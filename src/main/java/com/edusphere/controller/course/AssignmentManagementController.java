package com.edusphere.controller.course;

import com.edusphere.dto.assignment.AssignmentForm;
import com.edusphere.dto.assignment.GradeForm;
import com.edusphere.entity.course.Assignment;
import com.edusphere.repository.course.LessonRepository;
import com.edusphere.security.CustomUserDetails;
import com.edusphere.service.course.AssignmentService;
import com.edusphere.service.course.CourseActionException;

import jakarta.servlet.http.HttpServletResponse;
import jakarta.validation.Valid;

import java.time.format.DateTimeFormatter;

import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

@Controller
@PreAuthorize("hasRole('INSTRUCTOR')")
@RequestMapping("/instructor/courses/{courseId}/assignments")
public class AssignmentManagementController {

    private static final DateTimeFormatter DT_FMT = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm");

    private final AssignmentService service;
    private final LessonRepository lessonRepository;

    public AssignmentManagementController(AssignmentService service, LessonRepository lessonRepository) {
        this.service = service;
        this.lessonRepository = lessonRepository;
    }

    @GetMapping
    public String list(@PathVariable Integer courseId,
                       @AuthenticationPrincipal CustomUserDetails user,
                       Model model) {
        model.addAttribute("assignments", service.listForCourse(courseId, user.getUserId()));
        model.addAttribute("courseId", courseId);
        return "assignments/instructor-list";
    }

    @GetMapping("/new")
    public String newForm(@PathVariable Integer courseId,
                          @RequestParam(required = false) Integer lessonId,
                          @AuthenticationPrincipal CustomUserDetails user,
                          Model model) {
        AssignmentForm form = new AssignmentForm();
        if (lessonId != null) {
            form.setLessonId(lessonId);
        }
        model.addAttribute("assignmentForm", form);
        model.addAttribute("courseId", courseId);
        model.addAttribute("pageTitle", "Tạo bài tập mới");
        model.addAttribute("formAction", "/instructor/courses/" + courseId + "/assignments");
        model.addAttribute("lessons", lessonRepository.findByCourse_CourseIdOrderByOrderIndexAsc(courseId));
        return "assignments/form";
    }

    @PostMapping
    public String create(@PathVariable Integer courseId,
                         @Valid @ModelAttribute("assignmentForm") AssignmentForm form,
                         BindingResult errors,
                         @AuthenticationPrincipal CustomUserDetails user,
                         Model model,
                         RedirectAttributes flash) {
        if (errors.hasErrors()) {
            model.addAttribute("courseId", courseId);
            model.addAttribute("pageTitle", "Tạo bài tập mới");
            model.addAttribute("formAction", "/instructor/courses/" + courseId + "/assignments");
            model.addAttribute("lessons", lessonRepository.findByCourse_CourseIdOrderByOrderIndexAsc(courseId));
            return "assignments/form";
        }
        try {
            service.create(courseId, user.getUserId(), form);
            flash.addFlashAttribute("success", "Đã tạo bài tập thành công.");
            return "redirect:/instructor/courses/" + courseId + "/assignments";
        } catch (CourseActionException e) {
            model.addAttribute("courseId", courseId);
            model.addAttribute("pageTitle", "Tạo bài tập mới");
            model.addAttribute("formAction", "/instructor/courses/" + courseId + "/assignments");
            model.addAttribute("lessons", lessonRepository.findByCourse_CourseIdOrderByOrderIndexAsc(courseId));
            model.addAttribute("error", e.getMessage());
            return "assignments/form";
        }
    }

    @GetMapping("/{assignmentId}/edit")
    public String editForm(@PathVariable Integer courseId,
                           @PathVariable Integer assignmentId,
                           @AuthenticationPrincipal CustomUserDetails user,
                           Model model) {
        Assignment a = service.getAssignmentForInstructor(courseId, assignmentId, user.getUserId());
        AssignmentForm form = new AssignmentForm();
        form.setTitle(a.getTitle());
        form.setDescription(a.getDescription());
        form.setMaxScore(a.getMaxScore());
        form.setAllowResubmit(a.isAllowResubmit());
        form.setMaxAttempts(a.getMaxAttempts());
        if (a.getDueDate() != null) {
            form.setDueDate(a.getDueDate().format(DT_FMT));
        }
        if (a.getUnlockAt() != null) {
            form.setUnlockAt(a.getUnlockAt().format(DT_FMT));
        }
        if (a.getLockAt() != null) {
            form.setLockAt(a.getLockAt().format(DT_FMT));
        }
        if (a.getLesson() != null) {
            form.setLessonId(a.getLesson().getLessonId());
        }

        model.addAttribute("assignmentForm", form);
        model.addAttribute("courseId", courseId);
        model.addAttribute("assignmentId", assignmentId);
        model.addAttribute("pageTitle", "Chỉnh sửa bài tập");
        model.addAttribute("formAction", "/instructor/courses/" + courseId + "/assignments/" + assignmentId);
        model.addAttribute("lessons", lessonRepository.findByCourse_CourseIdOrderByOrderIndexAsc(courseId));
        return "assignments/form";
    }

