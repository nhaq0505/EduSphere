package com.edusphere.controller;

import com.edusphere.security.RoleLandingPage;
import com.edusphere.service.course.CourseDiscoveryService;

import org.springframework.security.core.Authentication;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

/**
 * Controller cho các trang chung: home, dashboard.
 * Giáo viên và Admin được redirect về trang riêng của họ thay vì xem trang chủ chung.
 */
@Controller
public class HomeController {

    private final CourseDiscoveryService courseDiscoveryService;

    public HomeController(CourseDiscoveryService courseDiscoveryService) {
        this.courseDiscoveryService = courseDiscoveryService;
    }

    @GetMapping("/")
    public String home(Authentication authentication, Model model) {
        // Nếu đã đăng nhập với vai trò INSTRUCTOR hoặc ADMINISTRATOR → redirect về trang riêng
        if (authentication != null && authentication.isAuthenticated()) {
            if (authentication.getAuthorities().contains(new SimpleGrantedAuthority("ROLE_INSTRUCTOR"))) {
                return "redirect:/instructor/dashboard";
            }
            if (authentication.getAuthorities().contains(new SimpleGrantedAuthority("ROLE_ADMINISTRATOR"))) {
                return "redirect:/admin/courses/review";
            }
        }
        // Student hoặc khách → trang chủ chung
        model.addAttribute("featuredCourses", courseDiscoveryService.featuredCourses(8));
        model.addAttribute("categories", courseDiscoveryService.activeCategories());
        return "index";
    }

    @GetMapping("/dashboard")
    public String dashboard(Authentication authentication) {
        if (authentication != null && authentication.isAuthenticated()) {
            if (authentication.getAuthorities().contains(new SimpleGrantedAuthority("ROLE_STUDENT"))) {
                return "redirect:/student/dashboard";
            }
            return "redirect:" + RoleLandingPage.forUser(authentication);
        }
        return "redirect:/login";
    }
}
