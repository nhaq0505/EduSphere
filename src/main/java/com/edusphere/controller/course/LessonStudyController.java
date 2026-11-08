package com.edusphere.controller.course;

import com.edusphere.dto.course.LessonItemView;
import com.edusphere.dto.course.StudyCourseView;
import com.edusphere.security.CustomUserDetails;
import com.edusphere.service.course.CourseActionException;
import com.edusphere.service.course.LearningService;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.HashMap;
import java.util.Map;

@Controller
@PreAuthorize("hasAnyRole('STUDENT', 'INSTRUCTOR', 'ADMINISTRATOR')")
public class LessonStudyController {

    private final LearningService learningService;

    public LessonStudyController(LearningService learningService) {
        this.learningService = learningService;
    }

    @GetMapping("/courses/{courseId}/learn")
    public String startStudy(@PathVariable Integer courseId,
                             @AuthenticationPrincipal CustomUserDetails user, Model model) {
        StudyCourseView context = learningService.getStudyContext(courseId, null, user.getUserId());
        if (context.currentLesson() != null) {
            return "redirect:/courses/" + courseId + "/lessons/" + context.currentLesson().lessonId();
        }
        model.addAttribute("study", context);
        return "courses/study";
    }

    @GetMapping("/courses/{courseId}/lessons/{lessonId}")
    public String studyLesson(@PathVariable Integer courseId,
                              @PathVariable Integer lessonId,
                              @RequestParam(required = false) String tab,
                              @AuthenticationPrincipal CustomUserDetails user,
                              Model model,
                              RedirectAttributes flash) {
        StudyCourseView context = learningService.getStudyContext(courseId, lessonId, user.getUserId());
        if (context.getCurrentLesson() != null && context.getCurrentLesson().isLocked() && !context.isPreviewMode()) {
            Integer fallbackLessonId = context.getLessons().stream()
                    .filter(l -> !l.isLocked())
                    .map(LessonItemView::getLessonId)
                    .reduce((first, second) -> second)
                    .orElse(lessonId);
            flash.addFlashAttribute("error", "🔒 Bài học này đang bị khóa. Bạn cần hoàn thành bài học và bài kiểm tra trước đó để mở khóa.");
            if (fallbackLessonId != null && !fallbackLessonId.equals(lessonId)) {
                return "redirect:/courses/" + courseId + "/lessons/" + fallbackLessonId;
            }
        }
        model.addAttribute("study", context);
        model.addAttribute("studyContext", context);
        if ("exercise".equals(tab)) model.addAttribute("initialTab", "exercise");
        return "courses/study";
    }

    @PostMapping("/courses/{courseId}/lessons/{lessonId}/complete")
    public String completeLesson(@PathVariable Integer courseId,
                                 @PathVariable Integer lessonId,
                                 @AuthenticationPrincipal CustomUserDetails user,
                                 RedirectAttributes flash) {
        try {
            Integer nextLessonId = learningService.completeLesson(courseId, lessonId, user.getUserId());
            flash.addFlashAttribute("success", "Đã đánh dấu hoàn thành bài học.");
            if (nextLessonId != null) return "redirect:/courses/" + courseId + "/lessons/" + nextLessonId;
            flash.addFlashAttribute("courseCompleted", true);
            return "redirect:/courses/" + courseId + "/lessons/" + lessonId;
        } catch (CourseActionException ex) {
            flash.addFlashAttribute("error", ex.getMessage());
            return "redirect:/courses/" + courseId + "/lessons/" + lessonId;
        }
    }

    /**
     * AJAX endpoint — học viên gửi tiến độ xem video mỗi ~4-5 giây hoặc khi pause/ended.
     * POST /courses/{courseId}/lessons/{lessonId}/watch-progress
     * Body params: start, end (khoảng thời gian xem thực tế), position (vị trí hiện tại), duration (tổng thời lượng), percent (fallback)
     */
    @PostMapping("/courses/{courseId}/lessons/{lessonId}/watch-progress")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> saveWatchProgress(
            @PathVariable Integer courseId,
            @PathVariable Integer lessonId,
            @RequestParam(required = false) Double start,
            @RequestParam(required = false) Double end,
            @RequestParam(defaultValue = "0") int position,
            @RequestParam(required = false) Double duration,
            @RequestParam(defaultValue = "0") int percent,
            @AuthenticationPrincipal CustomUserDetails user) {
        try {
            Map<String, Object> resp = learningService.saveWatchProgress(
                    courseId, lessonId, user.getUserId(), start, end, position, duration, percent);
            return ResponseEntity.ok(resp);
        } catch (CourseActionException ex) {
            Map<String, Object> resp = new HashMap<>();
            resp.put("success", false);
            resp.put("message", ex.getMessage());
            return ResponseEntity.status(ex.getStatus()).body(resp);
        }
    }

    @ExceptionHandler(CourseActionException.class)
    public String handleCourseActionError(CourseActionException ex, HttpServletResponse response, Model model) {
        response.setStatus(ex.getStatus().value());
        model.addAttribute("errorMessage", ex.getMessage());
        return "courses/action-error";
    }
}

