package com.edusphere.service.course;

import com.edusphere.dto.planning.HistoryItemView;
import com.edusphere.dto.planning.ProgressSummaryView;
import com.edusphere.dto.planning.StudentProgressView;
import com.edusphere.entity.account.Users;
import com.edusphere.entity.course.Assignment;
import com.edusphere.entity.course.Course;
import com.edusphere.entity.course.Enrollment;
import com.edusphere.entity.course.LearningHistory;
import com.edusphere.entity.course.LearningProgress;
import com.edusphere.entity.course.Lesson;
import com.edusphere.entity.course.Quiz;
import com.edusphere.repository.account.UserRepository;
import com.edusphere.repository.course.AssignmentRepository;
import com.edusphere.repository.course.CourseRepository;
import com.edusphere.repository.course.EnrollmentRepository;
import com.edusphere.repository.course.LearningHistoryRepository;
import com.edusphere.repository.course.LearningProgressRepository;
import com.edusphere.repository.course.LessonCompletionRepository;
import com.edusphere.repository.course.LessonRepository;
import com.edusphere.repository.course.QuizRepository;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
public class LearningProgressService {

    private static final String PUBLISHED = "PUBLISHED";

    private final LearningProgressRepository progressRepository;
    private final LearningHistoryRepository historyRepository;
    private final EnrollmentRepository enrollmentRepository;
    private final CourseRepository courseRepository;
    private final LessonRepository lessonRepository;
    private final LessonCompletionRepository completionRepository;
    private final AssignmentRepository assignmentRepository;
    private final QuizRepository quizRepository;
    private final UserRepository userRepository;

    public LearningProgressService(LearningProgressRepository progressRepository,
                                   LearningHistoryRepository historyRepository,
                                   EnrollmentRepository enrollmentRepository,
                                   CourseRepository courseRepository,
                                   LessonRepository lessonRepository,
                                   LessonCompletionRepository completionRepository,
                                   AssignmentRepository assignmentRepository,
                                   QuizRepository quizRepository,
                                   UserRepository userRepository) {
        this.progressRepository = progressRepository;
        this.historyRepository = historyRepository;
        this.enrollmentRepository = enrollmentRepository;
        this.courseRepository = courseRepository;
        this.lessonRepository = lessonRepository;
        this.completionRepository = completionRepository;
        this.assignmentRepository = assignmentRepository;
        this.quizRepository = quizRepository;
        this.userRepository = userRepository;
    }

    // ==========================================
    // UC37: Track Learning Progress (Student)
    // ==========================================

    @Transactional(readOnly = true)
    public List<ProgressSummaryView> getMyProgress(Integer studentId) {
        List<Enrollment> enrollments = enrollmentRepository.findByStudent_UserIdOrderByEnrolledAtDesc(studentId);
        List<ProgressSummaryView> result = new ArrayList<>();

        for (Enrollment enrollment : enrollments) {
            Course course = enrollment.getCourse();
            Integer courseId = course.getCourseId();

            Optional<LearningProgress> optProgress = progressRepository.findByStudent_UserIdAndCourse_CourseId(studentId, courseId);
            BigDecimal percent;
            int completed;
            int total;
            LocalDateTime lastAccess;

            if (optProgress.isPresent()) {
                LearningProgress p = optProgress.get();
                percent = p.getPercentComplete();
                completed = p.getCompletedLessons();
                total = p.getTotalLessons();
                lastAccess = p.getLastAccessedAt();
            } else {
                total = (int) lessonRepository.countByCourse_CourseIdAndStatus(courseId, PUBLISHED);
                completed = (int) completionRepository.countByStudent_UserIdAndCourse_CourseId(studentId, courseId);
                percent = total > 0
                        ? BigDecimal.valueOf((double) completed * 100.0 / total).setScale(2, RoundingMode.HALF_UP)
                        : BigDecimal.ZERO;
                lastAccess = null;
            }

            result.add(ProgressSummaryView.builder()
                    .courseId(courseId)
                    .courseTitle(course.getTitle())
                    .categoryName(course.getCategory() != null ? course.getCategory().getName() : "Chung")
                    .instructorName(course.getInstructor().getFullName())
                    .enrollmentStatus(enrollment.getStatus())
                    .percentComplete(percent)
                    .completedLessons(completed)
                    .totalLessons(total)
                    .lastAccessedAt(lastAccess)
                    .enrolledAt(enrollment.getEnrolledAt())
                    .completedAt(enrollment.getCompletedAt())
                    .build());
        }

        return result;
    }

