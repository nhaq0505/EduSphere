package com.edusphere.controller.course;

import com.edusphere.dto.course.EnrolledCourseView;
import com.edusphere.dto.planning.CalendarDayView;
import com.edusphere.dto.planning.HistoryItemView;
import com.edusphere.dto.planning.PersonalTaskForm;
import com.edusphere.dto.planning.PersonalTaskView;
import com.edusphere.dto.planning.ProgressSummaryView;
import com.edusphere.dto.planning.StudyPlanForm;
import com.edusphere.dto.planning.StudyPlanView;
import com.edusphere.entity.course.Assignment;
import com.edusphere.entity.course.Lesson;
import com.edusphere.entity.course.PersonalTask;
import com.edusphere.entity.course.Quiz;
import com.edusphere.entity.course.StudyPlan;
import com.edusphere.repository.course.AssignmentRepository;
import com.edusphere.repository.course.LessonRepository;
import com.edusphere.repository.course.QuizRepository;
import com.edusphere.security.CustomUserDetails;
import com.edusphere.service.course.CourseActionException;
import com.edusphere.service.course.CourseManagementService;
import com.edusphere.service.course.LearningProgressService;
import com.edusphere.service.course.StudyPlanService;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.validation.Valid;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
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

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.List;

@Controller
@PreAuthorize("hasAnyRole('STUDENT', 'INSTRUCTOR', 'ADMINISTRATOR')")
@RequestMapping("/study")
public class StudyPlanController {

    private final StudyPlanService studyPlanService;
    private final LearningProgressService learningProgressService;
    private final CourseManagementService courseManagementService;
    private final LessonRepository lessonRepository;
    private final AssignmentRepository assignmentRepository;
    private final QuizRepository quizRepository;

    public StudyPlanController(StudyPlanService studyPlanService,
                               LearningProgressService learningProgressService,
                               CourseManagementService courseManagementService,
                               LessonRepository lessonRepository,
                               AssignmentRepository assignmentRepository,
                               QuizRepository quizRepository) {
        this.studyPlanService = studyPlanService;
        this.learningProgressService = learningProgressService;
        this.courseManagementService = courseManagementService;
        this.lessonRepository = lessonRepository;
        this.assignmentRepository = assignmentRepository;
        this.quizRepository = quizRepository;
    }

    // ==========================================
    // UC34: Study Plans
    // ==========================================

    @GetMapping("/plans")
    public String listPlans(@AuthenticationPrincipal CustomUserDetails user, Model model) {
        List<StudyPlanView> plans = studyPlanService.getMyPlans(user.getUserId());
        long activeCount = plans.stream().filter(p -> "ACTIVE".equalsIgnoreCase(p.getStatus())).count();
        model.addAttribute("plans", plans);
        model.addAttribute("activeCount", activeCount);
        return "planning/plan-list";
    }

    @GetMapping("/plans/new")
    public String newPlanForm(Model model) {
        StudyPlanForm form = new StudyPlanForm();
        form.setStartDate(LocalDate.now().toString());
        form.setEndDate(LocalDate.now().plusMonths(1).toString());
        model.addAttribute("planForm", form);
        model.addAttribute("isEdit", false);
        return "planning/plan-form";
    }

    @PostMapping("/plans")
    public String createPlan(@AuthenticationPrincipal CustomUserDetails user,
                             @Valid @ModelAttribute("planForm") StudyPlanForm form,
                             BindingResult binding,
                             RedirectAttributes flash,
                             Model model) {
        if (binding.hasErrors()) {
            model.addAttribute("isEdit", false);
            return "planning/plan-form";
        }
        try {
            Integer planId = studyPlanService.createPlan(user.getUserId(), form);
            flash.addFlashAttribute("success", "Tạo kế hoạch học tập thành công!");
            return "redirect:/study/plans/" + planId;
        } catch (CourseActionException e) {
            model.addAttribute("error", e.getMessage());
            model.addAttribute("isEdit", false);
            return "planning/plan-form";
        }
    }

    @GetMapping("/plans/{planId}")
    public String viewPlan(@PathVariable Integer planId,
                           @AuthenticationPrincipal CustomUserDetails user,
                           Model model) {
        StudyPlanView plan = studyPlanService.getPlanView(planId, user.getUserId());
        List<PersonalTaskView> tasks = studyPlanService.getTasksForPlan(planId, user.getUserId());
        model.addAttribute("plan", plan);
        model.addAttribute("tasks", tasks);
        return "planning/plan-detail";
    }

