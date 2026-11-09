package com.edusphere.controller.course;

import com.edusphere.dto.course.CourseView;
import com.edusphere.repository.course.EnrollmentRepository;
import com.edusphere.security.CustomUserDetails;
import com.edusphere.service.course.CertificateService;
import com.edusphere.service.course.CourseCommentService;
import com.edusphere.service.course.CourseDiscoveryService;

import jakarta.servlet.http.HttpServletResponse;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestParam;

@Controller
public class CourseDiscoveryController {

    private final CourseDiscoveryService courseDiscoveryService;
    private final EnrollmentRepository enrollmentRepository;

    @Autowired(required = false)
    private CourseCommentService courseCommentService;

    @Autowired(required = false)
    private CertificateService certificateService;

    public CourseDiscoveryController(CourseDiscoveryService courseDiscoveryService,
                                     EnrollmentRepository enrollmentRepository) {
        this.courseDiscoveryService = courseDiscoveryService;
        this.enrollmentRepository = enrollmentRepository;
    }

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

    public String detail(Integer courseId, CustomUserDetails user,
                         Model model, HttpServletResponse response) {
        return detail(courseId, "newest", user, model, response);
    }

    @GetMapping("/courses/{courseId}")
    public String detail(@PathVariable Integer courseId,
                         @RequestParam(value = "sort", defaultValue = "newest") String sort,
                         @AuthenticationPrincipal CustomUserDetails user,
                         Model model, HttpServletResponse response) {
        return courseDiscoveryService.findPublishedCourse(courseId)
                .map(course -> {
                    model.addAttribute("course", course);
                    model.addAttribute("lessonTitles", courseDiscoveryService.publishedLessonTitles(courseId));

                    boolean loggedIn = user != null;
                    boolean enrolled = loggedIn && enrollmentRepository
                            .findByStudent_UserIdAndCourse_CourseId(user.getUserId(), courseId)
                            .map(enrollment -> !"DROPPED".equals(enrollment.getStatus()))
                            .orElse(false);

                    model.addAttribute("student", loggedIn);
                    model.addAttribute("enrolled", enrolled);

                    if (courseCommentService != null) {
                        Integer currentUserId = loggedIn ? user.getUserId() : null;
                        model.addAttribute("courseComments", courseCommentService.getCourseComments(courseId, currentUserId, sort));
                        model.addAttribute("ratingSummary", courseCommentService.getCourseRatingSummary(courseId));
                        model.addAttribute("commentSort", sort);
                    }
                    if (certificateService != null && loggedIn && enrolled) {
                        certificateService.findExistingCertificate(user.getUserId(), courseId)
                                .ifPresent(cert -> model.addAttribute("myCertificateId", cert.getCertificateId()));
                    }
                    return "courses/detail";
                })
                .orElseGet(() -> {
                    response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                    return "courses/not-found";
                });
    }
}