    @Transactional(readOnly = true)
    public ProgressSummaryView getCourseProgress(Integer courseId, Integer studentId) {
        Enrollment enrollment = enrollmentRepository.findByStudent_UserIdAndCourse_CourseId(studentId, courseId)
                .orElseThrow(() -> new CourseActionException(HttpStatus.FORBIDDEN, "Bạn chưa ghi danh khóa học này."));

        Course course = enrollment.getCourse();
        Optional<LearningProgress> optProgress = progressRepository.findByStudent_UserIdAndCourse_CourseId(studentId, courseId);

        BigDecimal percent;
        int completed;
        int total;
        LocalDateTime lastAccess;

        if (optProgress.isPresent()) {
            LearningProgress p = optProgress.get();
            percent = p.getPercentComplete();
            completed = p.getCompletedLessons();
            total = p.getTotalLessons();
            lastAccess = p.getLastAccessedAt();
        } else {
            total = (int) lessonRepository.countByCourse_CourseIdAndStatus(courseId, PUBLISHED);
            completed = (int) completionRepository.countByStudent_UserIdAndCourse_CourseId(studentId, courseId);
            percent = total > 0
                    ? BigDecimal.valueOf((double) completed * 100.0 / total).setScale(2, RoundingMode.HALF_UP)
                    : BigDecimal.ZERO;
            lastAccess = null;
        }

        return ProgressSummaryView.builder()
                .courseId(courseId)
                .courseTitle(course.getTitle())
                .categoryName(course.getCategory() != null ? course.getCategory().getName() : "Chung")
                .instructorName(course.getInstructor().getFullName())
                .enrollmentStatus(enrollment.getStatus())
                .percentComplete(percent)
                .completedLessons(completed)
                .totalLessons(total)
                .lastAccessedAt(lastAccess)
                .enrolledAt(enrollment.getEnrolledAt())
                .completedAt(enrollment.getCompletedAt())
                .build();
    }

    /**
     * Cập nhật tiến độ học tập (upsert) và ghi lại lịch sử khi học viên hoàn thành bài học.
     */
    @Transactional
    public void updateProgressOnLessonCompleted(Integer studentId, Integer courseId, Integer lessonId) {
        Users student = userRepository.findById(studentId)
                .orElseThrow(() -> new CourseActionException(HttpStatus.UNAUTHORIZED, "Người dùng không tồn tại."));
        Course course = courseRepository.findById(courseId)
                .orElseThrow(() -> new CourseActionException(HttpStatus.NOT_FOUND, "Khóa học không tồn tại."));
        Lesson lesson = lessonRepository.findById(lessonId).orElse(null);

        int total = (int) lessonRepository.countByCourse_CourseIdAndStatus(courseId, PUBLISHED);
        int completed = (int) completionRepository.countByStudent_UserIdAndCourse_CourseId(studentId, courseId);
        BigDecimal percent = total > 0
                ? BigDecimal.valueOf((double) completed * 100.0 / total).setScale(2, RoundingMode.HALF_UP)
                : BigDecimal.ZERO;

        LearningProgress progress = progressRepository.findByStudent_UserIdAndCourse_CourseId(studentId, courseId)
                .orElseGet(() -> {
                    LearningProgress p = new LearningProgress();
                    p.setStudent(student);
                    p.setCourse(course);
                    return p;
                });

        progress.setCompletedLessons(completed);
        progress.setTotalLessons(total);
        progress.setPercentComplete(percent);
        progress.setLastAccessedAt(LocalDateTime.now());
        progressRepository.save(progress);

        // Ghi lại lịch sử LESSON_COMPLETED
        String detailText = lesson != null ? "Hoàn thành bài: " + lesson.getTitle() : "Hoàn thành bài học";
        recordActivity(student, course, "LESSON_COMPLETED", lesson, null, null, detailText);
    }

    /**
     * Cập nhật last_accessed_at khi học viên học bài.
     */
    @Transactional
    public void recordAccess(Integer studentId, Integer courseId) {
        progressRepository.findByStudent_UserIdAndCourse_CourseId(studentId, courseId).ifPresent(p -> {
            p.setLastAccessedAt(LocalDateTime.now());
            progressRepository.save(p);
        });
    }

    // ==========================================
    // UC38: View Learning History (Student)
    // ==========================================

    @Transactional(readOnly = true)
    public Page<HistoryItemView> getHistory(Integer studentId, Pageable pageable) {
        Page<LearningHistory> page = historyRepository.findByStudent_UserIdOrderByOccurredAtDesc(studentId, pageable);
        return page.map(this::toHistoryItemView);
    }

    @Transactional(readOnly = true)
    public List<HistoryItemView> getCourseHistory(Integer studentId, Integer courseId) {
        return historyRepository.findByStudent_UserIdAndCourse_CourseIdOrderByOccurredAtDesc(studentId, courseId)
                .stream().map(this::toHistoryItemView).collect(Collectors.toList());
    }

