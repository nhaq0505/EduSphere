package com.edusphere.service.course;

import com.edusphere.dto.planning.CalendarDayView;
import com.edusphere.dto.planning.PersonalTaskForm;
import com.edusphere.dto.planning.PersonalTaskView;
import com.edusphere.dto.planning.StudyPlanForm;
import com.edusphere.dto.planning.StudyPlanView;
import com.edusphere.entity.account.Users;
import com.edusphere.entity.course.Assignment;
import com.edusphere.entity.course.Course;
import com.edusphere.entity.course.Lesson;
import com.edusphere.entity.course.PersonalTask;
import com.edusphere.entity.course.Quiz;
import com.edusphere.entity.course.StudyPlan;
import com.edusphere.repository.account.UserRepository;
import com.edusphere.repository.course.AssignmentRepository;
import com.edusphere.repository.course.CourseRepository;
import com.edusphere.repository.course.EnrollmentRepository;
import com.edusphere.repository.course.LessonRepository;
import com.edusphere.repository.course.PersonalTaskRepository;
import com.edusphere.repository.course.QuizRepository;
import com.edusphere.repository.course.StudyPlanRepository;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
public class StudyPlanService {

    private final StudyPlanRepository studyPlanRepository;
    private final PersonalTaskRepository personalTaskRepository;
    private final UserRepository userRepository;
    private final EnrollmentRepository enrollmentRepository;
    private final CourseRepository courseRepository;
    private final LessonRepository lessonRepository;
    private final AssignmentRepository assignmentRepository;
    private final QuizRepository quizRepository;

    public StudyPlanService(StudyPlanRepository studyPlanRepository,
                            PersonalTaskRepository personalTaskRepository,
                            UserRepository userRepository,
                            EnrollmentRepository enrollmentRepository,
                            CourseRepository courseRepository,
                            LessonRepository lessonRepository,
                            AssignmentRepository assignmentRepository,
                            QuizRepository quizRepository) {
        this.studyPlanRepository = studyPlanRepository;
        this.personalTaskRepository = personalTaskRepository;
        this.userRepository = userRepository;
        this.enrollmentRepository = enrollmentRepository;
        this.courseRepository = courseRepository;
        this.lessonRepository = lessonRepository;
        this.assignmentRepository = assignmentRepository;
        this.quizRepository = quizRepository;
    }

    // ==========================================
    // UC34: Create & Manage Study Plan
    // ==========================================

