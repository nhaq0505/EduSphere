package com.edusphere.service.course;

import com.edusphere.dto.assignment.AssignmentView;
import com.edusphere.dto.course.LessonItemView;
import com.edusphere.dto.course.MaterialView;
import com.edusphere.dto.course.StudyCourseView;
import com.edusphere.dto.quiz.QuizView;
import com.edusphere.entity.course.Assignment;
import com.edusphere.entity.course.Course;
import com.edusphere.entity.course.Enrollment;
import com.edusphere.entity.course.Lesson;
import com.edusphere.entity.course.LessonCompletion;
import com.edusphere.entity.course.Quiz;
import com.edusphere.entity.account.Users;
import com.edusphere.repository.course.AssignmentRepository;
import com.edusphere.repository.course.CourseRepository;
import com.edusphere.repository.course.EnrollmentRepository;
import com.edusphere.repository.course.LessonCompletionRepository;
import com.edusphere.repository.course.LessonRepository;
import com.edusphere.repository.course.MaterialRepository;
import com.edusphere.repository.course.QuizAttemptRepository;
import com.edusphere.repository.course.QuizRepository;
import com.edusphere.repository.course.SubmissionRepository;
import com.edusphere.repository.account.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.net.URI;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Objects;
import java.util.Set;
import java.util.stream.Collectors;

@Service
public class LearningService {

    private static final String PUBLISHED = "PUBLISHED";

    private final LessonRepository lessonRepository;
    private final EnrollmentRepository enrollmentRepository;
    private final LessonCompletionRepository lessonCompletionRepository;
    private final MaterialRepository materialRepository;
    private final UserRepository userRepository;
    private final LearningProgressService learningProgressService;
    private final CourseRepository courseRepository;
    private final AssignmentRepository assignmentRepository;
    private final SubmissionRepository submissionRepository;
    private final QuizRepository quizRepository;
    private final QuizAttemptRepository quizAttemptRepository;

    public LearningService(LessonRepository lessonRepository,
                           EnrollmentRepository enrollmentRepository,
                           LessonCompletionRepository lessonCompletionRepository,
                           MaterialRepository materialRepository,
                           UserRepository userRepository) {
        this(lessonRepository, enrollmentRepository, lessonCompletionRepository, materialRepository, userRepository, null, null);
    }

    public LearningService(LessonRepository lessonRepository,
                           EnrollmentRepository enrollmentRepository,
                           LessonCompletionRepository lessonCompletionRepository,
                           MaterialRepository materialRepository,
                           UserRepository userRepository,
                           LearningProgressService learningProgressService) {
        this(lessonRepository, enrollmentRepository, lessonCompletionRepository, materialRepository, userRepository, learningProgressService, null);
    }

    // Constructor 7-arg — không dùng @Autowired, delegate sang constructor chính
    public LearningService(LessonRepository lessonRepository,
                           EnrollmentRepository enrollmentRepository,
                           LessonCompletionRepository lessonCompletionRepository,
                           MaterialRepository materialRepository,
                           UserRepository userRepository,
                           LearningProgressService learningProgressService,
                           CourseRepository courseRepository) {
        this(lessonRepository, enrollmentRepository, lessonCompletionRepository, materialRepository,
                userRepository, learningProgressService, courseRepository, null, null, null, null);
    }

    // Constructor chính — Spring dùng cái này để autowire
    @Autowired
    public LearningService(LessonRepository lessonRepository,
                           EnrollmentRepository enrollmentRepository,
                           LessonCompletionRepository lessonCompletionRepository,
                           MaterialRepository materialRepository,
                           UserRepository userRepository,
                           LearningProgressService learningProgressService,
                           CourseRepository courseRepository,
                           AssignmentRepository assignmentRepository,
                           SubmissionRepository submissionRepository,
                           QuizRepository quizRepository,
                           QuizAttemptRepository quizAttemptRepository) {
        this.lessonRepository = lessonRepository;
        this.enrollmentRepository = enrollmentRepository;
        this.lessonCompletionRepository = lessonCompletionRepository;
        this.materialRepository = materialRepository;
        this.userRepository = userRepository;
        this.learningProgressService = learningProgressService;
        this.courseRepository = courseRepository;
        this.assignmentRepository = assignmentRepository;
        this.submissionRepository = submissionRepository;
        this.quizRepository = quizRepository;
        this.quizAttemptRepository = quizAttemptRepository;
    }