    @GetMapping("/plans/{planId}/edit")
    public String editPlanForm(@PathVariable Integer planId,
                               @AuthenticationPrincipal CustomUserDetails user,
                               Model model) {
        StudyPlan plan = studyPlanService.getPlanEntity(planId, user.getUserId());
        StudyPlanForm form = new StudyPlanForm();
        form.setTitle(plan.getTitle());
        form.setDescription(plan.getDescription());
        form.setStartDate(plan.getStartDate().toString());
        form.setEndDate(plan.getEndDate().toString());
        form.setTimezone(plan.getTimezone());
        form.setStatus(plan.getStatus());

        model.addAttribute("planForm", form);
        model.addAttribute("planId", planId);
        model.addAttribute("isEdit", true);
        return "planning/plan-form";
    }

    @PostMapping("/plans/{planId}/edit")
    public String updatePlan(@PathVariable Integer planId,
                             @AuthenticationPrincipal CustomUserDetails user,
                             @Valid @ModelAttribute("planForm") StudyPlanForm form,
                             BindingResult binding,
                             RedirectAttributes flash,
                             Model model) {
        if (binding.hasErrors()) {
            model.addAttribute("planId", planId);
            model.addAttribute("isEdit", true);
            return "planning/plan-form";
        }
        try {
            studyPlanService.updatePlan(planId, user.getUserId(), form);
            flash.addFlashAttribute("success", "Cập nhật kế hoạch học tập thành công!");
            return "redirect:/study/plans/" + planId;
        } catch (CourseActionException e) {
            model.addAttribute("error", e.getMessage());
            model.addAttribute("planId", planId);
            model.addAttribute("isEdit", true);
            return "planning/plan-form";
        }
    }

    @PostMapping("/plans/{planId}/delete")
    public String deletePlan(@PathVariable Integer planId,
                             @AuthenticationPrincipal CustomUserDetails user,
                             RedirectAttributes flash) {
        studyPlanService.deletePlan(planId, user.getUserId());
        flash.addFlashAttribute("success", "Đã xóa kế hoạch học tập.");
        return "redirect:/study/plans";
    }

    // ==========================================
    // UC35: Personal Tasks
    // ==========================================

