package com.edusphere.controller.course;

import com.edusphere.entity.course.CourseComment;
import com.edusphere.security.CustomUserDetails;
import com.edusphere.service.course.CourseActionException;
import com.edusphere.service.course.CourseCommentService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.HashMap;
import java.util.Map;

@Controller
public class CourseCommentController {

    private final CourseCommentService commentService;

    @Autowired
    public CourseCommentController(CourseCommentService commentService) {
        this.commentService = commentService;
    }

    /**
     * Đăng bình luận mới hoặc trả lời bình luận dưới Khóa học hoặc Bài giảng.
     */
    @PostMapping("/courses/{courseId}/comments")
    public String addComment(@PathVariable Integer courseId,
                             @RequestParam(required = false) Integer lessonId,
                             @RequestParam(required = false) Integer parentCommentId,
                             @RequestParam String content,
                             @RequestParam(required = false) Integer rating,
                             @AuthenticationPrincipal CustomUserDetails user,
                             RedirectAttributes flash) {
        if (user == null) {
            return "redirect:/login?courseId=" + courseId;
        }
        try {
            CourseComment saved = commentService.addComment(
                    courseId, lessonId, parentCommentId, user.getUserId(), content, rating);
            flash.addFlashAttribute("commentSuccess",
                    parentCommentId != null ? "Đã gửi phản hồi của bạn." : "Đã đăng bình luận của bạn.");
            return buildRedirectUrl(courseId, saved.getLesson() != null ? saved.getLesson().getLessonId() : lessonId);
        } catch (CourseActionException ex) {
            flash.addFlashAttribute("commentError", ex.getMessage());
            return buildRedirectUrl(courseId, lessonId);
        }
    }

    /**
     * Thích / Bỏ thích bình luận (hỗ trợ cả form submit thông thường và AJAX).
     */
    @PostMapping("/courses/{courseId}/comments/{commentId}/like")
    public Object toggleLike(@PathVariable Integer courseId,
                             @PathVariable Integer commentId,
                             @RequestParam(required = false) Integer lessonId,
                             @RequestHeader(value = "X-Requested-With", required = false) String requestedWith,
                             @RequestHeader(value = "Accept", required = false) String accept,
                             @AuthenticationPrincipal CustomUserDetails user,
                             RedirectAttributes flash) {
        boolean isAjax = "XMLHttpRequest".equalsIgnoreCase(requestedWith)
                || (accept != null && accept.contains("application/json"));
        if (user == null) {
            if (isAjax) {
                Map<String, Object> err = new HashMap<>();
                err.put("success", false);
                err.put("message", "Vui lòng đăng nhập để thích bình luận.");
                return ResponseEntity.status(401).body(err);
            }
            return "redirect:/login?courseId=" + courseId;
        }

        try {
            Map<String, Object> res = commentService.toggleLike(commentId, user.getUserId());
            res.put("success", true);
            if (isAjax) {
                return ResponseEntity.ok(res);
            }
            Integer targetLessonId = lessonId != null ? lessonId : (Integer) res.get("lessonId");
            return buildRedirectUrl(courseId, targetLessonId);
        } catch (CourseActionException ex) {
            if (isAjax) {
                Map<String, Object> err = new HashMap<>();
                err.put("success", false);
                err.put("message", ex.getMessage());
                return ResponseEntity.status(ex.getStatus()).body(err);
            }
            flash.addFlashAttribute("commentError", ex.getMessage());
            return buildRedirectUrl(courseId, lessonId);
        }
    }

    /**
     * Ghim / Bỏ ghim bình luận (dành cho Giảng viên khóa học hoặc Quản trị viên).
     */
    @PostMapping("/courses/{courseId}/comments/{commentId}/pin")
    public String togglePin(@PathVariable Integer courseId,
                            @PathVariable Integer commentId,
                            @RequestParam(required = false) Integer lessonId,
                            @AuthenticationPrincipal CustomUserDetails user,
                            RedirectAttributes flash) {
        if (user == null) {
            return "redirect:/login?courseId=" + courseId;
        }
        try {
            CourseComment pinned = commentService.togglePin(commentId, user.getUserId());
            flash.addFlashAttribute("commentSuccess",
                    Boolean.TRUE.equals(pinned.getPinned()) ? "Đã ghim bình luận lên đầu." : "Đã bỏ ghim bình luận.");
            Integer targetLessonId = pinned.getLesson() != null ? pinned.getLesson().getLessonId() : lessonId;
            return buildRedirectUrl(courseId, targetLessonId);
        } catch (CourseActionException ex) {
            flash.addFlashAttribute("commentError", ex.getMessage());
            return buildRedirectUrl(courseId, lessonId);
        }
    }

    /**
     * Xóa bình luận (dành cho tác giả bình luận, Giảng viên khóa học hoặc Quản trị viên).
     */
    @PostMapping("/courses/{courseId}/comments/{commentId}/delete")
    public String deleteComment(@PathVariable Integer courseId,
                                @PathVariable Integer commentId,
                                @RequestParam(required = false) Integer lessonId,
                                @AuthenticationPrincipal CustomUserDetails user,
                                RedirectAttributes flash) {
        if (user == null) {
            return "redirect:/login?courseId=" + courseId;
        }
        try {
            CourseComment deleted = commentService.deleteComment(commentId, user.getUserId());
            flash.addFlashAttribute("commentSuccess", "Đã xóa bình luận.");
            Integer targetLessonId = deleted.getLesson() != null ? deleted.getLesson().getLessonId() : lessonId;
            return buildRedirectUrl(courseId, targetLessonId);
        } catch (CourseActionException ex) {
            flash.addFlashAttribute("commentError", ex.getMessage());
            return buildRedirectUrl(courseId, lessonId);
        }
    }

    private String buildRedirectUrl(Integer courseId, Integer lessonId) {
        if (lessonId != null) {
            return "redirect:/courses/" + courseId + "/lessons/" + lessonId + "#comments-section";
        }
        return "redirect:/courses/" + courseId + "#comments-section";
    }
}
