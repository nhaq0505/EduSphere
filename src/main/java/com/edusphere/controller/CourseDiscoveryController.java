package com.edusphere.controller;

import com.edusphere.dto.CourseView;
import com.edusphere.service.CourseDiscoveryService;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.data.domain.Page;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestParam;

@Controller
public class CourseDiscoveryController {

    private final CourseDiscoveryService courseDiscoveryService;

    public CourseDiscoveryController(CourseDiscoveryService courseDiscoveryService) {
        this.courseDiscoveryService = courseDiscoveryService;
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

    @GetMapping("/courses/{courseId}")
    public String detail(@PathVariable Integer courseId, Model model, HttpServletResponse response) {
        return courseDiscoveryService.findPublishedCourse(courseId)
                .map(course -> {
                    model.addAttribute("course", course);
                    model.addAttribute("lessonTitles", courseDiscoveryService.publishedLessonTitles(courseId));
                    return "courses/detail";
                })
                .orElseGet(() -> {
                    response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                    return "courses/not-found";
                });
    }
}
