package com.edusphere.controller.course;

import com.edusphere.dto.course.CourseForm;
import com.edusphere.dto.course.InstructorDashboardStats;
import com.edusphere.security.CustomUserDetails;
import com.edusphere.service.course.CourseActionException;
import com.edusphere.service.course.CourseManagementService;
import com.edusphere.service.course.LearningService;
import com.edusphere.service.course.RevenueService;

import jakarta.servlet.http.HttpServletResponse;
import jakarta.validation.Valid;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

@Controller
public class CourseManagementController {
    private final CourseManagementService service;
    private final LearningService learningService;

    @Autowired(required = false)
    private RevenueService revenueService;

    public CourseManagementController(CourseManagementService service) {
        this(service, null);
    }

    @Autowired
    public CourseManagementController(CourseManagementService service, LearningService learningService) {
        this.service = service;
        this.learningService = learningService;
    }

    @GetMapping("/my-courses")
    public String myCourses(@AuthenticationPrincipal CustomUserDetails user, Model model) {
        model.addAttribute("courses", service.enrolledCourses(user.getUserId()));
        return "courses/my-courses";
    }

    @PostMapping("/courses/{courseId}/enroll")
    public String enroll(@PathVariable Integer courseId, @AuthenticationPrincipal CustomUserDetails user,
                         RedirectAttributes flash) {
        if (user == null) {
            return "redirect:/login?courseId=" + courseId;
        }
        try {
            service.enroll(courseId, user.getUserId());
            flash.addFlashAttribute("success", "Ghi danh thành công.");
        } catch (Exception ex) {
            // Khóa học đã ghi danh hoặc có trạng thái đặc biệt -> tiếp tục vào học
        }
        return "redirect:/courses/" + courseId + "/learn";
    }

    // Nếu ai đó truy cập URL GET /courses/{courseId}/enroll → chuyển hướng về trang chi tiết khóa học
    @GetMapping("/courses/{courseId}/enroll")
    public String enrollRedirect(@PathVariable Integer courseId, @AuthenticationPrincipal CustomUserDetails user) {
        return "redirect:/courses/" + courseId;
    }

    @GetMapping("/instructor/courses")
    public String instructorCourses(@RequestParam(value = "q", required = false) String q,
                                    @AuthenticationPrincipal CustomUserDetails user, Model model) {
        model.addAttribute("courses", service.instructorCourses(user.getUserId(), q));
        model.addAttribute("q", q);
        return "courses/instructor-list";
    }

    @GetMapping("/instructor/dashboard")
    public String instructorDashboard(@AuthenticationPrincipal CustomUserDetails user, Model model) {
        InstructorDashboardStats stats = service.instructorDashboard(user.getUserId());
        if (revenueService != null) {
            var rev = revenueService.getInstructorRevenue(user.getUserId(), null);
            stats.setGrossRevenue(rev.getGrossRevenue());
            stats.setNetEarnings(rev.getNetEarnings());
            stats.setAvailableBalance(rev.getAvailableBalance());
            stats.setPaidOrdersCount(rev.getPaidOrdersCount());
        }
        model.addAttribute("stats", stats);
        return "courses/instructor-dashboard";
    }

    @GetMapping("/instructor/courses/new")
    public String newCourse(Model model) {
        model.addAttribute("courseForm", new CourseForm());
        model.addAttribute("categories", service.activeCategories());
        model.addAttribute("formAction", "/instructor/courses");
        return "courses/form";
    }

    @PostMapping("/instructor/courses")
    public String create(@Valid @ModelAttribute("courseForm") CourseForm form, BindingResult errors,
                         @AuthenticationPrincipal CustomUserDetails user, Model model, RedirectAttributes flash) {
        if (errors.hasErrors()) {
            model.addAttribute("categories", service.activeCategories());
            model.addAttribute("formAction", "/instructor/courses");
            return "courses/form";
        }
        Integer id = service.create(user.getUserId(), form);
        flash.addFlashAttribute("success", "Đã khởi tạo khóa học. Tiếp tục thiết lập chương mục và bài học!");
        return "redirect:/instructor/courses/" + id;
    }

    @GetMapping("/instructor/courses/{id}")
    public String instructorDetail(@PathVariable Integer id, @AuthenticationPrincipal CustomUserDetails user, Model model) {
        model.addAttribute("course", service.instructorCourse(id, user.getUserId()));
        model.addAttribute("lessons", service.courseLessons(id, user.getUserId()));
        return "courses/instructor-detail";
    }

    @GetMapping("/instructor/courses/{id}/preview")
    public String previewAsStudent(@PathVariable Integer id,
                                   @RequestParam(required = false) Integer lessonId,
                                   @AuthenticationPrincipal CustomUserDetails user,
                                   Model model) {
        if (learningService != null) {
            var studyContext = learningService.getStudyContextForPreview(id, lessonId, user.getUserId());
            model.addAttribute("study", studyContext);
            model.addAttribute("studyContext", studyContext);
            return "courses/study";
        }
        return "redirect:/instructor/courses/" + id;
    }

