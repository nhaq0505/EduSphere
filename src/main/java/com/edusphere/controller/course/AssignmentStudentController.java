package com.edusphere.controller.course;

import com.edusphere.dto.assignment.SubmissionForm;
import com.edusphere.security.CustomUserDetails;
import com.edusphere.service.course.AssignmentService;
import com.edusphere.service.course.CourseActionException;

import jakarta.servlet.http.HttpServletResponse;

import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

@Controller
@RequestMapping("/courses/{courseId}/assignments")
public class AssignmentStudentController {

    private final AssignmentService service;

    public AssignmentStudentController(AssignmentService service) {
        this.service = service;
    }

    @GetMapping
    public String list(@PathVariable Integer courseId,
                       @AuthenticationPrincipal CustomUserDetails user, Model model) {
        model.addAttribute("assignments", service.listPublished(courseId, user.getUserId()));
        model.addAttribute("courseId", courseId);
        return "assignments/student-list";
    }

    @GetMapping("/{assignmentId}")
    public String detail(@PathVariable Integer courseId, @PathVariable Integer assignmentId,
                         @AuthenticationPrincipal CustomUserDetails user, Model model) {
        model.addAttribute("assignment", service.getAssignmentForStudent(courseId, assignmentId, user.getUserId()));
        model.addAttribute("mySubmissions", service.getMySubmissions(courseId, assignmentId, user.getUserId()));
        model.addAttribute("submissionForm", new SubmissionForm());
        model.addAttribute("courseId", courseId);
        model.addAttribute("assignmentId", assignmentId);
        return "assignments/student-detail";
    }

    @PostMapping("/{assignmentId}/submit")
    public String submit(@PathVariable Integer courseId, @PathVariable Integer assignmentId,
                         @ModelAttribute("submissionForm") SubmissionForm form,
                         @AuthenticationPrincipal CustomUserDetails user, RedirectAttributes flash) {
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
    public String result(@PathVariable Integer courseId, @PathVariable Integer assignmentId,
                         @AuthenticationPrincipal CustomUserDetails user, Model model) {
        model.addAttribute("assignment", service.getAssignmentForStudent(courseId, assignmentId, user.getUserId()));
        model.addAttribute("grade", service.getMyGrade(courseId, assignmentId, user.getUserId()).orElse(null));
        model.addAttribute("courseId", courseId);
        model.addAttribute("assignmentId", assignmentId);
        return "assignments/student-result";
    }

    @ExceptionHandler(CourseActionException.class)
    public String handleError(CourseActionException ex, HttpServletResponse response, Model model) {
        response.setStatus(ex.getStatus().value());
        model.addAttribute("errorMessage", ex.getMessage());
        return "courses/action-error";
    }
}