    @Transactional
    public StudyCourseView getStudyContext(Integer courseId, Integer lessonId, Integer studentId) {
        Enrollment enrollment = verifyEnrollment(studentId, courseId);
        Course course = enrollment.getCourse();

        // Ghi nhận thời điểm truy cập khóa học gần nhất
        if (learningProgressService != null) {
            learningProgressService.recordAccess(studentId, courseId);
        }

        List<Lesson> publishedLessons = lessonRepository.findByCourse_CourseIdAndStatusOrderByOrderIndexAsc(courseId, PUBLISHED);
        if (publishedLessons.isEmpty()) {
            return new StudyCourseView(courseId, course.getTitle(), course.getInstructor().getFullName(),
                    Collections.emptyList(), null, null, Collections.emptyList(), null, null, 0, 0, 0,
                    "ARTICLE", null, null, true, false);
        }

        Set<Integer> completedLessonIds = lessonCompletionRepository.findByStudent_UserIdAndCourse_CourseId(studentId, courseId)
                .stream().map(c -> c.getLesson().getLessonId()).collect(Collectors.toSet());

        Lesson current;
        if (lessonId != null) {
            current = publishedLessons.stream()
                    .filter(l -> Objects.equals(l.getLessonId(), lessonId))
                    .findFirst()
                    .orElseThrow(() -> new CourseActionException(HttpStatus.NOT_FOUND, "Không tìm thấy bài học trong khóa học này."));
        } else {
            // Mặc định bài chưa hoàn thành đầu tiên, nếu đã hoàn thành hết thì mở bài đầu tiên
            current = publishedLessons.stream()
                    .filter(l -> !completedLessonIds.contains(l.getLessonId()))
                    .findFirst()
                    .orElse(publishedLessons.get(0));
        }

        int currentIndex = publishedLessons.indexOf(current);
        Integer prevLessonId = currentIndex > 0 ? publishedLessons.get(currentIndex - 1).getLessonId() : null;
        Integer nextLessonId = currentIndex < publishedLessons.size() - 1 ? publishedLessons.get(currentIndex + 1).getLessonId() : null;

        List<LessonItemView> lessonItemViews = new ArrayList<>();
        LessonItemView currentLessonView = null;
        for (Lesson l : publishedLessons) {
            boolean isCur = Objects.equals(l.getLessonId(), current.getLessonId());
            boolean isComp = completedLessonIds.contains(l.getLessonId());
            String sTitle = l.getSection() != null ? l.getSection().getTitle() : null;
            Integer sId = l.getSection() != null ? l.getSection().getSectionId() : null;
            LessonItemView itemView = new LessonItemView(l.getLessonId(), l.getTitle(), l.getOrderIndex(), isComp, isCur,
                    l.getLessonType() != null ? l.getLessonType() : "ARTICLE",
                    l.getVideoDuration(), Boolean.TRUE.equals(l.getIsPreview()), sId, sTitle);
            lessonItemViews.add(itemView);
            if (isCur) {
                currentLessonView = itemView;
            }
        }

        List<MaterialView> materials = materialRepository.findByLesson_LessonIdOrderByOrderIndexAsc(current.getLessonId())
                .stream()
                .map(m -> new MaterialView(m.getMaterialId(), m.getTitle(), m.getType(),
                        safeUrl(m.getFileUrl()), m.getOriginalFileName(), m.getSizeBytes()))
                .toList();

        int totalCount = publishedLessons.size();
        int completedCount = (int) publishedLessons.stream().filter(l -> completedLessonIds.contains(l.getLessonId())).count();
        int progressPercent = totalCount > 0 ? (int) Math.round((double) completedCount * 100.0 / totalCount) : 0;

        // Load bài tập gắn với lesson hiện tại
        List<AssignmentView> lessonAssignments = Collections.emptyList();
        if (assignmentRepository != null) {
            lessonAssignments = assignmentRepository
                    .findByCourse_CourseIdAndLesson_LessonIdAndStatusOrderByDueDateAsc(
                            courseId, current.getLessonId(), "PUBLISHED")
                    .stream()
                    .map(a -> toAssignmentView(a, studentId))
                    .toList();
        }

        // Load quiz gắn với lesson hiện tại
        List<QuizView> lessonQuizzes = Collections.emptyList();
        if (quizRepository != null) {
            lessonQuizzes = quizRepository
                    .findByCourse_CourseIdAndLesson_LessonIdAndStatus(
                            courseId, current.getLessonId(), "PUBLISHED")
                    .stream()
                    .map(q -> toQuizView(q, studentId))
                    .toList();
        }

        boolean lessonCompleted = completedLessonIds.contains(current.getLessonId());

        return new StudyCourseView(
                course.getCourseId(),
                course.getTitle(),
                course.getInstructor().getFullName(),
                lessonItemViews,
                currentLessonView,
                current.getContent(),
                materials,
                prevLessonId,
                nextLessonId,
                completedCount,
                totalCount,
                progressPercent,
                current.getLessonType() != null ? current.getLessonType() : "ARTICLE",
                current.getVideoUrl(),
                current.getVideoDuration(),
                current.getAllowSeek() != null ? current.getAllowSeek() : true,
                false,
                lessonAssignments,
                lessonCompleted,
                lessonQuizzes
        );
    }

