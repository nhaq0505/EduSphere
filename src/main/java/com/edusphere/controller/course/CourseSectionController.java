package com.edusphere.controller.course;

import com.edusphere.dto.course.SectionForm;
import com.edusphere.security.CustomUserDetails;
import com.edusphere.service.course.CourseActionException;
import com.edusphere.service.course.CourseSectionService;

import jakarta.servlet.http.HttpServletResponse;
import jakarta.validation.Valid;

import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

@Controller
@RequestMapping("/instructor/courses/{courseId}/sections")
@PreAuthorize("hasRole('INSTRUCTOR')")
public class CourseSectionController {

    private final CourseSectionService sectionService;

    public CourseSectionController(CourseSectionService sectionService) {
        this.sectionService = sectionService;
    }

    @PostMapping
    public String create(@PathVariable Integer courseId,
                         @Valid SectionForm form,
                         BindingResult errors,
                         @AuthenticationPrincipal CustomUserDetails user,
                         RedirectAttributes flash) {
        if (errors.hasErrors()) {
            flash.addFlashAttribute("error", errors.getAllErrors().get(0).getDefaultMessage());
            return "redirect:/instructor/courses/" + courseId;
        }
        sectionService.createSection(courseId, user.getUserId(), form);
        flash.addFlashAttribute("success", "Đã thêm chương mục mới.");
        return "redirect:/instructor/courses/" + courseId;
    }

    @PostMapping("/{sectionId}/edit")
    public String edit(@PathVariable Integer courseId,
                       @PathVariable Integer sectionId,
                       @Valid SectionForm form,
                       BindingResult errors,
                       @AuthenticationPrincipal CustomUserDetails user,
                       RedirectAttributes flash) {
        if (errors.hasErrors()) {
            flash.addFlashAttribute("error", errors.getAllErrors().get(0).getDefaultMessage());
            return "redirect:/instructor/courses/" + courseId;
        }
        sectionService.updateSection(courseId, sectionId, user.getUserId(), form);
        flash.addFlashAttribute("success", "Đã cập nhật chương mục.");
        return "redirect:/instructor/courses/" + courseId;
    }

    @PostMapping("/{sectionId}/delete")
    public String delete(@PathVariable Integer courseId,
                         @PathVariable Integer sectionId,
                         @AuthenticationPrincipal CustomUserDetails user,
                         RedirectAttributes flash) {
        sectionService.deleteSection(courseId, sectionId, user.getUserId());
        flash.addFlashAttribute("success", "Đã xóa chương mục. Các bài học bên trong được giữ lại ở mục chung.");
        return "redirect:/instructor/courses/" + courseId;
    }

    @PostMapping("/{sectionId}/move")
    public String move(@PathVariable Integer courseId,
                       @PathVariable Integer sectionId,
                       @RequestParam String direction,
                       @AuthenticationPrincipal CustomUserDetails user,
                       RedirectAttributes flash) {
        sectionService.moveSection(courseId, sectionId, user.getUserId(), direction);
        flash.addFlashAttribute("success", "Đã thay đổi thứ tự chương.");
        return "redirect:/instructor/courses/" + courseId;
    }

    @ExceptionHandler(CourseActionException.class)
    public String courseError(CourseActionException ex, HttpServletResponse response, Model model) {
        response.setStatus(ex.getStatus().value());
        model.addAttribute("errorMessage", ex.getMessage());
        return "courses/action-error";
    }
}

