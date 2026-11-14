package com.edusphere.controller.course;

import com.edusphere.dto.assignment.AssignmentView;
import com.edusphere.dto.assignment.SubmissionForm;
import com.edusphere.entity.course.Assignment;
import com.edusphere.entity.course.Grade;
import com.edusphere.entity.course.Submission;
import com.edusphere.security.CustomUserDetails;
import com.edusphere.service.course.AssignmentService;
import com.edusphere.service.course.CourseActionException;

import jakarta.servlet.http.HttpServletResponse;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDateTime;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

/**
 * Controller phục vụ luồng bài tập phía Học viên (UC29 - View & Submit Assignment, UC31 - View Grade).
 * Bổ sung thống kê hạn nộp, lượt nộp còn lại và API JSON tra cứu trạng thái nộp bài.
 */
@Controller
@RequestMapping("/courses/{courseId}/assignments")
public class AssignmentStudentController {

  private final AssignmentService service;

  public AssignmentStudentController(AssignmentService service) {
    this.service = service;
  }

  @GetMapping
  public String list(
      @PathVariable Integer courseId,
      @AuthenticationPrincipal CustomUserDetails user,
      Model model) {
    List<AssignmentView> assignments = service.listPublished(courseId, user.getUserId());
    model.addAttribute("assignments", assignments);
    model.addAttribute("assignmentStats", buildStudentAssignmentListStats(assignments));
    model.addAttribute("courseId", courseId);
    return "assignments/student-list";
  }

  @GetMapping("/{assignmentId}")
  public String detail(
      @PathVariable Integer courseId,
      @PathVariable Integer assignmentId,
      @AuthenticationPrincipal CustomUserDetails user,
      Model model) {
    Assignment assignment = service.getAssignmentForStudent(courseId, assignmentId, user.getUserId());
    List<Submission> mySubmissions = service.getMySubmissions(courseId, assignmentId, user.getUserId());
    Optional<Grade> publishedGrade = service.getMyGrade(courseId, assignmentId, user.getUserId());

    int usedAttempts = mySubmissions != null ? mySubmissions.size() : 0;
    int maxAttempts = assignment.getMaxAttempts() != null ? assignment.getMaxAttempts() : 1;
    int remainingAttempts = Math.max(0, maxAttempts - usedAttempts);
    boolean isOverdue = assignment.getDueDate() != null
        && LocalDateTime.now().isAfter(assignment.getDueDate());

    model.addAttribute("assignment", assignment);
    model.addAttribute("mySubmissions", mySubmissions);
    model.addAttribute("publishedGrade", publishedGrade.orElse(null));
    model.addAttribute("usedAttempts", usedAttempts);
    model.addAttribute("remainingAttempts", remainingAttempts);
    model.addAttribute("isOverdue", isOverdue);
    model.addAttribute("submissionForm", new SubmissionForm());
    model.addAttribute("courseId", courseId);
    model.addAttribute("assignmentId", assignmentId);
    return "assignments/student-detail";
  }

  @PostMapping("/{assignmentId}/submit")
  public String submit(
      @PathVariable Integer courseId,
      @PathVariable Integer assignmentId,
      @ModelAttribute("submissionForm") SubmissionForm form,
      @AuthenticationPrincipal CustomUserDetails user,
      RedirectAttributes flash) {
    service.submit(courseId, assignmentId, user.getUserId(), form);
    flash.addFlashAttribute("success", "Nộp bài thành công! Giảng viên sẽ sớm chấm và công bố kết quả.");
    // Nếu assignment gắn với lesson → redirect về trang học lesson đó (tab bài tập)
    var assignment = service.getAssignmentForStudent(courseId, assignmentId, user.getUserId());
    if (assignment.getLesson() != null) {
      return "redirect:/courses/" + courseId + "/lessons/" + assignment.getLesson().getLessonId() + "?tab=exercise";
    }
    return "redirect:/courses/" + courseId + "/assignments/" + assignmentId;
  }