    @Transactional
    public void recordActivity(Users student, Course course, String activityType,
                               Lesson lesson, Assignment assignment, Quiz quiz, String details) {
        LearningHistory history = new LearningHistory();
        history.setStudent(student);
        history.setCourse(course);
        history.setActivityType(activityType);
        history.setLesson(lesson);
        history.setAssignment(assignment);
        history.setQuiz(quiz);
        history.setDetails(details);
        history.setOccurredAt(LocalDateTime.now());
        historyRepository.save(history);
    }

    // ==========================================
    // UC39: View Student Progress (Instructor)
    // ==========================================

    @Transactional(readOnly = true)
    public List<StudentProgressView> getCourseStudentProgress(Integer courseId, Integer instructorId) {
        Course course = courseRepository.findById(courseId)
                .orElseThrow(() -> new CourseActionException(HttpStatus.NOT_FOUND, "Không tìm thấy khóa học."));

        if (!course.getInstructor().getUserId().equals(instructorId)) {
            throw new CourseActionException(HttpStatus.FORBIDDEN, "Bạn không có quyền quản lý khóa học này.");
        }

        List<Enrollment> enrollments = enrollmentRepository.findByCourse_CourseIdOrderByEnrolledAtDesc(courseId);
        List<LearningProgress> allProgress = progressRepository.findByCourse_CourseId(courseId);
        Map<Integer, LearningProgress> progressByStudentId = allProgress.stream()
                .collect(Collectors.toMap(p -> p.getStudent().getUserId(), p -> p, (p1, p2) -> p1));

        int totalPublishedLessons = (int) lessonRepository.countByCourse_CourseIdAndStatus(courseId, PUBLISHED);

        List<StudentProgressView> result = new ArrayList<>();
        for (Enrollment enrollment : enrollments) {
            Users student = enrollment.getStudent();
            LearningProgress p = progressByStudentId.get(student.getUserId());

            BigDecimal percent;
            int completed;
            int total = totalPublishedLessons;
            LocalDateTime lastAccess;

            if (p != null) {
                percent = p.getPercentComplete();
                completed = p.getCompletedLessons();
                total = p.getTotalLessons();
                lastAccess = p.getLastAccessedAt();
            } else {
                completed = (int) completionRepository.countByStudent_UserIdAndCourse_CourseId(student.getUserId(), courseId);
                percent = total > 0
                        ? BigDecimal.valueOf((double) completed * 100.0 / total).setScale(2, RoundingMode.HALF_UP)
                        : BigDecimal.ZERO;
                lastAccess = null;
            }

            result.add(StudentProgressView.builder()
                    .studentId(student.getUserId())
                    .fullName(student.getFullName())
                    .email(student.getEmail())
                    .avatarUrl(student.getAvatarUrl())
                    .enrollmentStatus(enrollment.getStatus())
                    .enrolledAt(enrollment.getEnrolledAt())
                    .completedAt(enrollment.getCompletedAt())
                    .percentComplete(percent)
                    .completedLessons(completed)
                    .totalLessons(total)
                    .lastAccessedAt(lastAccess)
                    .build());
        }

        return result;
    }

    private HistoryItemView toHistoryItemView(LearningHistory h) {
        return HistoryItemView.builder()
                .historyId(h.getHistoryId())
                .courseId(h.getCourse().getCourseId())
                .courseTitle(h.getCourse().getTitle())
                .activityType(h.getActivityType())
                .activityLabel(formatActivityType(h.getActivityType()))
                .lessonId(h.getLesson() != null ? h.getLesson().getLessonId() : null)
                .lessonTitle(h.getLesson() != null ? h.getLesson().getTitle() : null)
                .assignmentId(h.getAssignment() != null ? h.getAssignment().getAssignmentId() : null)
                .assignmentTitle(h.getAssignment() != null ? h.getAssignment().getTitle() : null)
                .quizId(h.getQuiz() != null ? h.getQuiz().getQuizId() : null)
                .quizTitle(h.getQuiz() != null ? h.getQuiz().getTitle() : null)
                .details(h.getDetails())
                .occurredAt(h.getOccurredAt())
                .build();
    }

    private String formatActivityType(String type) {
        if (type == null) return "Hoạt động";
        return switch (type) {
            case "LESSON_COMPLETED" -> "Hoàn thành bài học";
            case "ASSIGNMENT_SUBMITTED" -> "Nộp bài tập";
            case "QUIZ_SUBMITTED" -> "Làm bài kiểm tra";
            case "COURSE_ENROLLED" -> "Ghi danh khóa học";
            case "COURSE_COMPLETED" -> "Hoàn thành khóa học";
            default -> type;
        };
    }
}

