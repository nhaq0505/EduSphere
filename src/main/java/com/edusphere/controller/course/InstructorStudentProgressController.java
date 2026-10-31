package com.edusphere.controller.course;

import com.edusphere.dto.planning.StudentProgressView;
import com.edusphere.entity.course.Course;
import com.edusphere.repository.course.CourseRepository;
import com.edusphere.security.CustomUserDetails;
import com.edusphere.service.course.CourseActionException;
import com.edusphere.service.course.LearningProgressService;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.http.HttpStatus;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.List;

@Controller
@PreAuthorize("hasRole('INSTRUCTOR')")
public class InstructorStudentProgressController {

    private final LearningProgressService learningProgressService;
    private final CourseRepository courseRepository;

    public InstructorStudentProgressController(LearningProgressService learningProgressService,
                                               CourseRepository courseRepository) {
        this.learningProgressService = learningProgressService;
        this.courseRepository = courseRepository;
    }

    @GetMapping("/instructor/courses/{courseId}/students")
    public String viewCourseStudentProgress(@PathVariable Integer courseId,
                                            @AuthenticationPrincipal CustomUserDetails user,
                                            Model model) {
        Course course = courseRepository.findById(courseId)
                .orElseThrow(() -> new CourseActionException(HttpStatus.NOT_FOUND, "Không tìm thấy khóa học."));

        if (!course.getInstructor().getUserId().equals(user.getUserId())) {
            throw new CourseActionException(HttpStatus.FORBIDDEN, "Bạn không có quyền quản lý khóa học này.");
        }

        List<StudentProgressView> students = learningProgressService.getCourseStudentProgress(courseId, user.getUserId());
        long completedCount = students.stream().filter(s -> "COMPLETED".equalsIgnoreCase(s.getEnrollmentStatus())).count();
        double avgProgress = students.isEmpty() ? 0 : students.stream()
                .mapToDouble(s -> s.getPercentComplete() != null ? s.getPercentComplete().doubleValue() : 0.0)
                .average().orElse(0.0);

        model.addAttribute("course", course);
        model.addAttribute("students", students);
        model.addAttribute("totalStudents", students.size());
        model.addAttribute("completedStudents", completedCount);
        model.addAttribute("avgProgress", BigDecimal.valueOf(avgProgress).setScale(1, RoundingMode.HALF_UP));

        return "planning/instructor-student-progress";
    }

    @ExceptionHandler(CourseActionException.class)
    public String handleCourseActionError(CourseActionException ex, HttpServletResponse response, Model model) {
        response.setStatus(ex.getStatus().value());
        model.addAttribute("errorMessage", ex.getMessage());
        return "courses/action-error";
    }
}

