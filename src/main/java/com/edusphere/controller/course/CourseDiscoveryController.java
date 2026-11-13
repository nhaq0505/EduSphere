package com.edusphere.controller.course;

import com.edusphere.dto.course.CourseRatingSummaryView;
import com.edusphere.dto.course.CourseView;
import com.edusphere.dto.course.LessonItemView;
import com.edusphere.dto.course.StudyCourseView;
import com.edusphere.repository.course.EnrollmentRepository;
import com.edusphere.security.CustomUserDetails;
import com.edusphere.service.course.CertificateService;
import com.edusphere.service.course.CourseActionException;
import com.edusphere.service.course.CourseCommentService;
import com.edusphere.service.course.CourseDiscoveryService;
import com.edusphere.service.course.CourseRatingService;

import jakarta.servlet.http.HttpServletResponse;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

@Controller
public class CourseDiscoveryController {

    private final CourseDiscoveryService courseDiscoveryService;
    private final EnrollmentRepository enrollmentRepository;
    private final CourseRatingService courseRatingService;

    @Autowired(required = false)
    private CourseCommentService courseCommentService;

    @Autowired(required = false)
    private CertificateService certificateService;

    public CourseDiscoveryController(CourseDiscoveryService courseDiscoveryService,
                                     EnrollmentRepository enrollmentRepository,
                                     CourseRatingService courseRatingService) {
        this.courseDiscoveryService = courseDiscoveryService;
        this.enrollmentRepository = enrollmentRepository;
        this.courseRatingService = courseRatingService;
    }

    /**
     * Hiển thị danh sách khóa học công khai kèm bộ lọc tìm kiếm, danh mục, trình độ và học phí.
     */
    @GetMapping("/courses")
    public String list(@RequestParam(defaultValue = "") String q,
                       @RequestParam(required = false) Integer categoryId,
                       @RequestParam(defaultValue = "") String level,
                       @RequestParam(defaultValue = "") String priceFilter,
                       @RequestParam(defaultValue = "0") int page,
                       Model model) {
        Page<CourseView> coursePage = courseDiscoveryService.search(q, categoryId, level, priceFilter, page);
        model.addAttribute("coursePage", coursePage);
        model.addAttribute("categories", courseDiscoveryService.activeCategories());
        model.addAttribute("q", q.trim());
        model.addAttribute("categoryId", categoryId);
        model.addAttribute("level", level.toUpperCase());
        model.addAttribute("priceFilter", priceFilter.toUpperCase());
        return "courses/list";
    }

    @GetMapping("/courses/{courseId}")
    public String detail(@PathVariable Integer courseId,
                         @RequestParam(value = "sort", defaultValue = "newest") String sort,
                         @AuthenticationPrincipal CustomUserDetails user,
                         Model model, HttpServletResponse response) {
        return courseDiscoveryService.findPublishedCourse(courseId)
                .map(course -> {
                    model.addAttribute("course", course);
                    List<LessonItemView> publishedLessons = courseDiscoveryService.publishedLessonItems(courseId);
                    model.addAttribute("lessons", publishedLessons);
                    model.addAttribute("sections", StudyCourseView.buildSections(publishedLessons, course.getTitle()));
                    model.addAttribute("lessonTitles", publishedLessons.stream().map(LessonItemView::getTitle).toList());

                    boolean loggedIn = user != null;
                    Integer currentUserId = loggedIn ? user.getUserId() : null;
                    boolean isAdmin = loggedIn && user.getAuthorities().stream()
                            .anyMatch(a -> "ROLE_ADMINISTRATOR".equals(a.getAuthority()));
                    boolean enrolled = loggedIn && enrollmentRepository
                            .findByStudent_UserIdAndCourse_CourseId(currentUserId, courseId)
                            .map(enrollment -> !"DROPPED".equals(enrollment.getStatus()))
                            .orElse(false);

                    CourseRatingSummaryView ratingSummary = courseRatingService
                            .getRatingSummary(courseId, currentUserId, isAdmin);

                    model.addAttribute("student", loggedIn);
                    model.addAttribute("enrolled", enrolled);
                    model.addAttribute("ratingSummary", ratingSummary);
                    if (courseCommentService != null) {
                        model.addAttribute("courseComments", courseCommentService.getCourseComments(courseId, currentUserId, sort));
                        model.addAttribute("commentSort", sort);
                    }
                    if (certificateService != null && loggedIn && enrolled) {
                        certificateService.issueCertificateIfEligible(currentUserId, courseId)
                                .ifPresent(cert -> model.addAttribute("myCertificateId", cert.getCertificateId()));
                    }
                    return "courses/detail";
                })
                .orElseGet(() -> {
                    response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                    return "courses/not-found";
                });
    }

    /**
     * Học viên gửi mới hoặc cập nhật đánh giá sao (1–5 sao) và nhận xét cho khóa học.
     */
    @PostMapping("/courses/{courseId}/ratings")
    public String submitRating(@PathVariable Integer courseId,
                               @RequestParam Integer rating,
                               @RequestParam(required = false) String comment,
                               @AuthenticationPrincipal CustomUserDetails user,
                               RedirectAttributes flash) {
        if (user == null) {
            return "redirect:/login?courseId=" + courseId;
        }
        try {
            courseRatingService.submitOrUpdateRating(courseId, user.getUserId(), rating, comment);
            flash.addFlashAttribute("ratingSuccess", "Cảm ơn bạn! Đánh giá khóa học của bạn đã được lưu.");
        } catch (CourseActionException ex) {
            flash.addFlashAttribute("ratingError", ex.getMessage());
        }
        return "redirect:/courses/" + courseId + "#course-reviews";
    }

    /**
     * Học viên xóa đánh giá của chính mình trên khóa học.
     */
    @PostMapping("/courses/{courseId}/ratings/delete")
    public String deleteRating(@PathVariable Integer courseId,
                               @AuthenticationPrincipal CustomUserDetails user,
                               RedirectAttributes flash) {
        if (user == null) {
            return "redirect:/login?courseId=" + courseId;
        }
        try {
            courseRatingService.deleteMyRating(courseId, user.getUserId());
            flash.addFlashAttribute("ratingSuccess", "Đã xóa đánh giá của bạn.");
        } catch (CourseActionException ex) {
            flash.addFlashAttribute("ratingError", ex.getMessage());
        }
        return "redirect:/courses/" + courseId + "#course-reviews";
    }

    /**
     * Giảng viên của khóa học (hoặc Admin) gửi phản hồi cho đánh giá của học viên.
     */
    @PostMapping("/courses/{courseId}/ratings/{ratingId}/reply")
    public String replyRating(@PathVariable Integer courseId,
                              @PathVariable Integer ratingId,
                              @RequestParam(required = false) String replyText,
                              @AuthenticationPrincipal CustomUserDetails user,
                              RedirectAttributes flash) {
        if (user == null) {
            return "redirect:/login?courseId=" + courseId;
        }
        boolean isAdmin = user.getAuthorities().stream()
                .anyMatch(a -> "ROLE_ADMINISTRATOR".equals(a.getAuthority()));
        try {
            courseRatingService.replyToRating(courseId, ratingId, user.getUserId(), isAdmin, replyText);
            flash.addFlashAttribute("ratingSuccess", "Đã cập nhật phản hồi đánh giá.");
        } catch (CourseActionException ex) {
            flash.addFlashAttribute("ratingError", ex.getMessage());
        }
        return "redirect:/courses/" + courseId + "#course-reviews";
    }
}