    @Transactional(readOnly = true)
    public List<StudyPlanView> getMyPlans(Integer studentId) {
        List<StudyPlan> plans = studyPlanRepository.findByStudent_UserIdOrderByCreatedAtDesc(studentId);
        return plans.stream().map(this::toStudyPlanView).collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public StudyPlanView getPlanView(Integer planId, Integer studentId) {
        StudyPlan plan = findOwnedPlan(planId, studentId);
        return toStudyPlanView(plan);
    }

    @Transactional(readOnly = true)
    public StudyPlan getPlanEntity(Integer planId, Integer studentId) {
        return findOwnedPlan(planId, studentId);
    }

    @Transactional
    public Integer createPlan(Integer studentId, StudyPlanForm form) {
        Users student = userRepository.findById(studentId)
                .orElseThrow(() -> new CourseActionException(HttpStatus.UNAUTHORIZED, "Người dùng không tồn tại."));

        LocalDate start = parseLocalDate(form.getStartDate(), "Ngày bắt đầu không hợp lệ.");
        LocalDate end = parseLocalDate(form.getEndDate(), "Ngày kết thúc không hợp lệ.");
        if (end.isBefore(start)) {
            throw new CourseActionException(HttpStatus.BAD_REQUEST, "Ngày kết thúc phải diễn ra sau hoặc cùng ngày bắt đầu.");
        }

        StudyPlan plan = new StudyPlan();
        plan.setStudent(student);
        plan.setTitle(form.getTitle().trim());
        plan.setDescription(form.getDescription() != null ? form.getDescription().trim() : null);
        plan.setStartDate(start);
        plan.setEndDate(end);
        plan.setTimezone(form.getTimezone() != null && !form.getTimezone().isBlank() ? form.getTimezone() : "Asia/Ho_Chi_Minh");
        plan.setStatus("ACTIVE");

        StudyPlan saved = studyPlanRepository.save(plan);
        return saved.getPlanId();
    }

    @Transactional
    public void updatePlan(Integer planId, Integer studentId, StudyPlanForm form) {
        StudyPlan plan = findOwnedPlan(planId, studentId);

        LocalDate start = parseLocalDate(form.getStartDate(), "Ngày bắt đầu không hợp lệ.");
        LocalDate end = parseLocalDate(form.getEndDate(), "Ngày kết thúc không hợp lệ.");
        if (end.isBefore(start)) {
            throw new CourseActionException(HttpStatus.BAD_REQUEST, "Ngày kết thúc phải diễn ra sau hoặc cùng ngày bắt đầu.");
        }

        plan.setTitle(form.getTitle().trim());
        plan.setDescription(form.getDescription() != null ? form.getDescription().trim() : null);
        plan.setStartDate(start);
        plan.setEndDate(end);
        if (form.getStatus() != null && List.of("ACTIVE", "COMPLETED", "CANCELLED").contains(form.getStatus())) {
            plan.setStatus(form.getStatus());
        }
        studyPlanRepository.save(plan);
    }

    @Transactional
    public void deletePlan(Integer planId, Integer studentId) {
        StudyPlan plan = findOwnedPlan(planId, studentId);
        personalTaskRepository.deleteByPlan_PlanId(planId);
        studyPlanRepository.delete(plan);
    }

    // ==========================================
    // UC35: Schedule Learning Task
    // ==========================================

    @Transactional(readOnly = true)
    public List<PersonalTaskView> getTasksForPlan(Integer planId, Integer studentId) {
        findOwnedPlan(planId, studentId); // ownership check
        return personalTaskRepository.findByPlan_PlanIdAndStudent_UserIdOrderByPlannedStartAtAsc(planId, studentId)
                .stream().map(this::toPersonalTaskView).collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public PersonalTaskView getTask(Integer taskId, Integer studentId) {
        PersonalTask task = findOwnedTask(taskId, studentId);
        return toPersonalTaskView(task);
    }

    @Transactional
    public void createTask(Integer planId, Integer studentId, PersonalTaskForm form) {
        StudyPlan plan = findOwnedPlan(planId, studentId);
        Users student = userRepository.findById(studentId)
                .orElseThrow(() -> new CourseActionException(HttpStatus.UNAUTHORIZED, "Người dùng không tồn tại."));

        LocalDateTime startAt = parseLocalDateTime(form.getPlannedStartAt(), "Thời điểm bắt đầu không hợp lệ.");
        LocalDateTime endAt = parseLocalDateTime(form.getPlannedEndAt(), "Thời điểm kết thúc không hợp lệ.");
        if (endAt.isBefore(startAt)) {
            throw new CourseActionException(HttpStatus.BAD_REQUEST, "Thời điểm kết thúc phải sau thời điểm bắt đầu.");
        }

        PersonalTask task = new PersonalTask();
        task.setPlan(plan);
        task.setStudent(student);
        task.setTitle(form.getTitle().trim());
        task.setNotes(form.getNotes() != null ? form.getNotes().trim() : null);
        task.setPlannedStartAt(startAt);
        task.setPlannedEndAt(endAt);
        task.setStatus("PENDING");

        // Link optional course/lesson/assignment/quiz
        // LƯU Ý: Tuyệt đối KHÔNG thay đổi dueDate / unlockAt / lockAt chính thức của khóa học/bài học/quiz/bài tập!
        linkRelatedEntities(task, studentId, form.getCourseId(), form.getRelatedLessonId(),
                form.getRelatedAssignmentId(), form.getRelatedQuizId());

        personalTaskRepository.save(task);
    }

    @Transactional
    public void updateTask(Integer taskId, Integer studentId, PersonalTaskForm form) {
        PersonalTask task = findOwnedTask(taskId, studentId);

        LocalDateTime startAt = parseLocalDateTime(form.getPlannedStartAt(), "Thời điểm bắt đầu không hợp lệ.");
        LocalDateTime endAt = parseLocalDateTime(form.getPlannedEndAt(), "Thời điểm kết thúc không hợp lệ.");
        if (endAt.isBefore(startAt)) {
            throw new CourseActionException(HttpStatus.BAD_REQUEST, "Thời điểm kết thúc phải sau thời điểm bắt đầu.");
        }

        task.setTitle(form.getTitle().trim());
        task.setNotes(form.getNotes() != null ? form.getNotes().trim() : null);
        task.setPlannedStartAt(startAt);
        task.setPlannedEndAt(endAt);

        if (form.getStatus() != null && List.of("PENDING", "DONE", "SKIPPED").contains(form.getStatus())) {
            task.setStatus(form.getStatus());
            if ("DONE".equals(form.getStatus()) && task.getCompletedAt() == null) {
                task.setCompletedAt(LocalDateTime.now());
            } else if (!"DONE".equals(form.getStatus())) {
                task.setCompletedAt(null);
            }
        }

        linkRelatedEntities(task, studentId, form.getCourseId(), form.getRelatedLessonId(),
                form.getRelatedAssignmentId(), form.getRelatedQuizId());

        personalTaskRepository.save(task);
    }

    @Transactional
    public void markTaskDone(Integer taskId, Integer studentId) {
        PersonalTask task = findOwnedTask(taskId, studentId);
        task.setStatus("DONE");
        task.setCompletedAt(LocalDateTime.now());
        personalTaskRepository.save(task);
    }

    @Transactional
    public void markTaskPending(Integer taskId, Integer studentId) {
        PersonalTask task = findOwnedTask(taskId, studentId);
        task.setStatus("PENDING");
        task.setCompletedAt(null);
        personalTaskRepository.save(task);
    }

    @Transactional
    public void deleteTask(Integer taskId, Integer studentId) {
        PersonalTask task = findOwnedTask(taskId, studentId);
        personalTaskRepository.delete(task);
    }

    // ==========================================
    // UC36: View Study Calendar
    // ==========================================

    @Transactional(readOnly = true)
    public List<CalendarDayView> getCalendarWeek(Integer studentId, LocalDate referenceDate) {
        if (referenceDate == null) {
            referenceDate = LocalDate.now();
        }

        LocalDate monday = referenceDate.with(DayOfWeek.MONDAY);
        LocalDate sunday = referenceDate.with(DayOfWeek.SUNDAY);

        LocalDateTime startOfWeek = monday.atStartOfDay();
        LocalDateTime endOfWeek = sunday.plusDays(1).atStartOfDay().minusNanos(1000);

        List<PersonalTask> tasks = personalTaskRepository
                .findByStudent_UserIdAndPlannedStartAtBetweenOrderByPlannedStartAtAsc(studentId, startOfWeek, endOfWeek);

        Map<LocalDate, List<PersonalTaskView>> tasksByDate = tasks.stream()
                .map(this::toPersonalTaskView)
                .collect(Collectors.groupingBy(t -> t.getPlannedStartAt().toLocalDate()));

        LocalDate today = LocalDate.now();
        List<CalendarDayView> weekDays = new ArrayList<>();
        for (int i = 0; i < 7; i++) {
            LocalDate date = monday.plusDays(i);
            String dayName = getVietnameseDayOfWeek(date.getDayOfWeek());
            List<PersonalTaskView> dayTasks = tasksByDate.getOrDefault(date, List.of());
            weekDays.add(new CalendarDayView(date, dayName, date.equals(today), dayTasks));
        }

        return weekDays;
    }

    // ==========================================
    // Helper Methods
    // ==========================================

    private StudyPlan findOwnedPlan(Integer planId, Integer studentId) {
        return studyPlanRepository.findByPlanIdAndStudent_UserId(planId, studentId)
                .orElseThrow(() -> new CourseActionException(HttpStatus.NOT_FOUND, "Không tìm thấy kế hoạch học tập."));
    }

    private PersonalTask findOwnedTask(Integer taskId, Integer studentId) {
        return personalTaskRepository.findByTaskIdAndStudent_UserId(taskId, studentId)
                .orElseThrow(() -> new CourseActionException(HttpStatus.NOT_FOUND, "Không tìm thấy nhiệm vụ."));
    }

    private void linkRelatedEntities(PersonalTask task, Integer studentId, Integer courseId,
                                     Integer lessonId, Integer assignmentId, Integer quizId) {
        if (courseId != null) {
            boolean isEnrolled = enrollmentRepository.findByStudent_UserIdAndCourse_CourseId(studentId, courseId).isPresent();
            if (!isEnrolled) {
                throw new CourseActionException(HttpStatus.FORBIDDEN, "Bạn chưa ghi danh khóa học này.");
            }
            Course course = courseRepository.findById(courseId)
                    .orElseThrow(() -> new CourseActionException(HttpStatus.NOT_FOUND, "Khóa học không tồn tại."));
            task.setCourse(course);

            if (lessonId != null) {
                Lesson lesson = lessonRepository.findById(lessonId)
                        .filter(l -> l.getCourse().getCourseId().equals(courseId))
                        .orElse(null);
                task.setRelatedLesson(lesson);
            } else {
                task.setRelatedLesson(null);
            }

            if (assignmentId != null) {
                Assignment assignment = assignmentRepository.findById(assignmentId)
                        .filter(a -> a.getCourse().getCourseId().equals(courseId))
                        .orElse(null);
                task.setRelatedAssignment(assignment);
            } else {
                task.setRelatedAssignment(null);
            }

            if (quizId != null) {
                Quiz quiz = quizRepository.findById(quizId)
                        .filter(q -> q.getCourse().getCourseId().equals(courseId))
                        .orElse(null);
                task.setRelatedQuiz(quiz);
            } else {
                task.setRelatedQuiz(null);
            }
        } else {
            task.setCourse(null);
            task.setRelatedLesson(null);
            task.setRelatedAssignment(null);
            task.setRelatedQuiz(null);
        }
    }

    private StudyPlanView toStudyPlanView(StudyPlan plan) {
        long totalTasks = personalTaskRepository.countByPlan_PlanId(plan.getPlanId());
        long doneTasks = personalTaskRepository.countByPlan_PlanIdAndStatus(plan.getPlanId(), "DONE");
        return new StudyPlanView(
                plan.getPlanId(),
                plan.getTitle(),
                plan.getDescription(),
                plan.getStartDate(),
                plan.getEndDate(),
                plan.getTimezone(),
                plan.getStatus(),
                plan.getCreatedAt(),
                totalTasks,
                doneTasks
        );
    }

    public PersonalTaskView toPersonalTaskView(PersonalTask task) {
        return PersonalTaskView.builder()
                .taskId(task.getTaskId())
                .planId(task.getPlan().getPlanId())
                .planTitle(task.getPlan().getTitle())
                .title(task.getTitle())
                .notes(task.getNotes())
                .courseId(task.getCourse() != null ? task.getCourse().getCourseId() : null)
                .courseTitle(task.getCourse() != null ? task.getCourse().getTitle() : null)
                .relatedLessonId(task.getRelatedLesson() != null ? task.getRelatedLesson().getLessonId() : null)
                .lessonTitle(task.getRelatedLesson() != null ? task.getRelatedLesson().getTitle() : null)
                .relatedAssignmentId(task.getRelatedAssignment() != null ? task.getRelatedAssignment().getAssignmentId() : null)
                .assignmentTitle(task.getRelatedAssignment() != null ? task.getRelatedAssignment().getTitle() : null)
                .relatedQuizId(task.getRelatedQuiz() != null ? task.getRelatedQuiz().getQuizId() : null)
                .quizTitle(task.getRelatedQuiz() != null ? task.getRelatedQuiz().getTitle() : null)
                .plannedStartAt(task.getPlannedStartAt())
                .plannedEndAt(task.getPlannedEndAt())
                .status(task.getStatus())
                .completedAt(task.getCompletedAt())
                .build();
    }

    private LocalDate parseLocalDate(String str, String errorMsg) {
        try {
            return LocalDate.parse(str.trim());
        } catch (Exception e) {
            throw new CourseActionException(HttpStatus.BAD_REQUEST, errorMsg);
        }
    }

    private LocalDateTime parseLocalDateTime(String str, String errorMsg) {
        try {
            return LocalDateTime.parse(str.trim());
        } catch (Exception e) {
            throw new CourseActionException(HttpStatus.BAD_REQUEST, errorMsg);
        }
    }

    private String getVietnameseDayOfWeek(DayOfWeek day) {
        return switch (day) {
            case MONDAY -> "Thứ Hai";
            case TUESDAY -> "Thứ Ba";
            case WEDNESDAY -> "Thứ Tư";
            case THURSDAY -> "Thứ Năm";
            case FRIDAY -> "Thứ Sáu";
            case SATURDAY -> "Thứ Bảy";
            case SUNDAY -> "Chủ Nhật";
        };
    }
}