    @GetMapping("/instructor/courses/{id}/preview/lessons/{lessonId}")
    public String previewLessonAsStudent(@PathVariable Integer id,
                                         @PathVariable Integer lessonId,
                                         @AuthenticationPrincipal CustomUserDetails user,
                                         Model model) {
        return previewAsStudent(id, lessonId, user, model);
    }

    @GetMapping("/instructor/courses/{id}/edit")
    public String editForm(@PathVariable Integer id, @AuthenticationPrincipal CustomUserDetails user, Model model) {
        model.addAttribute("course", service.instructorCourse(id, user.getUserId()));
        model.addAttribute("courseForm", service.editForm(id, user.getUserId()));
        model.addAttribute("categories", service.activeCategories());
        model.addAttribute("formAction", "/instructor/courses/" + id);
        return "courses/form";
    }

    @PostMapping("/instructor/courses/{id}")
    public String edit(@PathVariable Integer id, @Valid @ModelAttribute("courseForm") CourseForm form,
                       BindingResult errors, @AuthenticationPrincipal CustomUserDetails user,
                       Model model, RedirectAttributes flash) {
        if (errors.hasErrors()) {
            model.addAttribute("course", service.instructorCourse(id, user.getUserId()));
            model.addAttribute("categories", service.activeCategories());
            model.addAttribute("formAction", "/instructor/courses/" + id);
            return "courses/form";
        }
        service.edit(id, user.getUserId(), form);
        flash.addFlashAttribute("success", "Đã lưu thay đổi. Khóa học được nâng phiên bản và chuyển về Bản nháp.");
        return "redirect:/instructor/courses/" + id;
    }

    @PostMapping("/instructor/courses/{id}/submit")
    public String submit(@PathVariable Integer id,
                         @RequestParam(required = false) String changeNote,
                         @AuthenticationPrincipal CustomUserDetails user, RedirectAttributes flash) {
        service.submitWithNote(id, user.getUserId(), changeNote);
        flash.addFlashAttribute("success", "Đã gửi khóa học để duyệt.");
        return "redirect:/instructor/courses/" + id;
    }

    @PostMapping("/instructor/courses/{id}/publish")
    public String publish(@PathVariable Integer id, @AuthenticationPrincipal CustomUserDetails user, RedirectAttributes flash) {
        service.publish(id, user.getUserId());
        flash.addFlashAttribute("success", "Đã công bố khóa học.");
        return "redirect:/instructor/courses/" + id;
    }

    @PostMapping("/instructor/courses/{id}/republish")
    public String republish(@PathVariable Integer id, @AuthenticationPrincipal CustomUserDetails user, RedirectAttributes flash) {
        service.republish(id, user.getUserId());
        flash.addFlashAttribute("success", "Đã tái công bố nội dung mới. Học viên có thể xem bài học vừa cập nhật.");
        return "redirect:/instructor/courses/" + id;
    }

    @PostMapping({"/instructor/courses/{id}/hide", "/instructor/courses/{id}/unpublish"})
    public String hide(@PathVariable Integer id, @AuthenticationPrincipal CustomUserDetails user, RedirectAttributes flash) {
        service.hide(id, user.getUserId());
        flash.addFlashAttribute("success", "Đã ẩn khóa học khỏi danh sách công khai.");
        return "redirect:/instructor/courses/" + id;
    }

    @PostMapping("/instructor/courses/{id}/archive")
    public String archive(@PathVariable Integer id, @AuthenticationPrincipal CustomUserDetails user, RedirectAttributes flash) {
        service.archive(id, user.getUserId());
        flash.addFlashAttribute("success", "Đã lưu trữ khóa học.");
        return "redirect:/instructor/courses/" + id;
    }

    @GetMapping("/admin/courses/review")
    public String pending(Model model) {
        model.addAttribute("courses", service.pendingCourses());
        return "admin/course-review";
    }

    @GetMapping("/admin/courses/{id}/review")
    public String reviewDetail(@PathVariable Integer id, Model model) {
        model.addAttribute("course", service.adminCourseDetail(id));
        return "admin/course-review-detail";
    }

    @PostMapping("/admin/courses/{id}/review")
    public String review(@PathVariable Integer id, @RequestParam String decision,
                         @RequestParam(required = false) String comment,
                         @AuthenticationPrincipal CustomUserDetails user, RedirectAttributes flash) {
        service.review(id, user.getUserId(), decision, comment);
        flash.addFlashAttribute("success", "APPROVED".equals(decision) ? "Đã phê duyệt khóa học." : "Đã từ chối khóa học.");
        return "redirect:/admin/courses/review";
    }

    @ExceptionHandler(CourseActionException.class)
    public String courseError(CourseActionException ex, HttpServletResponse response, Model model) {
        response.setStatus(ex.getStatus().value());
        model.addAttribute("errorMessage", ex.getMessage());
        return "courses/action-error";
    }
}
