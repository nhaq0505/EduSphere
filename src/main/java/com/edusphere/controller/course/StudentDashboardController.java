package com.edusphere.controller.course;

import com.edusphere.dto.course.StudentDashboardView;
import com.edusphere.security.CustomUserDetails;
import com.edusphere.service.course.StudentDashboardService;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
@PreAuthorize("hasAnyRole('STUDENT', 'INSTRUCTOR', 'ADMINISTRATOR')")
public class StudentDashboardController {

    private final StudentDashboardService studentDashboardService;

    public StudentDashboardController(StudentDashboardService studentDashboardService) {
        this.studentDashboardService = studentDashboardService;
    }

    @GetMapping("/student/dashboard")
    public String studentDashboard(@AuthenticationPrincipal CustomUserDetails user, Model model) {
        if (user == null) {
            return "redirect:/login";
        }
        StudentDashboardView dashboard = studentDashboardService.getDashboard(
                user.getUserId(),
                user.getFullName()
        );
        model.addAttribute("dashboard", dashboard);
        return "courses/student-dashboard";
    }
}