    @Transactional(readOnly = true)
    public StudyCourseView getStudyContextForPreview(Integer courseId, Integer lessonId, Integer instructorId) {
        Course course = courseRepository != null ? courseRepository.findById(courseId)
                .orElseThrow(() -> new CourseActionException(HttpStatus.NOT_FOUND, "Không tìm thấy khóa học."))
                : null;
        if (course == null) throw new CourseActionException(HttpStatus.NOT_FOUND, "Không tìm thấy khóa học.");
        if (!Objects.equals(course.getInstructor().getUserId(), instructorId)) {
            throw new CourseActionException(HttpStatus.FORBIDDEN, "Bạn không có quyền xem trước khóa học này.");
        }

        List<Lesson> allLessons = lessonRepository.findByCourse_CourseIdOrderByOrderIndexAsc(courseId);
        if (allLessons.isEmpty()) {
            return new StudyCourseView(courseId, course.getTitle(), course.getInstructor().getFullName(),
                    Collections.emptyList(), null, null, Collections.emptyList(), null, null, 0, 0, 0,
                    "ARTICLE", null, null, true, true);
        }

        Lesson current;
        if (lessonId != null) {
            current = allLessons.stream()
                    .filter(l -> Objects.equals(l.getLessonId(), lessonId))
                    .findFirst()
                    .orElse(allLessons.get(0));
        } else {
            current = allLessons.get(0);
        }

        int currentIndex = allLessons.indexOf(current);
        Integer prevLessonId = currentIndex > 0 ? allLessons.get(currentIndex - 1).getLessonId() : null;
        Integer nextLessonId = currentIndex < allLessons.size() - 1 ? allLessons.get(currentIndex + 1).getLessonId() : null;

        List<LessonItemView> lessonItemViews = new ArrayList<>();
        LessonItemView currentLessonView = null;
        for (Lesson l : allLessons) {
            boolean isCur = Objects.equals(l.getLessonId(), current.getLessonId());
            String sTitle = l.getSection() != null ? l.getSection().getTitle() : null;
            Integer sId = l.getSection() != null ? l.getSection().getSectionId() : null;
            LessonItemView itemView = new LessonItemView(l.getLessonId(), l.getTitle(), l.getOrderIndex(), false, isCur,
                    l.getLessonType() != null ? l.getLessonType() : "ARTICLE",
                    l.getVideoDuration(), Boolean.TRUE.equals(l.getIsPreview()), sId, sTitle);
            lessonItemViews.add(itemView);
            if (isCur) currentLessonView = itemView;
        }

        List<MaterialView> materials = materialRepository.findByLesson_LessonIdOrderByOrderIndexAsc(current.getLessonId())
                .stream()
                .map(m -> new MaterialView(m.getMaterialId(), m.getTitle(), m.getType(),
                        safeUrl(m.getFileUrl()), m.getOriginalFileName(), m.getSizeBytes()))
                .toList();

        return new StudyCourseView(
                course.getCourseId(),
                course.getTitle(),
                course.getInstructor().getFullName(),
                lessonItemViews,
                currentLessonView,
                current.getContent(),
                materials,
                prevLessonId,
                nextLessonId,
                0,
                allLessons.size(),
                0,
                current.getLessonType() != null ? current.getLessonType() : "ARTICLE",
                current.getVideoUrl(),
                current.getVideoDuration(),
                current.getAllowSeek() != null ? current.getAllowSeek() : true,
                true // previewMode
        );
    }