    @PostMapping(value = {"/{assignmentId}", "/{assignmentId}/edit"})
    public String update(@PathVariable Integer courseId,
                         @PathVariable Integer assignmentId,
                         @Valid @ModelAttribute("assignmentForm") AssignmentForm form,
                         BindingResult errors,
                         @AuthenticationPrincipal CustomUserDetails user,
                         Model model,
                         RedirectAttributes flash) {
        if (errors.hasErrors()) {
            model.addAttribute("courseId", courseId);
            model.addAttribute("assignmentId", assignmentId);
            model.addAttribute("pageTitle", "Chỉnh sửa bài tập");
            model.addAttribute("formAction", "/instructor/courses/" + courseId + "/assignments/" + assignmentId);
            model.addAttribute("lessons", lessonRepository.findByCourse_CourseIdOrderByOrderIndexAsc(courseId));
            return "assignments/form";
        }
        try {
            service.update(courseId, assignmentId, user.getUserId(), form);
            flash.addFlashAttribute("success", "Cập nhật bài tập thành công.");
            return "redirect:/instructor/courses/" + courseId + "/assignments";
        } catch (CourseActionException e) {
            model.addAttribute("courseId", courseId);
            model.addAttribute("assignmentId", assignmentId);
            model.addAttribute("pageTitle", "Chỉnh sửa bài tập");
            model.addAttribute("formAction", "/instructor/courses/" + courseId + "/assignments/" + assignmentId);
            model.addAttribute("lessons", lessonRepository.findByCourse_CourseIdOrderByOrderIndexAsc(courseId));
            model.addAttribute("error", e.getMessage());
            return "assignments/form";
        }
    }

    @PostMapping("/{assignmentId}/publish")
    public String publish(@PathVariable Integer courseId,
                          @PathVariable Integer assignmentId,
                          @AuthenticationPrincipal CustomUserDetails user,
                          RedirectAttributes flash) {
        service.publish(courseId, assignmentId, user.getUserId());
        flash.addFlashAttribute("success", "Đã công bố bài tập.");
        return "redirect:/instructor/courses/" + courseId + "/assignments";
    }

    @PostMapping("/{assignmentId}/archive")
    public String archive(@PathVariable Integer courseId,
                          @PathVariable Integer assignmentId,
                          @AuthenticationPrincipal CustomUserDetails user,
                          RedirectAttributes flash) {
        service.archive(courseId, assignmentId, user.getUserId());
        flash.addFlashAttribute("success", "Đã lưu trữ bài tập.");
        return "redirect:/instructor/courses/" + courseId + "/assignments";
    }

    @GetMapping("/{assignmentId}/submissions")
    public String submissions(@PathVariable Integer courseId,
                              @PathVariable Integer assignmentId,
                              @AuthenticationPrincipal CustomUserDetails user,
                              Model model) {
        model.addAttribute("assignment", service.getAssignmentForInstructor(courseId, assignmentId, user.getUserId()));
        model.addAttribute("submissions", service.listSubmissions(courseId, assignmentId, user.getUserId()));
        model.addAttribute("courseId", courseId);
        model.addAttribute("assignmentId", assignmentId);
        return "assignments/submissions";
    }

    @GetMapping("/{assignmentId}/submissions/{submissionId}/grade")
    public String gradeForm(@PathVariable Integer courseId,
                            @PathVariable Integer assignmentId,
                            @PathVariable Integer submissionId,
                            @AuthenticationPrincipal CustomUserDetails user,
                            Model model) {
        model.addAttribute("assignment", service.getAssignmentForInstructor(courseId, assignmentId, user.getUserId()));
        model.addAttribute("submission", service.getSubmission(courseId, assignmentId, submissionId, user.getUserId()));
        model.addAttribute("existingGrade", service.getGradeForSubmission(submissionId).orElse(null));
        model.addAttribute("courseId", courseId);
        model.addAttribute("assignmentId", assignmentId);
        return "assignments/grade-form";
    }

    @PostMapping("/{assignmentId}/submissions/{submissionId}/grade")
    public String grade(@PathVariable Integer courseId,
                        @PathVariable Integer assignmentId,
                        @PathVariable Integer submissionId,
                        @Valid @ModelAttribute("gradeForm") GradeForm form,
                        BindingResult errors,
                        @AuthenticationPrincipal CustomUserDetails user,
                        RedirectAttributes flash) {
        service.gradeSubmission(courseId, assignmentId, submissionId, user.getUserId(), form);
        flash.addFlashAttribute("success", "Đã lưu điểm bài tập.");
        return "redirect:/instructor/courses/" + courseId + "/assignments/" + assignmentId + "/submissions/" + submissionId + "/grade";
    }

    @PostMapping("/{assignmentId}/submissions/{submissionId}/publish-grade")
    public String publishGrade(@PathVariable Integer courseId,
                               @PathVariable Integer assignmentId,
                               @PathVariable Integer submissionId,
                               @AuthenticationPrincipal CustomUserDetails user,
                               RedirectAttributes flash) {
        service.publishGrade(courseId, assignmentId, submissionId, user.getUserId());
        flash.addFlashAttribute("success", "Đã công bố điểm cho học viên.");
        return "redirect:/instructor/courses/" + courseId + "/assignments/" + assignmentId + "/submissions/" + submissionId + "/grade";
    }

    @ExceptionHandler(CourseActionException.class)
    public String handleError(CourseActionException ex, HttpServletResponse response, Model model) {
        response.setStatus(ex.getStatus().value());
        model.addAttribute("errorMessage", ex.getMessage());
        return "courses/action-error";
    }
}
