package com.edusphere.controller.course;

import com.edusphere.dto.result.ResultRow;
import com.edusphere.dto.result.StudentResultsView;
import com.edusphere.entity.course.Course;
import com.edusphere.security.CustomUserDetails;
import com.edusphere.service.course.CourseActionException;
import com.edusphere.service.course.LearningResultService;

import jakarta.servlet.http.HttpServletResponse;

import java.nio.charset.StandardCharsets;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

/**
 * UC32 (Instructor: công bố kết quả) và UC33 (Student: xem kết quả học tập).
 * Bổ sung bộ lọc kết quả, thống kê phân bố điểm (Gradebook Stats), xếp hạng học viên và xuất CSV/JSON.
 */
@Controller
public class LearningResultController {

  private final LearningResultService service;

  public LearningResultController(LearningResultService service) {
    this.service = service;
  }

  // ---------- UC32 ----------

  @GetMapping("/instructor/courses/{courseId}/results")
  public String instructorResults(
      @PathVariable Integer courseId,
      @RequestParam(name = "kind", required = false) String kind,
      @RequestParam(name = "state", required = false) String state,
      @RequestParam(name = "q", required = false) String keyword,
      @AuthenticationPrincipal CustomUserDetails user,
      Model model) {
    Course course = service.ownedCourse(courseId, user.getUserId());
    List<ResultRow> allRows = service.instructorOverview(courseId, user.getUserId());
    List<ResultRow> rows = (kind == null && state == null && keyword == null)
        ? allRows
        : service.filterInstructorOverview(courseId, user.getUserId(), kind, state, keyword);

    Map<String, Object> gradebookStats = service.buildInstructorGradebookStats(allRows);
    List<Map<String, Object>> studentLeaderboard = service.buildStudentPerformanceLeaderboard(allRows);

    model.addAttribute("course", course);
    model.addAttribute("rows", rows);
    model.addAttribute("allRowsCount", allRows.size());
    model.addAttribute("gradebookStats", gradebookStats);
    model.addAttribute("studentLeaderboard", studentLeaderboard);
    model.addAttribute("selectedKind", kind != null ? kind : "ALL");
    model.addAttribute("selectedState", state != null ? state : "ALL");
    model.addAttribute("searchKeyword", keyword != null ? keyword : "");
    model.addAttribute("courseId", courseId);
    return "results/instructor-results";
  }

  /**
   * Overload tương thích ngược cho các unit test gọi trực tiếp 3 tham số.
   */
  public String instructorResults(
      Integer courseId,
      CustomUserDetails user,
      Model model) {
    return instructorResults(courseId, null, null, null, user, model);
  }

  @PostMapping("/instructor/courses/{courseId}/results/assignments/{assignmentId}/submissions/{submissionId}/publish")
  public String publishAssignment(
      @PathVariable Integer courseId,
      @PathVariable Integer assignmentId,
      @PathVariable Integer submissionId,
      @AuthenticationPrincipal CustomUserDetails user,
      RedirectAttributes flash) {
    service.publishAssignment(courseId, assignmentId, submissionId, user.getUserId());
    flash.addFlashAttribute("success", "Đã công bố kết quả bài tập.");
    return "redirect:/instructor/courses/" + courseId + "/results";
  }

  @PostMapping("/instructor/courses/{courseId}/results/quizzes/{quizId}/attempts/{attemptId}/publish")
  public String publishQuiz(
      @PathVariable Integer courseId,
      @PathVariable Integer quizId,
      @PathVariable Integer attemptId,
      @AuthenticationPrincipal CustomUserDetails user,
      RedirectAttributes flash) {
    service.publishQuiz(courseId, quizId, attemptId, user.getUserId());
    flash.addFlashAttribute("success", "Đã công bố kết quả quiz.");
    return "redirect:/instructor/courses/" + courseId + "/results";
  }

  @PostMapping("/instructor/courses/{courseId}/results/publish-all")
  public String publishAll(
      @PathVariable Integer courseId,
      @AuthenticationPrincipal CustomUserDetails user,
      RedirectAttributes flash) {
    int n = service.publishAllReady(courseId, user.getUserId());
    flash.addFlashAttribute(
        "success",
        n == 0
            ? "Không có kết quả nào sẵn sàng để công bố."
            : "Đã công bố " + n + " kết quả.");
    return "redirect:/instructor/courses/" + courseId + "/results";
  }