    @Transactional
    public Integer completeLesson(Integer courseId, Integer lessonId, Integer studentId) {
        Enrollment enrollment = verifyEnrollment(studentId, courseId);
        Lesson lesson = lessonRepository.findByLessonIdAndCourse_CourseIdAndStatus(lessonId, courseId, PUBLISHED)
                .orElseThrow(() -> new CourseActionException(HttpStatus.NOT_FOUND, "Không tìm thấy bài học để hoàn thành."));

        if (!lessonCompletionRepository.existsByStudent_UserIdAndLesson_LessonId(studentId, lessonId)) {
            Users student = userRepository.findById(studentId)
                    .orElseThrow(() -> new CourseActionException(HttpStatus.UNAUTHORIZED, "Vui lòng đăng nhập lại."));
            LessonCompletion completion = new LessonCompletion();
            completion.setStudent(student);
            completion.setCourse(lesson.getCourse());
            completion.setLesson(lesson);
            completion.setCompletedAt(LocalDateTime.now());
            lessonCompletionRepository.save(completion);
        }

        // Cập nhật tiến độ học tập và ghi lịch sử hoạt động (UC37 & UC38)
        if (learningProgressService != null) {
            learningProgressService.updateProgressOnLessonCompleted(studentId, courseId, lessonId);
        }

        List<Lesson> publishedLessons = lessonRepository.findByCourse_CourseIdAndStatusOrderByOrderIndexAsc(courseId, PUBLISHED);
        long completedCount = lessonCompletionRepository.countByStudent_UserIdAndCourse_CourseId(studentId, courseId);

        if (completedCount >= publishedLessons.size() && !"COMPLETED".equals(enrollment.getStatus())) {
            enrollment.setStatus("COMPLETED");
            enrollment.setCompletedAt(LocalDateTime.now());
            enrollmentRepository.save(enrollment);
            // Ghi nhận hoàn thành khóa học vào lịch sử
            if (learningProgressService != null) {
                learningProgressService.recordActivity(enrollment.getStudent(), enrollment.getCourse(),
                        "COURSE_COMPLETED", null, null, null, "Đã hoàn thành tất cả các bài học trong khóa học!");
            }
        }

        int currentIndex = -1;
        for (int i = 0; i < publishedLessons.size(); i++) {
            if (Objects.equals(publishedLessons.get(i).getLessonId(), lessonId)) {
                currentIndex = i;
                break;
            }
        }

        return (currentIndex >= 0 && currentIndex < publishedLessons.size() - 1)
                ? publishedLessons.get(currentIndex + 1).getLessonId()
                : null;
    }

