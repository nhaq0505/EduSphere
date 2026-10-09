package com.edusphere.controller;

import com.edusphere.dto.CourseForm;
import com.edusphere.security.CustomUserDetails;
import com.edusphere.service.CourseActionException;
import com.edusphere.service.CourseManagementService;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.validation.Valid;
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

    public CourseManagementController(CourseManagementService service) {
        this.service = service;
    }

    @GetMapping("/my-courses")
    public String myCourses(@AuthenticationPrincipal CustomUserDetails user, Model model) {
        model.addAttribute("courses", service.enrolledCourses(user.getUserId()));
        return "courses/my-courses";
    }

    @PostMapping("/courses/{courseId}/enroll")
    public String enroll(@PathVariable Integer courseId, @AuthenticationPrincipal CustomUserDetails user,
                         RedirectAttributes flash) {
        service.enroll(courseId, user.getUserId());
        flash.addFlashAttribute("success", "Ghi danh thành công.");
        return "redirect:/my-courses";
    }

    @GetMapping("/instructor/courses")
    public String instructorCourses(@AuthenticationPrincipal CustomUserDetails user, Model model) {
        model.addAttribute("courses", service.instructorCourses(user.getUserId()));
        return "courses/instructor-list";
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
        flash.addFlashAttribute("success", "Đã tạo khóa học nháp.");
        return "redirect:/instructor/courses/" + id;
    }

    @GetMapping("/instructor/courses/{id}")
    public String instructorDetail(@PathVariable Integer id, @AuthenticationPrincipal CustomUserDetails user, Model model) {
        model.addAttribute("course", service.instructorCourse(id, user.getUserId()));
        return "courses/instructor-detail";
    }

    @GetMapping("/instructor/courses/{id}/edit")
    public String editForm(@PathVariable Integer id, @AuthenticationPrincipal CustomUserDetails user, Model model) {
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
            model.addAttribute("categories", service.activeCategories());
            model.addAttribute("formAction", "/instructor/courses/" + id);
            return "courses/form";
        }
        service.edit(id, user.getUserId(), form);
        flash.addFlashAttribute("success", "Đã lưu thay đổi.");
        return "redirect:/instructor/courses/" + id;
    }

    @PostMapping("/instructor/courses/{id}/submit")
    public String submit(@PathVariable Integer id, @AuthenticationPrincipal CustomUserDetails user, RedirectAttributes flash) {
        service.submit(id, user.getUserId());
        flash.addFlashAttribute("success", "Đã gửi khóa học để duyệt.");
        return "redirect:/instructor/courses/" + id;
    }

    @PostMapping("/instructor/courses/{id}/publish")
    public String publish(@PathVariable Integer id, @AuthenticationPrincipal CustomUserDetails user, RedirectAttributes flash) {
        service.publish(id, user.getUserId());
        flash.addFlashAttribute("success", "Đã công bố khóa học.");
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
        return "courses/admin-review";
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