    @GetMapping("/plans/{planId}/tasks/new")
    public String newTaskForm(@PathVariable Integer planId,
                              @RequestParam(required = false) Integer selectedCourseId,
                              @AuthenticationPrincipal CustomUserDetails user,
                              Model model) {
        StudyPlanView plan = studyPlanService.getPlanView(planId, user.getUserId());
        PersonalTaskForm form = new PersonalTaskForm();
        form.setPlannedStartAt(LocalDate.now().atTime(9, 0).format(DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm")));
        form.setPlannedEndAt(LocalDate.now().atTime(10, 30).format(DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm")));
        if (selectedCourseId != null) {
            form.setCourseId(selectedCourseId);
        }

        populateTaskFormModel(user.getUserId(), selectedCourseId, model);
        model.addAttribute("plan", plan);
        model.addAttribute("taskForm", form);
        model.addAttribute("isEdit", false);
        return "planning/task-form";
    }

    @PostMapping("/plans/{planId}/tasks/new")
    public String createTask(@PathVariable Integer planId,
                             @AuthenticationPrincipal CustomUserDetails user,
                             @Valid @ModelAttribute("taskForm") PersonalTaskForm form,
                             BindingResult binding,
                             RedirectAttributes flash,
                             Model model) {
        if (binding.hasErrors()) {
            StudyPlanView plan = studyPlanService.getPlanView(planId, user.getUserId());
            populateTaskFormModel(user.getUserId(), form.getCourseId(), model);
            model.addAttribute("plan", plan);
            model.addAttribute("isEdit", false);
            return "planning/task-form";
        }
        try {
            studyPlanService.createTask(planId, user.getUserId(), form);
            flash.addFlashAttribute("success", "Đã thêm nhiệm vụ học tập!");
            return "redirect:/study/plans/" + planId;
        } catch (CourseActionException e) {
            StudyPlanView plan = studyPlanService.getPlanView(planId, user.getUserId());
            populateTaskFormModel(user.getUserId(), form.getCourseId(), model);
            model.addAttribute("plan", plan);
            model.addAttribute("isEdit", false);
            model.addAttribute("error", e.getMessage());
            return "planning/task-form";
        }
    }

    @GetMapping("/plans/{planId}/tasks/{taskId}/edit")
    public String editTaskForm(@PathVariable Integer planId,
                               @PathVariable Integer taskId,
                               @RequestParam(required = false) Integer selectedCourseId,
                               @AuthenticationPrincipal CustomUserDetails user,
                               Model model) {
        StudyPlanView plan = studyPlanService.getPlanView(planId, user.getUserId());
        PersonalTaskView task = studyPlanService.getTask(taskId, user.getUserId());

        PersonalTaskForm form = new PersonalTaskForm();
        form.setTitle(task.getTitle());
        form.setNotes(task.getNotes());
        form.setCourseId(selectedCourseId != null ? selectedCourseId : task.getCourseId());
        form.setRelatedLessonId(task.getRelatedLessonId());
        form.setRelatedAssignmentId(task.getRelatedAssignmentId());
        form.setRelatedQuizId(task.getRelatedQuizId());
        form.setPlannedStartAt(task.getPlannedStartAt().format(DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm")));
        form.setPlannedEndAt(task.getPlannedEndAt().format(DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm")));
        form.setStatus(task.getStatus());

        populateTaskFormModel(user.getUserId(), form.getCourseId(), model);
        model.addAttribute("plan", plan);
        model.addAttribute("taskId", taskId);
        model.addAttribute("taskForm", form);
        model.addAttribute("isEdit", true);
        return "planning/task-form";
    }

    @PostMapping("/plans/{planId}/tasks/{taskId}/edit")
    public String updateTask(@PathVariable Integer planId,
                             @PathVariable Integer taskId,
                             @AuthenticationPrincipal CustomUserDetails user,
                             @Valid @ModelAttribute("taskForm") PersonalTaskForm form,
                             BindingResult binding,
                             RedirectAttributes flash,
                             Model model) {
        if (binding.hasErrors()) {
            StudyPlanView plan = studyPlanService.getPlanView(planId, user.getUserId());
            populateTaskFormModel(user.getUserId(), form.getCourseId(), model);
            model.addAttribute("plan", plan);
            model.addAttribute("taskId", taskId);
            model.addAttribute("isEdit", true);
            return "planning/task-form";
        }
        try {
            studyPlanService.updateTask(taskId, user.getUserId(), form);
            flash.addFlashAttribute("success", "Cập nhật nhiệm vụ thành công!");
            return "redirect:/study/plans/" + planId;
        } catch (CourseActionException e) {
            StudyPlanView plan = studyPlanService.getPlanView(planId, user.getUserId());
            populateTaskFormModel(user.getUserId(), form.getCourseId(), model);
            model.addAttribute("plan", plan);
            model.addAttribute("taskId", taskId);
            model.addAttribute("isEdit", true);
            model.addAttribute("error", e.getMessage());
            return "planning/task-form";
        }
    }

    @PostMapping("/plans/{planId}/tasks/{taskId}/done")
    public String markTaskDone(@PathVariable Integer planId,
                               @PathVariable Integer taskId,
                               @AuthenticationPrincipal CustomUserDetails user,
                               RedirectAttributes flash) {
        studyPlanService.markTaskDone(taskId, user.getUserId());
        flash.addFlashAttribute("success", "Đã đánh dấu hoàn thành nhiệm vụ!");
        return "redirect:/study/plans/" + planId;
    }

    @PostMapping("/plans/{planId}/tasks/{taskId}/reopen")
    public String reopenTask(@PathVariable Integer planId,
                             @PathVariable Integer taskId,
                             @AuthenticationPrincipal CustomUserDetails user,
                             RedirectAttributes flash) {
        studyPlanService.markTaskPending(taskId, user.getUserId());
        flash.addFlashAttribute("success", "Đã mở lại nhiệm vụ!");
        return "redirect:/study/plans/" + planId;
    }

    @PostMapping("/plans/{planId}/tasks/{taskId}/delete")
    public String deleteTask(@PathVariable Integer planId,
                             @PathVariable Integer taskId,
                             @AuthenticationPrincipal CustomUserDetails user,
                             RedirectAttributes flash) {
        studyPlanService.deleteTask(taskId, user.getUserId());
        flash.addFlashAttribute("success", "Đã xóa nhiệm vụ.");
        return "redirect:/study/plans/" + planId;
    }

    // ==========================================
    // UC36: Study Calendar
    // ==========================================

    @GetMapping("/calendar")
    public String viewCalendar(@RequestParam(required = false) String date,
                               @AuthenticationPrincipal CustomUserDetails user,
                               Model model) {
        LocalDate refDate;
        try {
            refDate = (date != null && !date.isBlank()) ? LocalDate.parse(date.trim()) : LocalDate.now();
        } catch (Exception e) {
            refDate = LocalDate.now();
        }

        List<CalendarDayView> week = studyPlanService.getCalendarWeek(user.getUserId(), refDate);
        LocalDate prevWeekDate = refDate.minusWeeks(1);
        LocalDate nextWeekDate = refDate.plusWeeks(1);

        model.addAttribute("week", week);
        model.addAttribute("currentDate", refDate);
        model.addAttribute("prevWeekDate", prevWeekDate);
        model.addAttribute("nextWeekDate", nextWeekDate);
        model.addAttribute("todayDate", LocalDate.now());
        return "planning/calendar";
    }

    // ==========================================
    // UC37: Track Learning Progress
    // ==========================================

    @GetMapping("/progress")
    public String viewProgress(@AuthenticationPrincipal CustomUserDetails user, Model model) {
        List<ProgressSummaryView> progressList = learningProgressService.getMyProgress(user.getUserId());
        long completedCourses = progressList.stream().filter(p -> "COMPLETED".equalsIgnoreCase(p.getEnrollmentStatus())).count();
        long activeCourses = progressList.stream().filter(p -> "ACTIVE".equalsIgnoreCase(p.getEnrollmentStatus())).count();

        model.addAttribute("progressList", progressList);
        model.addAttribute("totalCourses", progressList.size());
        model.addAttribute("completedCourses", completedCourses);
        model.addAttribute("activeCourses", activeCourses);
        return "planning/progress";
    }

    // ==========================================
    // UC38: View Learning History
    // ==========================================

    @GetMapping("/history")
    public String viewHistory(@RequestParam(defaultValue = "0") int page,
                              @AuthenticationPrincipal CustomUserDetails user,
                              Model model) {
        if (page < 0) page = 0;
        Page<HistoryItemView> historyPage = learningProgressService.getHistory(user.getUserId(), PageRequest.of(page, 20));

        model.addAttribute("historyPage", historyPage);
        model.addAttribute("currentPage", page);
        model.addAttribute("totalPages", historyPage.getTotalPages());
        return "planning/history";
    }

    // ==========================================
    // Helper Methods
    // ==========================================

    private void populateTaskFormModel(Integer studentId, Integer courseId, Model model) {
        List<EnrolledCourseView> enrolledCourses = courseManagementService.enrolledCourses(studentId);
        model.addAttribute("enrolledCourses", enrolledCourses);

        boolean isEnrolled = courseId != null && enrolledCourses.stream()
                .anyMatch(c -> courseId.equals(c.getCourseId()));

        if (isEnrolled) {
            List<Lesson> lessons = lessonRepository.findByCourse_CourseIdAndStatusOrderByOrderIndexAsc(courseId, "PUBLISHED");
            List<Assignment> assignments = assignmentRepository.findByCourse_CourseIdAndStatusOrderByDueDateAsc(courseId, "PUBLISHED");
            List<Quiz> quizzes = quizRepository.findByCourse_CourseIdAndStatus(courseId, "PUBLISHED");
            model.addAttribute("availableLessons", lessons);
            model.addAttribute("availableAssignments", assignments);
            model.addAttribute("availableQuizzes", quizzes);
        } else {
            model.addAttribute("availableLessons", List.of());
            model.addAttribute("availableAssignments", List.of());
            model.addAttribute("availableQuizzes", List.of());
        }
    }

    @ExceptionHandler(CourseActionException.class)
    public String handleCourseActionError(CourseActionException ex, HttpServletResponse response, Model model) {
        response.setStatus(ex.getStatus().value());
        model.addAttribute("errorMessage", ex.getMessage());
        return "courses/action-error";
    }
}

