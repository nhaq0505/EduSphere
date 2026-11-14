package com.edusphere.controller.course;

import com.edusphere.dto.course.CourseCommentView;
import com.edusphere.dto.course.CourseRatingSummary;
import com.edusphere.entity.course.CourseComment;
import com.edusphere.security.CustomUserDetails;
import com.edusphere.service.course.CourseActionException;
import com.edusphere.service.course.CourseCommentService;

import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

/**
 * Controller quản lý hệ thống Bình luận & Hỏi đáp (Q&A Discussion) dưới Khóa học và Bài giảng.
 * Hỗ trợ đăng câu hỏi, phản hồi theo luồng (threaded replies), thả tim (AJAX/Form), ghim bình luận và thống kê đánh giá.
 */
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
  public String addComment(
      @PathVariable Integer courseId,
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
          courseId,
          lessonId,
          parentCommentId,
          user.getUserId(),
          content,
          rating);
      flash.addFlashAttribute(
          "commentSuccess",
          parentCommentId != null
              ? "Đã gửi phản hồi của bạn."
              : (lessonId != null ? "Đã gửi câu hỏi cho Giáo viên." : "Đã đăng bình luận của bạn."));
      return buildRedirectUrl(
          courseId,
          saved.getLesson() != null ? saved.getLesson().getLessonId() : lessonId);
    } catch (CourseActionException ex) {
      flash.addFlashAttribute("commentError", ex.getMessage());
      return buildRedirectUrl(courseId, lessonId);
    }
  }

  /**
   * Thích / Bỏ thích bình luận (hỗ trợ cả form submit thông thường và AJAX).
   */
  @PostMapping("/courses/{courseId}/comments/{commentId}/like")
  public Object toggleLike(
      @PathVariable Integer courseId,
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
  public String togglePin(
      @PathVariable Integer courseId,
      @PathVariable Integer commentId,
      @RequestParam(required = false) Integer lessonId,
      @AuthenticationPrincipal CustomUserDetails user,
      RedirectAttributes flash) {
    if (user == null) {
      return "redirect:/login?courseId=" + courseId;
    }
    try {
      CourseComment pinned = commentService.togglePin(commentId, user.getUserId());
      flash.addFlashAttribute(
          "commentSuccess",
          Boolean.TRUE.equals(pinned.getPinned())
              ? "Đã ghim bình luận lên đầu."
              : "Đã bỏ ghim bình luận.");
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
  public String deleteComment(
      @PathVariable Integer courseId,
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

  /**
   * API JSON lấy danh sách bình luận và tổng quan đánh giá sao của khóa học.
   */
  @GetMapping("/courses/{courseId}/comments/json")
  @ResponseBody
  public ResponseEntity<Map<String, Object>> getCourseCommentsJson(
      @PathVariable Integer courseId,
      @RequestParam(name = "sort", defaultValue = "newest") String sort,
      @AuthenticationPrincipal CustomUserDetails user) {
    Integer currentUserId = user != null ? user.getUserId() : null;
    List<CourseCommentView> comments = commentService.getCourseComments(courseId, currentUserId, sort);
    CourseRatingSummary ratingSummary = commentService.getCourseRatingSummary(courseId);

    Map<String, Object> payload = new LinkedHashMap<>();
    payload.put("courseId", courseId);
    payload.put("sort", sort);
    payload.put("ratingSummary", ratingSummary);
    payload.put("comments", comments);
    payload.put("discussionStats", commentService.buildCourseDiscussionStats(courseId));
    return ResponseEntity.ok(payload);
  }

  /**
   * API JSON lấy danh sách câu hỏi trao đổi riêng trong bài giảng.
   */
  @GetMapping("/courses/{courseId}/lessons/{lessonId}/comments/json")
  @ResponseBody
  public ResponseEntity<Map<String, Object>> getLessonCommentsJson(
      @PathVariable Integer courseId,
      @PathVariable Integer lessonId,
      @RequestParam(name = "sort", defaultValue = "newest") String sort,
      @AuthenticationPrincipal CustomUserDetails user) {
    if (user == null) {
      Map<String, Object> unauthorized = new LinkedHashMap<>();
      unauthorized.put("authenticated", false);
      return ResponseEntity.status(401).body(unauthorized);
    }
    List<CourseCommentView> comments = commentService.getLessonComments(
        courseId, lessonId, user.getUserId(), sort);
    long totalCount = commentService.countLessonComments(courseId, lessonId, user.getUserId());

    Map<String, Object> payload = new LinkedHashMap<>();
    payload.put("authenticated", true);
    payload.put("courseId", courseId);
    payload.put("lessonId", lessonId);
    payload.put("totalCount", totalCount);
    payload.put("comments", comments);
    return ResponseEntity.ok(payload);
  }

  private String buildRedirectUrl(Integer courseId, Integer lessonId) {
    if (lessonId != null) {
      return "redirect:/courses/" + courseId + "/lessons/" + lessonId + "#comments-section";
    }
    return "redirect:/courses/" + courseId + "#comments-section";
  }
}