    private Enrollment verifyEnrollment(Integer studentId, Integer courseId) {
        Enrollment enrollment = enrollmentRepository.findByStudent_UserIdAndCourse_CourseId(studentId, courseId).orElse(null);
        if (enrollment != null) {
            if ("DROPPED".equalsIgnoreCase(enrollment.getStatus())) {
                throw new CourseActionException(HttpStatus.FORBIDDEN, "Khóa học này đã bị hủy ghi danh.");
            }
            return enrollment;
        }

        // Tự động cấp quyền truy cập học nếu là khóa học miễn phí hoặc Giảng viên sở hữu khóa học
        if (courseRepository != null) {
            Course c = courseRepository.findById(courseId).orElse(null);
            if (c != null) {
                boolean isInstructor = c.getInstructor() != null && Objects.equals(c.getInstructor().getUserId(), studentId);
                boolean isFree = c.getPrice() == null || c.getPrice().signum() == 0;
                boolean isAccessible = "PUBLISHED".equalsIgnoreCase(c.getStatus())
                        || "APPROVED".equalsIgnoreCase(c.getStatus())
                        || "UPDATING".equalsIgnoreCase(c.getStatus())
                        || isInstructor;

                if (isAccessible && (isFree || isInstructor)) {
                    Users u = userRepository.findById(studentId).orElse(null);
                    if (u != null) {
                        try {
                            Enrollment autoEnroll = new Enrollment();
                            autoEnroll.setCourse(c);
                            autoEnroll.setStudent(u);
                            autoEnroll.setStatus("ACTIVE");
                            autoEnroll.setEnrolledAt(LocalDateTime.now());
                            return enrollmentRepository.save(autoEnroll);
                        } catch (Exception ex) {
                            return enrollmentRepository.findByStudent_UserIdAndCourse_CourseId(studentId, courseId).orElse(null);
                        }
                    }
                }
            }
        }

        throw new CourseActionException(HttpStatus.FORBIDDEN, "Bạn chưa ghi danh khóa học này.");
    }

    private AssignmentView toAssignmentView(Assignment a, Integer studentId) {
        int attemptCount = (submissionRepository != null)
                ? (int) submissionRepository.countByAssignment_AssignmentIdAndStudent_UserId(
                        a.getAssignmentId(), studentId)
                : 0;
        AssignmentView v = new AssignmentView();
        v.setAssignmentId(a.getAssignmentId());
        v.setTitle(a.getTitle());
        v.setDescription(a.getDescription());
        v.setDueDate(a.getDueDate());
        v.setMaxScore(a.getMaxScore());
        v.setStatus(a.getStatus());
        v.setSubmissionCount(attemptCount);
        v.setLessonTitle(a.getLesson() != null ? a.getLesson().getTitle() : null);
        v.setAllowResubmit(a.isAllowResubmit());
        v.setMaxAttempts(a.getMaxAttempts());
        v.setUnlockAt(a.getUnlockAt());
        v.setLockAt(a.getLockAt());
        v.setLessonId(a.getLesson() != null ? a.getLesson().getLessonId() : null);
        v.setHasSubmitted(attemptCount > 0);
        v.setAttemptCount(attemptCount);
        return v;
    }

    private QuizView toQuizView(Quiz q, Integer studentId) {
        int attemptCount = (quizAttemptRepository != null)
                ? quizAttemptRepository.countByQuiz_QuizIdAndStudent_UserId(q.getQuizId(), studentId)
                : 0;
        Integer inProgressId = null;
        if (quizAttemptRepository != null) {
            inProgressId = quizAttemptRepository
                    .findFirstByQuiz_QuizIdAndStudent_UserIdAndStatus(q.getQuizId(), studentId, "IN_PROGRESS")
                    .map(a -> a.getAttemptId()).orElse(null);
        }
        // count questions
        long qCount = 0; // will be populated if needed
        QuizView v = new QuizView();
        v.setQuizId(q.getQuizId());
        v.setTitle(q.getTitle());
        v.setStatus(q.getStatus());
        v.setQuestionCount(qCount);
        v.setMaxScore(null);
        v.setDueDate(q.getDueDate());
        v.setTimeLimitMinutes(q.getTimeLimitMinutes());
        v.setMaxAttempts(q.getMaxAttempts());
        v.setMyAttemptCount(attemptCount);
        v.setPassingScore(q.getPassingScore());
        v.setInProgressAttemptId(inProgressId);
        return v;
    }

    private String safeUrl(String value) {
        if (value == null) return null;
        if (value.startsWith("/") && !value.contains("..")) return value;
        try {
            URI uri = URI.create(value);
            String scheme = uri.getScheme();
            return scheme != null && Set.of("http", "https").contains(scheme.toLowerCase())
                    && uri.getHost() != null && uri.getUserInfo() == null ? value : null;
        } catch (IllegalArgumentException ex) {
            return null;
        }
    }
}
