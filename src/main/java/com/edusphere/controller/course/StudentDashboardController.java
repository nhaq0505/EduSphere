package com.edusphere.controller.course;

import com.edusphere.dto.course.StudentDashboardView;
import com.edusphere.security.CustomUserDetails;
import com.edusphere.service.course.StudentDashboardService;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class StudentDashboardController {

    private final StudentDashboardService dashboardService;

    public StudentDashboardController(StudentDashboardService dashboardService) {
        this.dashboardService = dashboardService;
    }

    @GetMapping("/dashboard")
    public String dashboard(@AuthenticationPrincipal CustomUserDetails user, Model model) {
        if (user == null) {
            return "redirect:/login";
        }
        StudentDashboardView view = dashboardService.build(user.getUserId(), user.getFullName());
        model.addAttribute("dash", view);
        return "courses/dashboard";
    }
}
