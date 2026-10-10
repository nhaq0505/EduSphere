package com.edusphere.controller.course;

import com.edusphere.dto.course.StudyCourseView;
import com.edusphere.security.CustomUserDetails;
import com.edusphere.service.course.CourseActionException;
import com.edusphere.service.course.LearningService;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

@Controller
@PreAuthorize("hasRole('STUDENT')")
public class LessonStudyController {

    private final LearningService learningService;

    public LessonStudyController(LearningService learningService) {
        this.learningService = learningService;
    }

    @GetMapping("/courses/{courseId}/learn")
    public String startStudy(@PathVariable Integer courseId,
                             @AuthenticationPrincipal CustomUserDetails user,
                             Model model) {
        StudyCourseView context = learningService.getStudyContext(courseId, null, user.getUserId());
        if (context.currentLesson() != null) {
            return "redirect:/courses/" + courseId + "/lessons/" + context.currentLesson().lessonId();
        }
        model.addAttribute("study", context);
        model.addAttribute("studyContext", context);
        return "courses/study";
    }

    @GetMapping("/courses/{courseId}/lessons/{lessonId}")
    public String studyLesson(@PathVariable Integer courseId,
                             @PathVariable Integer lessonId,
                             @AuthenticationPrincipal CustomUserDetails user,
                             Model model) {
        StudyCourseView context = learningService.getStudyContext(courseId, lessonId, user.getUserId());
        model.addAttribute("study", context);
        model.addAttribute("studyContext", context);
        return "courses/study";
    }

    @PostMapping("/courses/{courseId}/lessons/{lessonId}/complete")
    public String completeLesson(@PathVariable Integer courseId,
                                 @PathVariable Integer lessonId,
                                 @AuthenticationPrincipal CustomUserDetails user,
                                 RedirectAttributes flash) {
        Integer nextLessonId = learningService.completeLesson(courseId, lessonId, user.getUserId());
        flash.addFlashAttribute("success", "Đã đánh dấu hoàn thành bài học.");
        if (nextLessonId != null) {
            return "redirect:/courses/" + courseId + "/lessons/" + nextLessonId;
        }
        flash.addFlashAttribute("courseCompleted", true);
        return "redirect:/courses/" + courseId + "/lessons/" + lessonId;
    }

    @ExceptionHandler(CourseActionException.class)
    public String handleCourseActionError(CourseActionException ex, HttpServletResponse response, Model model) {
        response.setStatus(ex.getStatus().value());
        model.addAttribute("errorMessage", ex.getMessage());
        return "courses/action-error";
    }
}