  @GetMapping("/{assignmentId}/result")
  public String result(
      @PathVariable Integer courseId,
      @PathVariable Integer assignmentId,
      @AuthenticationPrincipal CustomUserDetails user,
      Model model) {
    Assignment assignment = service.getAssignmentForStudent(courseId, assignmentId, user.getUserId());
    Grade grade = service.getMyGrade(courseId, assignmentId, user.getUserId()).orElse(null);
    List<Submission> mySubmissions = service.getMySubmissions(courseId, assignmentId, user.getUserId());

    BigDecimal scorePercent = null;
    String standingLabel = "Chưa công bố";
    if (grade != null
        && grade.getScore() != null
        && grade.getMaxScore() != null
        && grade.getMaxScore().signum() > 0) {
      scorePercent = grade.getScore()
          .multiply(BigDecimal.valueOf(100))
          .divide(grade.getMaxScore(), 1, RoundingMode.HALF_UP);
      standingLabel = classifyStanding(scorePercent);
    }

    model.addAttribute("assignment", assignment);
    model.addAttribute("grade", grade);
    model.addAttribute("mySubmissions", mySubmissions);
    model.addAttribute("scorePercent", scorePercent);
    model.addAttribute("standingLabel", standingLabel);
    model.addAttribute("courseId", courseId);
    model.addAttribute("assignmentId", assignmentId);
    return "assignments/student-result";
  }

  @GetMapping("/{assignmentId}/status-json")
  @ResponseBody
  public ResponseEntity<Map<String, Object>> assignmentStatusJson(
      @PathVariable Integer courseId,
      @PathVariable Integer assignmentId,
      @AuthenticationPrincipal CustomUserDetails user) {
    Assignment assignment = service.getAssignmentForStudent(courseId, assignmentId, user.getUserId());
    List<Submission> mySubmissions = service.getMySubmissions(courseId, assignmentId, user.getUserId());
    Optional<Grade> myGrade = service.getMyGrade(courseId, assignmentId, user.getUserId());

    int usedAttempts = mySubmissions != null ? mySubmissions.size() : 0;
    int maxAttempts = assignment.getMaxAttempts() != null ? assignment.getMaxAttempts() : 1;

    Map<String, Object> payload = new LinkedHashMap<>();
    payload.put("courseId", courseId);
    payload.put("assignmentId", assignmentId);
    payload.put("title", assignment.getTitle());
    payload.put("maxScore", assignment.getMaxScore());
    payload.put("maxAttempts", maxAttempts);
    payload.put("usedAttempts", usedAttempts);
    payload.put("remainingAttempts", Math.max(0, maxAttempts - usedAttempts));
    payload.put("hasPublishedGrade", myGrade.isPresent());
    myGrade.ifPresent(g -> {
      payload.put("score", g.getScore());
      payload.put("feedback", g.getFeedback());
      payload.put("gradedAt", g.getGradedAt());
    });
    return ResponseEntity.ok(payload);
  }

  @ExceptionHandler(CourseActionException.class)
  public String handleError(
      CourseActionException ex,
      HttpServletResponse response,
      Model model) {
    response.setStatus(ex.getStatus().value());
    model.addAttribute("errorMessage", ex.getMessage());
    return "courses/action-error";
  }

  private Map<String, Object> buildStudentAssignmentListStats(List<AssignmentView> items) {
    Map<String, Object> stats = new LinkedHashMap<>();
    if (items == null || items.isEmpty()) {
      stats.put("totalCount", 0);
      stats.put("withDueDateCount", 0);
      stats.put("upcomingCount", 0);
      return stats;
    }
    int totalCount = items.size();
    int withDueDateCount = 0;
    int upcomingCount = 0;
    LocalDateTime now = LocalDateTime.now();
    for (AssignmentView item : items) {
      if (item != null && item.getDueDate() != null) {
        withDueDateCount++;
        if (item.getDueDate().isAfter(now)) {
          upcomingCount++;
        }
      }
    }
    stats.put("totalCount", totalCount);
    stats.put("withDueDateCount", withDueDateCount);
    stats.put("upcomingCount", upcomingCount);
    return stats;
  }

  private String classifyStanding(BigDecimal pct) {
    if (pct == null) {
      return "Chưa xếp loại";
    }
    double val = pct.doubleValue();
    if (val >= 85.0) {
      return "Xuất sắc (A)";
    }
    if (val >= 70.0) {
      return "Khá giỏi (B)";
    }
    if (val >= 50.0) {
      return "Đạt yêu cầu (C)";
    }
    return "Cần cố gắng thêm (D/F)";
  }
}