  @PostMapping("/instructor/courses/{courseId}/results/publish-by-kind")
  public String publishByKind(
      @PathVariable Integer courseId,
      @RequestParam(name = "kind", defaultValue = "ALL") String kind,
      @AuthenticationPrincipal CustomUserDetails user,
      RedirectAttributes flash) {
    int n = service.publishReadyByKind(courseId, user.getUserId(), kind);
    String kindLabel = "QUIZ".equalsIgnoreCase(kind)
        ? "quiz"
        : ("ASSIGNMENT".equalsIgnoreCase(kind) ? "bài tập" : "kết quả");
    flash.addFlashAttribute(
        "success",
        n == 0
            ? "Không có " + kindLabel + " nào sẵn sàng để công bố."
            : "Đã công bố " + n + " " + kindLabel + ".");
    return "redirect:/instructor/courses/" + courseId + "/results";
  }

  @GetMapping("/instructor/courses/{courseId}/results/export-csv")
  public ResponseEntity<byte[]> exportInstructorCsv(
      @PathVariable Integer courseId,
      @AuthenticationPrincipal CustomUserDetails user) {
    Course course = service.ownedCourse(courseId, user.getUserId());
    List<ResultRow> rows = service.instructorOverview(courseId, user.getUserId());
    String csvContent = service.exportInstructorResultsCsv(course, rows);
    byte[] bytes = csvContent.getBytes(StandardCharsets.UTF_8);

    String filename = "ket-qua-khoa-hoc-" + courseId + ".csv";
    return ResponseEntity.ok()
        .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"" + filename + "\"")
        .contentType(new MediaType("text", "csv", StandardCharsets.UTF_8))
        .body(bytes);
  }

  @GetMapping("/instructor/courses/{courseId}/results/analytics-json")
  @ResponseBody
  public ResponseEntity<Map<String, Object>> instructorAnalyticsJson(
      @PathVariable Integer courseId,
      @AuthenticationPrincipal CustomUserDetails user) {
    Course course = service.ownedCourse(courseId, user.getUserId());
    List<ResultRow> rows = service.instructorOverview(courseId, user.getUserId());
    Map<String, Object> payload = new LinkedHashMap<>();
    payload.put("courseId", courseId);
    payload.put("courseTitle", course.getTitle());
    payload.put("stats", service.buildInstructorGradebookStats(rows));
    payload.put("leaderboard", service.buildStudentPerformanceLeaderboard(rows));
    return ResponseEntity.ok(payload);
  }

  // ---------- UC33 ----------

  @GetMapping("/courses/{courseId}/results")
  public String studentResults(
      @PathVariable Integer courseId,
      @AuthenticationPrincipal CustomUserDetails user,
      Model model) {
    StudentResultsView results = service.studentResults(courseId, user.getUserId());
    model.addAttribute("results", results);
    model.addAttribute("courseId", courseId);
    return "results/student-results";
  }

  @GetMapping("/courses/{courseId}/results/summary-json")
  @ResponseBody
  public ResponseEntity<Map<String, Object>> studentResultsJson(
      @PathVariable Integer courseId,
      @AuthenticationPrincipal CustomUserDetails user) {
    StudentResultsView results = service.studentResults(courseId, user.getUserId());
    Map<String, Object> payload = new LinkedHashMap<>();
    payload.put("courseId", courseId);
    payload.put("courseTitle", results.getCourseTitle());
    payload.put("totalCount", results.getTotalCount());
    payload.put("publishedCount", results.getPublishedCount());
    payload.put("pendingCount", results.getPendingCount());
    payload.put("averagePercent", results.getAveragePercent());
    payload.put("averageScale10", results.getAverageScale10());
    payload.put("academicStandingLabel", results.getAcademicStandingLabel());
    payload.put("quizAveragePercent", results.getQuizAveragePercent());
    payload.put("assignmentAveragePercent", results.getAssignmentAveragePercent());
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
}
