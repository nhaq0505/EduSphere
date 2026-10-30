package com.edusphere.controller.course;

import com.edusphere.security.CustomUserDetails;
import com.edusphere.service.course.CourseActionException;
import com.edusphere.service.course.LearningResultService;

import jakarta.servlet.http.HttpServletResponse;

import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

/** UC32 (Instructor: công bố kết quả) và UC33 (Student: xem kết quả học tập). */
@Controller
public class LearningResultController {

    private final LearningResultService service;

    public LearningResultController(LearningResultService service) {
        this.service = service;
    }

    // ---------- UC32 ----------
    @GetMapping("/instructor/courses/{courseId}/results")
    public String instructorResults(@PathVariable Integer courseId,
                                    @AuthenticationPrincipal CustomUserDetails user, Model model) {
        model.addAttribute("course", service.ownedCourse(courseId, user.getUserId()));
        model.addAttribute("rows", service.instructorOverview(courseId, user.getUserId()));
        model.addAttribute("courseId", courseId);
        return "results/instructor-results";
    }

    @PostMapping("/instructor/courses/{courseId}/results/assignments/{assignmentId}/submissions/{submissionId}/publish")
    public String publishAssignment(@PathVariable Integer courseId, @PathVariable Integer assignmentId,
                                    @PathVariable Integer submissionId,
                                    @AuthenticationPrincipal CustomUserDetails user, RedirectAttributes flash) {
        service.publishAssignment(courseId, assignmentId, submissionId, user.getUserId());
        flash.addFlashAttribute("success", "Đã công bố kết quả bài tập.");
        return "redirect:/instructor/courses/" + courseId + "/results";
    }

    @PostMapping("/instructor/courses/{courseId}/results/quizzes/{quizId}/attempts/{attemptId}/publish")
    public String publishQuiz(@PathVariable Integer courseId, @PathVariable Integer quizId,
                              @PathVariable Integer attemptId,
                              @AuthenticationPrincipal CustomUserDetails user, RedirectAttributes flash) {
        service.publishQuiz(courseId, quizId, attemptId, user.getUserId());
        flash.addFlashAttribute("success", "Đã công bố kết quả quiz.");
        return "redirect:/instructor/courses/" + courseId + "/results";
    }

    @PostMapping("/instructor/courses/{courseId}/results/publish-all")
    public String publishAll(@PathVariable Integer courseId,
                             @AuthenticationPrincipal CustomUserDetails user, RedirectAttributes flash) {
        int n = service.publishAllReady(courseId, user.getUserId());
        flash.addFlashAttribute("success", n == 0
                ? "Không có kết quả nào sẵn sàng để công bố."
                : "Đã công bố " + n + " kết quả.");
        return "redirect:/instructor/courses/" + courseId + "/results";
    }

    // ---------- UC33 ----------
    @GetMapping("/courses/{courseId}/results")
    public String studentResults(@PathVariable Integer courseId,
                                 @AuthenticationPrincipal CustomUserDetails user, Model model) {
        model.addAttribute("results", service.studentResults(courseId, user.getUserId()));
        model.addAttribute("courseId", courseId);
        return "results/student-results";
    }

    @ExceptionHandler(CourseActionException.class)
    public String handleError(CourseActionException ex, HttpServletResponse response, Model model) {
        response.setStatus(ex.getStatus().value());
        model.addAttribute("errorMessage", ex.getMessage());
        return "courses/action-error";
    }
}
