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
import com.edusphere.entity.course.Question;
import com.edusphere.entity.course.LessonWatchProgress;
import com.edusphere.entity.course.Quiz;
import com.edusphere.entity.course.QuizAttempt;
import com.edusphere.entity.course.StudentStudyLog;
import com.edusphere.entity.account.Users;
import com.edusphere.repository.course.AssignmentRepository;
import com.edusphere.repository.course.CourseRepository;
import com.edusphere.repository.course.EnrollmentRepository;
import com.edusphere.repository.course.LessonCompletionRepository;
import com.edusphere.repository.course.LessonRepository;
import com.edusphere.repository.course.LessonWatchProgressRepository;
import com.edusphere.repository.course.MaterialRepository;
import com.edusphere.repository.course.QuestionRepository;
import com.edusphere.repository.course.QuizAttemptRepository;
import com.edusphere.repository.course.QuizRepository;
import com.edusphere.repository.course.StudentStudyLogRepository;
import com.edusphere.repository.course.SubmissionRepository;
import com.edusphere.repository.account.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.net.URI;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Set;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
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
    private final QuestionRepository questionRepository;
    private final LessonWatchProgressRepository watchProgressRepository;

    @Autowired(required = false)
    private BunnyStreamService bunnyStreamService;

    @Autowired(required = false)
    private CertificateService certificateService;

    @Autowired(required = false)
    private StudentStudyLogRepository studentStudyLogRepository;

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

    // Constructor 7-arg
    public LearningService(LessonRepository lessonRepository,
                           EnrollmentRepository enrollmentRepository,
                           LessonCompletionRepository lessonCompletionRepository,
                           MaterialRepository materialRepository,
                           UserRepository userRepository,
                           LearningProgressService learningProgressService,
                           CourseRepository courseRepository) {
        this(lessonRepository, enrollmentRepository, lessonCompletionRepository, materialRepository,
                userRepository, learningProgressService, courseRepository, null, null, null, null, null, null);
    }

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
        this(lessonRepository, enrollmentRepository, lessonCompletionRepository, materialRepository,
                userRepository, learningProgressService, courseRepository, assignmentRepository,
                submissionRepository, quizRepository, quizAttemptRepository, null, null);
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
                           QuizAttemptRepository quizAttemptRepository,
                           QuestionRepository questionRepository,
                           LessonWatchProgressRepository watchProgressRepository) {
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
        this.questionRepository = questionRepository;
        this.watchProgressRepository = watchProgressRepository;
    }

    // ── Watch Progress ─────────────────────────────────────────

    /**
     * Backward-compatible overload: nhận watchPercent và lastPositionSecs trực tiếp.
     */
    @Transactional
    public void saveWatchProgress(Integer courseId, Integer lessonId, Integer studentId,
                                  int watchPercent, int lastPositionSecs) {
        saveWatchProgress(courseId, lessonId, studentId, null, null, lastPositionSecs, null, watchPercent);
    }

    /**
     * Lưu tiến độ xem video: nhận khoảng thời gian xem mới [startSec, endSec], gộp vào các khoảng đã xem,
     * tính lại tổng số giây đã xem duy nhất và cập nhật watch_percent.
     * Mở khóa Quiz khi đạt >= 80%.
     */
    @Transactional
    public Map<String, Object> saveWatchProgress(Integer courseId, Integer lessonId, Integer studentId,
                                                Double startSec, Double endSec,
                                                int lastPositionSecs, Double durationSec,
                                                int fallbackPercent) {
        verifyEnrollment(studentId, courseId);
        Lesson lesson = lessonRepository.findByLessonIdAndCourse_CourseId(lessonId, courseId)
                .orElseThrow(() -> new CourseActionException(HttpStatus.NOT_FOUND, "Không tìm thấy bài học."));
        Users student = userRepository.findById(studentId)
                .orElseThrow(() -> new CourseActionException(HttpStatus.UNAUTHORIZED, "Vui lòng đăng nhập lại."));

        LessonWatchProgress wp = watchProgressRepository
                .findByStudent_UserIdAndLesson_LessonId(studentId, lessonId)
                .orElseGet(() -> {
                    LessonWatchProgress n = new LessonWatchProgress();
                    n.setStudent(student);
                    n.setCourse(lesson.getCourse());
                    n.setLesson(lesson);
                    n.setWatchPercent(0);
                    n.setLastPosition(0);
                    n.setWatchedSegments("[]");
                    n.setQuizUnlocked(false);
                    return n;
                });

        // 1. Xác định thời lượng video hiệu dụng (giây)
        int effectiveDuration = 0;
        if (durationSec != null && durationSec > 0) {
            effectiveDuration = (int) Math.round(durationSec);
        } else if (lesson.getVideoDuration() != null && lesson.getVideoDuration() > 0) {
            effectiveDuration = lesson.getVideoDuration() > 60 ? lesson.getVideoDuration() : lesson.getVideoDuration() * 60;
        }

        // 2. Parse các khoảng đã xem trước đó
        List<int[]> intervals = parseIntervals(wp.getWatchedSegments());
        int previousWatchedSecs = calculateTotalWatchedSeconds(intervals);

        // 3. Nếu có gửi khoảng [startSec, endSec] hợp lệ -> gộp vào danh sách khoảng đã xem
        if (startSec != null && endSec != null) {
            int s = (int) Math.floor(Math.max(0, startSec));
            int e = (int) Math.ceil(Math.max(0, endSec));

            // Nếu biết effectiveDuration, giới hạn không vượt quá độ dài video
            if (effectiveDuration > 0) {
                s = Math.min(s, effectiveDuration);
                e = Math.min(e, effectiveDuration);
            }

            // Chống gian lận: khoảng xem giữa 2 lần ping (~4-5s) không được vượt quá 15s
            if (e - s > 15) {
                e = s + 15;
                if (effectiveDuration > 0) {
                    e = Math.min(e, effectiveDuration);
                }
            }

            if (e > s) {
                intervals = mergeIntervals(intervals, s, e);
            }
        }

        // 4. Tính tổng số giây đã xem duy nhất (không cộng trùng, không tính pause/buffer)
        int totalWatchedSecs = calculateTotalWatchedSeconds(intervals);
        int deltaWatchedSecs = Math.max(0, totalWatchedSecs - previousWatchedSecs);
        if (deltaWatchedSecs > 0) {
            recordStudySeconds(student, lesson.getCourse(), deltaWatchedSecs);
        }

        // 5. Tính phần trăm tiến độ
        int newPercent = 0;
        if (effectiveDuration > 0) {
            newPercent = Math.min(100, (int) Math.round((totalWatchedSecs * 100.0) / effectiveDuration));
        } else if (fallbackPercent > 0) {
            newPercent = Math.min(100, fallbackPercent);
        }

        int currentPercent = wp.getWatchPercent() != null ? wp.getWatchPercent() : 0;
        int finalPercent = Math.max(currentPercent, newPercent);
        wp.setWatchPercent(finalPercent);

        // 6. Cập nhật vị trí dừng gần nhất (chỉ cập nhật giá trị hợp lệ >= 0)
        wp.setLastPosition(Math.max(0, lastPositionSecs));

        // 7. Lưu lại chuỗi JSON các khoảng đã xem
        wp.setWatchedSegments(intervalsToJson(intervals));

        // 8. Kiểm tra và cập nhật điều kiện mở khóa Quiz (>= 80%)
        int minWatchReq = (lesson.getMinWatchPercent() != null && lesson.getMinWatchPercent() > 0) ? lesson.getMinWatchPercent() : 80;
        boolean isUnlocked = Boolean.TRUE.equals(wp.getQuizUnlocked()) || (finalPercent >= minWatchReq);
        if (isUnlocked) {
            wp.setQuizUnlocked(true);
        }

        // Nếu bài học không có Quiz nào và đã xem đạt yêu cầu -> tự động ghi nhận hoàn thành bài học
        if (finalPercent >= minWatchReq && lessonCompletionRepository != null
                && !lessonCompletionRepository.existsByStudent_UserIdAndLesson_LessonId(studentId, lessonId)) {
            boolean hasQuiz = quizRepository != null
                    && !quizRepository.findByCourse_CourseIdAndLesson_LessonIdAndStatus(courseId, lessonId, "PUBLISHED").isEmpty();
            if (!hasQuiz) {
                try {
                    LessonCompletion lc = new LessonCompletion();
                    lc.setStudent(student);
                    lc.setCourse(lesson.getCourse());
                    lc.setLesson(lesson);
                    lc.setCompletedAt(LocalDateTime.now());
                    lessonCompletionRepository.save(lc);
                    if (certificateService != null) {
                        certificateService.issueCertificateIfEligible(studentId, courseId);
                    }
                } catch (Exception ignored) {}
            }
        }

        LessonWatchProgress saved = watchProgressRepository.save(wp);

        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("percent", saved.getWatchPercent());
        result.put("position", saved.getLastPosition());
        result.put("quizUnlocked", Boolean.TRUE.equals(saved.getQuizUnlocked()));
        result.put("totalWatchedSeconds", totalWatchedSecs);
        result.put("effectiveDuration", effectiveDuration);
        return result;
    }

    public static List<int[]> parseIntervals(String json) {
        List<int[]> result = new ArrayList<>();
        if (json == null || json.isBlank()) return result;
        Matcher m = Pattern.compile("\\[\\s*(\\d+)\\s*,\\s*(\\d+)\\s*\\]").matcher(json);
        while (m.find()) {
            int s = Integer.parseInt(m.group(1));
            int e = Integer.parseInt(m.group(2));
            if (e >= s) {
                result.add(new int[]{s, e});
            }
        }
        return result;
    }

    public static List<int[]> mergeIntervals(List<int[]> existing, int newStart, int newEnd) {
        if (newEnd < newStart) return new ArrayList<>(existing != null ? existing : Collections.emptyList());
        List<int[]> intervals = new ArrayList<>(existing != null ? existing : Collections.emptyList());
        intervals.add(new int[]{newStart, newEnd});
        intervals.sort(Comparator.comparingInt(a -> a[0]));

        List<int[]> merged = new ArrayList<>();
        for (int[] interval : intervals) {
            if (merged.isEmpty()) {
                merged.add(new int[]{interval[0], interval[1]});
            } else {
                int[] last = merged.get(merged.size() - 1);
                // Nếu khoảng mới chạm hoặc trùng khoảng trước (cho phép sai số 1s để nối mượt)
                if (interval[0] <= last[1] + 1) {
                    last[1] = Math.max(last[1], interval[1]);
                } else {
                    merged.add(new int[]{interval[0], interval[1]});
                }
            }
        }
        return merged;
    }

    public static int calculateTotalWatchedSeconds(List<int[]> intervals) {
        if (intervals == null) return 0;
        int total = 0;
        for (int[] interval : intervals) {
            total += Math.max(0, interval[1] - interval[0]);
        }
        return total;
    }

    public static String intervalsToJson(List<int[]> intervals) {
        if (intervals == null || intervals.isEmpty()) return "[]";
        StringBuilder sb = new StringBuilder("[");
        for (int i = 0; i < intervals.size(); i++) {
            if (i > 0) sb.append(",");
            int[] interval = intervals.get(i);
            sb.append("[").append(interval[0]).append(",").append(interval[1]).append("]");
        }
        sb.append("]");
        return sb.toString();
    }

    /** Lấy tiến độ xem video của học viên (trả về -1 nếu chưa xem lần nào). */
    @Transactional(readOnly = true)
    public LessonWatchProgress getWatchProgress(Integer lessonId, Integer studentId) {
        return watchProgressRepository
                .findByStudent_UserIdAndLesson_LessonId(studentId, lessonId)
                .orElse(null);
    }

    @Transactional
    public StudyCourseView getStudyContext(Integer courseId, Integer lessonId, Integer studentId) {
        if (courseRepository != null && studentId != null) {
            Course maybeCourse = courseRepository.findById(courseId).orElse(null);
            if (maybeCourse != null && maybeCourse.getInstructor() != null
                    && Objects.equals(maybeCourse.getInstructor().getUserId(), studentId)) {
                return getStudyContextForPreview(courseId, lessonId, studentId);
            }
        }
        List<Lesson> publishedLessons = lessonRepository.findByCourse_CourseIdAndStatusOrderByOrderIndexAsc(courseId, PUBLISHED);

        // Check if specific lesson was requested
        Lesson targetLesson = null;
        if (lessonId != null && !publishedLessons.isEmpty()) {
            targetLesson = publishedLessons.stream()
                    .filter(l -> Objects.equals(l.getLessonId(), lessonId))
                    .findFirst()
                    .orElse(null);
        }

        Enrollment enrollment = null;
        try {
            enrollment = verifyEnrollment(studentId, courseId);
        } catch (CourseActionException ex) {
            // If student is not enrolled, check if target lesson (or first preview lesson) allows preview
            if (targetLesson != null && Boolean.TRUE.equals(targetLesson.getIsPreview())) {
                enrollment = null; // Preview allowed
            } else if (targetLesson == null && !publishedLessons.isEmpty()) {
                targetLesson = publishedLessons.stream()
                        .filter(l -> Boolean.TRUE.equals(l.getIsPreview()))
                        .findFirst()
                        .orElseThrow(() -> ex);
            } else {
                throw ex;
            }
        }

        Course course = enrollment != null ? enrollment.getCourse()
                : (courseRepository != null ? courseRepository.findById(courseId).orElse(null) : null);
        if (course == null && targetLesson != null) {
            course = targetLesson.getCourse();
        }

        // Ghi nhận thời điểm truy cập khóa học gần nhất
        if (learningProgressService != null && enrollment != null && studentId != null) {
            learningProgressService.recordAccess(studentId, courseId);
        }

        if (publishedLessons.isEmpty()) {
            String title = course != null ? course.getTitle() : "Khóa học";
            String insName = course != null && course.getInstructor() != null ? course.getInstructor().getFullName() : "";
            StudyCourseView studyView = new StudyCourseView(courseId, title, insName,
                    Collections.emptyList(), null, null, Collections.emptyList(), null, null, 0, 0, 0,
                    "ARTICLE", null, null, true, false);
            return studyView;
        }

        Set<Integer> completedLessonIds = (studentId != null)
                ? lessonCompletionRepository.findByStudent_UserIdAndCourse_CourseId(studentId, courseId)
                        .stream().map(c -> c.getLesson().getLessonId()).collect(Collectors.toSet())
                : Collections.emptySet();

        Lesson current;
        if (targetLesson != null) {
            current = targetLesson;
            // Check prerequisite & unlock days if lesson is NOT a preview lesson
            if (!Boolean.TRUE.equals(current.getIsPreview())) {
                if (current.getPrerequisiteLesson() != null && !completedLessonIds.contains(current.getPrerequisiteLesson().getLessonId())) {
                    throw new CourseActionException(HttpStatus.BAD_REQUEST,
                            "Bạn cần hoàn thành bài học tiên quyết trước: " + current.getPrerequisiteLesson().getTitle());
                }
                if (current.getUnlockDaysAfterEnroll() != null && current.getUnlockDaysAfterEnroll() > 0
                        && enrollment != null && enrollment.getEnrolledAt() != null) {
                    if (LocalDateTime.now().isBefore(enrollment.getEnrolledAt().plusDays(current.getUnlockDaysAfterEnroll()))) {
                        throw new CourseActionException(HttpStatus.BAD_REQUEST,
                                "Bài học này sẽ mở khóa sau " + current.getUnlockDaysAfterEnroll() + " ngày kể từ khi ghi danh.");
                    }
                }
            }
        } else {
            // Mặc định bài chưa hoàn thành đầu tiên được mở khóa, nếu không có thì bài đầu tiên được mở khóa, hoặc bài đầu tiên
            final Enrollment fEnrollment = enrollment;
            current = publishedLessons.stream()
                    .filter(l -> !completedLessonIds.contains(l.getLessonId()) && isLessonUnlocked(l, completedLessonIds, fEnrollment))
                    .findFirst()
                    .orElseGet(() -> publishedLessons.stream()
                            .filter(l -> isLessonUnlocked(l, completedLessonIds, fEnrollment))
                            .findFirst()
                            .orElse(publishedLessons.get(0)));
        }

        // Nếu bài học hiện tại KHÔNG có video và KHÔNG có Quiz PUBLISHED:
        // Học viên xem nội dung -> tự động ghi nhận hoàn thành bài học để mở bài tiếp theo
        boolean currentHasVideo = current.getVideoUrl() != null && !current.getVideoUrl().isBlank();
        boolean currentHasQuiz = quizRepository != null
                && !quizRepository.findByCourse_CourseIdAndLesson_LessonIdAndStatus(courseId, current.getLessonId(), "PUBLISHED").isEmpty();
        if (enrollment != null && enrollment.getStudent() != null
                && !currentHasVideo && !currentHasQuiz && !completedLessonIds.contains(current.getLessonId())) {
            try {
                LessonCompletion lc = new LessonCompletion();
                lc.setStudent(enrollment.getStudent());
                lc.setCourse(course);
                lc.setLesson(current);
                lc.setCompletedAt(LocalDateTime.now());
                lessonCompletionRepository.save(lc);
                completedLessonIds.add(current.getLessonId());
            } catch (Exception ignored) {}
        }

        int currentIndex = publishedLessons.indexOf(current);
        Integer prevLessonId = currentIndex > 0 ? publishedLessons.get(currentIndex - 1).getLessonId() : null;
        Integer nextLessonId = currentIndex < publishedLessons.size() - 1 ? publishedLessons.get(currentIndex + 1).getLessonId() : null;

        List<LessonItemView> lessonItemViews = new ArrayList<>();
        LessonItemView currentLessonView = null;
        boolean prevPassed = true;
        for (int i = 0; i < publishedLessons.size(); i++) {
            Lesson l = publishedLessons.get(i);
            boolean isCur = Objects.equals(l.getLessonId(), current.getLessonId());
            boolean isComp = completedLessonIds.contains(l.getLessonId());

            // Bài đầu tiên (i == 0) luôn mở khóa.
            // Các bài tiếp theo (i > 0) bị khóa nếu bài trước đó chưa hoàn thành cả bài học và bài quiz (nếu có).
            boolean locked = (i > 0) && !prevPassed;

            // Kiểm tra bài hiện tại có đạt cả bài học và quiz hay không để mở bài tiếp:
            if (!isLessonAndQuizCompleted(l, studentId)) {
                prevPassed = false;
            }

            String sTitle = l.getSection() != null ? l.getSection().getTitle() : null;
            Integer sId = l.getSection() != null ? l.getSection().getSectionId() : null;
            LessonItemView itemView = new LessonItemView(l.getLessonId(), l.getTitle(), l.getOrderIndex(), isComp, isCur,
                    l.getLessonType() != null ? l.getLessonType() : "ARTICLE",
                    l.getVideoDuration(), Boolean.TRUE.equals(l.getIsPreview()), sId, sTitle, locked);
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
        if (assignmentRepository != null && studentId != null) {
            lessonAssignments = assignmentRepository
                    .findByCourse_CourseIdAndLesson_LessonIdAndStatusOrderByDueDateAsc(
                            courseId, current.getLessonId(), "PUBLISHED")
                    .stream()
                    .map(a -> toAssignmentView(a, studentId))
                    .toList();
        }

        // Load quiz gắn với lesson hiện tại
        List<QuizView> lessonQuizzes = Collections.emptyList();
        if (quizRepository != null && studentId != null) {
            lessonQuizzes = quizRepository
                    .findByCourse_CourseIdAndLesson_LessonIdAndStatus(
                            courseId, current.getLessonId(), "PUBLISHED")
                    .stream()
                    .map(q -> toQuizView(q, studentId))
                    .toList();
        }

        boolean lessonCompleted = completedLessonIds.contains(current.getLessonId());
        boolean isPreviewMode = (enrollment == null) || Boolean.TRUE.equals(current.getIsPreview());

        // Tự động đồng bộ trạng thái video từ Bunny nếu đang PROCESSING (hữu ích khi chạy local không có Webhook)
        syncBunnyVideoStatusIfNeeded(current);

        // Lấy tiến độ xem video của học viên cho bài học hiện tại
        LessonWatchProgress wp = watchProgressRepository != null
                ? watchProgressRepository.findByStudent_UserIdAndLesson_LessonId(studentId, current.getLessonId()).orElse(null)
                : null;
        int watchPercent  = wp != null && wp.getWatchPercent() != null ? wp.getWatchPercent()  : -1;
        int lastPosition  = wp != null && wp.getLastPosition() != null ? wp.getLastPosition()  : 0;
        boolean hasVideo = current.getVideoUrl() != null && !current.getVideoUrl().isBlank();
        boolean quizRequiresVideo = hasVideo && Boolean.TRUE.equals(current.getQuizRequiresVideo());
        int minWatchPct   = current.getMinWatchPercent() != null && current.getMinWatchPercent() > 0 ? current.getMinWatchPercent() : 80;
        // Nếu bài không có video -> mở khóa Quiz ngay. Nếu có video -> mở khóa khi xem >= minWatchPct
        boolean quizUnlocked = !hasVideo || !quizRequiresVideo
                || (wp != null && (Boolean.TRUE.equals(wp.getQuizUnlocked()) || watchPercent >= minWatchPct));
        String watchedSegments = wp != null && wp.getWatchedSegments() != null ? wp.getWatchedSegments() : "[]";

        StudyCourseView studyView = new StudyCourseView(
                course != null ? course.getCourseId() : courseId,
                course != null ? course.getTitle() : "Khóa học",
                course != null && course.getInstructor() != null ? course.getInstructor().getFullName() : "",
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
                isPreviewMode,
                lessonAssignments,
                lessonCompleted,
                lessonQuizzes,
                current.getVideoStatus(),
                watchPercent,
                lastPosition,
                quizRequiresVideo,
                minWatchPct,
                quizUnlocked,
                watchedSegments);

        if (course != null && course.getCredits() != null) {
            studyView.setCourseCredits(course.getCredits());
        }
        if (certificateService != null && studentId != null && totalCount > 0 && completedCount >= totalCount) {
            try {
                certificateService.issueCertificateIfEligible(studentId, courseId)
                        .ifPresent(cert -> studyView.setCertificateId(cert.getCertificateId()));
            } catch (Exception ignored) {}
        }
        return studyView;

    }

    /**
     * Tự động kiểm tra trạng thái video trên Bunny Stream nếu bài học đang ở trạng thái PROCESSING/UPLOADING,
     * giúp cập nhật lên READY ngay khi học viên hoặc giảng viên mở bài học mà không cần phụ thuộc vào Webhook.
     */
    private void syncBunnyVideoStatusIfNeeded(Lesson lesson) {
        if (lesson == null || bunnyStreamService == null || !bunnyStreamService.isConfigured()) {
            return;
        }
        String guid = lesson.getBunnyVideoId();
        if ((guid == null || guid.isBlank()) && lesson.getVideoUrl() != null
                && lesson.getVideoUrl().contains("player.mediadelivery.net/embed/")) {
            int lastSlash = lesson.getVideoUrl().lastIndexOf('/');
            if (lastSlash >= 0 && lastSlash < lesson.getVideoUrl().length() - 1) {
                guid = lesson.getVideoUrl().substring(lastSlash + 1).trim();
                int qIdx = guid.indexOf('?');
                if (qIdx > 0) guid = guid.substring(0, qIdx);
                lesson.setBunnyVideoId(guid);
            }
        }
        if (guid == null || guid.isBlank()) {
            return;
        }
        String status = lesson.getVideoStatus();
        if (status == null || "PROCESSING".equalsIgnoreCase(status)
                || "UPLOADING".equalsIgnoreCase(status) || "NONE".equalsIgnoreCase(status)) {
            String latestStatus = bunnyStreamService.getVideoStatus(guid);
            if (latestStatus != null && !latestStatus.equals(status)) {
                lesson.setVideoStatus(latestStatus);
                lesson.setUpdatedAt(LocalDateTime.now());
                lessonRepository.save(lesson);
            }
        }
    }

    private boolean isLessonUnlocked(Lesson l, Set<Integer> completedLessonIds, Enrollment enrollment) {
        if (Boolean.TRUE.equals(l.getIsPreview())) {
            return true;
        }
        if (l.getPrerequisiteLesson() != null && !completedLessonIds.contains(l.getPrerequisiteLesson().getLessonId())) {
            return false;
        }
        if (l.getUnlockDaysAfterEnroll() != null && l.getUnlockDaysAfterEnroll() > 0
                && enrollment != null && enrollment.getEnrolledAt() != null) {
            if (LocalDateTime.now().isBefore(enrollment.getEnrolledAt().plusDays(l.getUnlockDaysAfterEnroll()))) {
                return false;
            }
        }
        return true;
    }

    @Transactional
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
            StudyCourseView studyView = new StudyCourseView(courseId, course.getTitle(), course.getInstructor().getFullName(),
                    Collections.emptyList(), null, null, Collections.emptyList(), null, null, 0, 0, 0,
                    "ARTICLE", null, null, true, true);
            return studyView;
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

        syncBunnyVideoStatusIfNeeded(current);

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
                    l.getVideoDuration(), Boolean.TRUE.equals(l.getIsPreview()), sId, sTitle, false);
            lessonItemViews.add(itemView);
            if (isCur) currentLessonView = itemView;
        }

        List<MaterialView> materials = materialRepository.findByLesson_LessonIdOrderByOrderIndexAsc(current.getLessonId())
                .stream()
                .map(m -> new MaterialView(m.getMaterialId(), m.getTitle(), m.getType(),
                        safeUrl(m.getFileUrl()), m.getOriginalFileName(), m.getSizeBytes()))
                .toList();

        StudyCourseView studyView = new StudyCourseView(
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
                true, // previewMode
                Collections.emptyList(),
                false,
                Collections.emptyList(),
                current.getVideoStatus()); // Bunny video status

        if (course.getCredits() != null) {
            studyView.setCourseCredits(course.getCredits());
        }
        return studyView;

    }

    /**
     * Kiểm tra một bài học đã hoàn thành cả phần nội dung/video VÀ bài quiz (nếu có) hay chưa.
     * Dùng để quyết định việc mở khóa bài học kế tiếp.
     */
    public boolean isLessonAndQuizCompleted(Lesson lesson, Integer studentId) {
        if (lesson == null) return false;
        Integer lessonId = lesson.getLessonId();
        Integer courseId = lesson.getCourse() != null ? lesson.getCourse().getCourseId() : null;
        boolean hasVideo = lesson.getVideoUrl() != null && !lesson.getVideoUrl().isBlank();

        // 1. Kiểm tra hoàn thành bài học
        boolean lessonCompleted = lessonCompletionRepository != null
                && lessonCompletionRepository.existsByStudent_UserIdAndLesson_LessonId(studentId, lessonId);

        // Với bài có video: học viên có thể hoàn thành bằng cách xem video >= minWatchPct
        if (!lessonCompleted && hasVideo && watchProgressRepository != null) {
            int minPct = (lesson.getMinWatchPercent() != null && lesson.getMinWatchPercent() > 0) ? lesson.getMinWatchPercent() : 80;
            lessonCompleted = watchProgressRepository.findByStudent_UserIdAndLesson_LessonId(studentId, lessonId)
                    .map(wp -> Boolean.TRUE.equals(wp.getQuizUnlocked()) || (wp.getWatchPercent() != null && wp.getWatchPercent() >= minPct))
                    .orElse(false);
        }

        // Kiểm tra xem bài học có Quiz PUBLISHED hay không
        List<Quiz> quizzes = (courseId != null && quizRepository != null)
                ? quizRepository.findByCourse_CourseIdAndLesson_LessonIdAndStatus(courseId, lessonId, "PUBLISHED")
                : Collections.emptyList();
        boolean hasQuizzes = quizzes != null && !quizzes.isEmpty();

        // Nếu bài học KHÔNG có video:
        // - Nếu KHÔNG có Quiz: đã đủ điều kiện qua bài tiếp theo khi xem nội dung
        // - Nếu CÓ Quiz: học viên cần nộp/đạt Quiz (kiểm tra ở bước 2 dưới đây)
        if (!hasVideo) {
            if (!hasQuizzes) {
                return true;
            }
        } else {
            if (!lessonCompleted) {
                return false;
            }
        }

        // 2. Nếu bài học có Quiz PUBLISHED -> học viên phải hoàn thành / nộp Quiz
        if (hasQuizzes && quizAttemptRepository != null) {
            for (Quiz q : quizzes) {
                List<QuizAttempt> attempts = quizAttemptRepository.findByQuiz_QuizIdAndStudent_UserIdOrderByAttemptNumberDesc(q.getQuizId(), studentId);
                boolean qPassed = false;
                for (QuizAttempt att : attempts) {
                    if ("SCORED".equals(att.getStatus()) || "SUBMITTED".equals(att.getStatus())) {
                        if (q.getPassingScore() != null && att.getMaxScore() != null
                                && att.getMaxScore().compareTo(BigDecimal.ZERO) > 0 && att.getScore() != null) {
                            double pct = att.getScore().doubleValue() / att.getMaxScore().doubleValue() * 100.0;
                            if (pct >= q.getPassingScore().doubleValue()) {
                                qPassed = true;
                                break;
                            }
                        } else {
                            qPassed = true;
                            break;
                        }
                    }
                }
                if (!qPassed) {
                    return false;
                }
            }
        }

        return true;
    }

    @Transactional
    public Integer completeLesson(Integer courseId, Integer lessonId, Integer studentId) {
        Enrollment enrollment = verifyEnrollment(studentId, courseId);
        Lesson lesson = lessonRepository.findByLessonIdAndCourse_CourseIdAndStatus(lessonId, courseId, PUBLISHED)
                .orElseThrow(() -> new CourseActionException(HttpStatus.NOT_FOUND, "Không tìm thấy bài học để hoàn thành."));

        // Kiểm tra điều kiện hoàn thành Quiz nếu bài học có gắn Quiz
        if (quizRepository != null && quizAttemptRepository != null) {
            List<Quiz> quizzes = quizRepository.findByCourse_CourseIdAndLesson_LessonIdAndStatus(courseId, lessonId, "PUBLISHED");
            if (quizzes != null && !quizzes.isEmpty()) {
                boolean allQuizzesDone = true;
                for (Quiz q : quizzes) {
                    List<QuizAttempt> attempts = quizAttemptRepository.findByQuiz_QuizIdAndStudent_UserIdOrderByAttemptNumberDesc(q.getQuizId(), studentId);
                    boolean done = attempts.stream().anyMatch(a -> "SCORED".equals(a.getStatus()) || "SUBMITTED".equals(a.getStatus()));
                    if (!done) {
                        allQuizzesDone = false;
                        break;
                    }
                }
                if (!allQuizzesDone) {
                    throw new CourseActionException(HttpStatus.BAD_REQUEST,
                            "Bạn cần hoàn thành bài kiểm tra (Quiz) của bài học này trước khi đánh dấu hoàn thành để chuyển sang bài tiếp theo.");
                }
            }
        }

        if (lesson.getPrerequisiteLesson() != null) {
            boolean prereqDone = lessonCompletionRepository.existsByStudent_UserIdAndLesson_LessonId(
                    studentId, lesson.getPrerequisiteLesson().getLessonId());
            if (!prereqDone) {
                throw new CourseActionException(HttpStatus.BAD_REQUEST,
                        "Bạn cần hoàn thành bài học tiên quyết trước: " + lesson.getPrerequisiteLesson().getTitle());
            }
        }

        if (lesson.getUnlockDaysAfterEnroll() != null && lesson.getUnlockDaysAfterEnroll() > 0
                && enrollment.getEnrolledAt() != null) {
            if (LocalDateTime.now().isBefore(enrollment.getEnrolledAt().plusDays(lesson.getUnlockDaysAfterEnroll()))) {
                throw new CourseActionException(HttpStatus.BAD_REQUEST,
                        "Bài học này sẽ mở khóa sau " + lesson.getUnlockDaysAfterEnroll() + " ngày kể từ khi ghi danh.");
            }
        }

        if (enrollment.getEnrollmentId() != null) {
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
            if (certificateService != null) {
                try {
                    certificateService.issueCertificateIfEligible(studentId, courseId);
                } catch (Exception ignored) {}
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

        // Tự động cấp quyền truy cập học nếu là khóa học miễn phí hoặc Giảng viên sở hữu khóa học / Admin
        if (courseRepository != null) {
            Course c = courseRepository.findById(courseId).orElse(null);
            if (c != null) {
                Users u = userRepository != null && studentId != null ? userRepository.findById(studentId).orElse(null) : null;
                boolean isOwner = c.getInstructor() != null && Objects.equals(c.getInstructor().getUserId(), studentId);
                boolean isAdmin = u != null && u.getUserRolesCollection() != null
                        && u.getUserRolesCollection().stream()
                        .anyMatch(ur -> ur.getRoles() != null && "ADMINISTRATOR".equalsIgnoreCase(ur.getRoles().getRoleName()));

                if (isOwner || isAdmin) {
                    Users targetUser = u != null ? u : c.getInstructor();
                    if (targetUser != null) {
                        Enrollment existing = enrollmentRepository
                                .findByStudent_UserIdAndCourse_CourseId(targetUser.getUserId(), courseId)
                                .orElse(null);
                        if (existing != null) {
                            if ("DROPPED".equalsIgnoreCase(existing.getStatus())) {
                                existing.setStatus("ACTIVE");
                                return enrollmentRepository.save(existing);
                            }
                            return existing;
                        }
                        Enrollment autoEnroll = new Enrollment();
                        autoEnroll.setCourse(c);
                        autoEnroll.setStudent(targetUser);
                        autoEnroll.setStatus("ACTIVE");
                        autoEnroll.setEnrolledAt(LocalDateTime.now());
                        return enrollmentRepository.save(autoEnroll);
                    }
                }

                boolean isFree = c.getPrice() == null || c.getPrice().signum() == 0;
                boolean isAccessible = "PUBLISHED".equals(c.getStatus())
                        || "UPDATING".equals(c.getStatus())
                        || ("SUBMITTED".equals(c.getStatus()) && c.getPublishedAt() != null);

                if (isAccessible && isFree && u != null) {
                    Enrollment existing = enrollmentRepository.findByStudent_UserIdAndCourse_CourseId(studentId, courseId).orElse(null);
                    if (existing != null) {
                        if ("DROPPED".equalsIgnoreCase(existing.getStatus())) {
                            existing.setStatus("ACTIVE");
                            return enrollmentRepository.save(existing);
                        }
                        return existing;
                    }
                    Enrollment autoEnroll = new Enrollment();
                    autoEnroll.setCourse(c);
                    autoEnroll.setStudent(u);
                    autoEnroll.setStatus("ACTIVE");
                    autoEnroll.setEnrolledAt(LocalDateTime.now());
                    return enrollmentRepository.save(autoEnroll);
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
        // count questions and total maxScore
        long qCount = 0;
        BigDecimal maxScore = null;
        if (questionRepository != null) {
            List<Question> qList = questionRepository.findByQuiz_QuizIdOrderByOrderIndexAsc(q.getQuizId());
            long counted = questionRepository.countByQuiz_QuizId(q.getQuizId());
            qCount = counted > 0 ? counted : (qList != null ? qList.size() : 0);
            maxScore = (qList != null ? qList : Collections.<Question>emptyList()).stream()
                    .map(Question::getScore)
                    .filter(Objects::nonNull)
                    .reduce(BigDecimal.ZERO, BigDecimal::add);
        }
        QuizView v = new QuizView();
        v.setQuizId(q.getQuizId());
        v.setTitle(q.getTitle());
        v.setStatus(q.getStatus());
        v.setQuestionCount(qCount);
        v.setMaxScore(maxScore);
        v.setDueDate(q.getDueDate());
        v.setTimeLimitMinutes(q.getTimeLimitMinutes());
        v.setMaxAttempts(q.getMaxAttempts());
        v.setMyAttemptCount(attemptCount);
        v.setPassingScore(q.getPassingScore());
        v.setInProgressAttemptId(inProgressId);
        return v;
    }

    private void recordStudySeconds(Users student, Course course, int addedSeconds) {
        if (studentStudyLogRepository == null || student == null || course == null || addedSeconds <= 0) {
            return;
        }
        try {
            LocalDate today = LocalDate.now();
            StudentStudyLog logEntry = studentStudyLogRepository
                    .findByStudent_UserIdAndCourse_CourseIdAndStudyDate(student.getUserId(), course.getCourseId(), today)
                    .orElseGet(() -> {
                        StudentStudyLog created = new StudentStudyLog();
                        created.setStudent(student);
                        created.setCourse(course);
                        created.setStudyDate(today);
                        created.setDurationSeconds(0);
                        return created;
                    });
            int current = logEntry.getDurationSeconds() != null ? logEntry.getDurationSeconds() : 0;
            logEntry.setDurationSeconds(current + addedSeconds);
            studentStudyLogRepository.save(logEntry);
        } catch (Exception ignored) {
            // Không làm gián đoạn luồng học bài nếu ghi log giờ học gặp lỗi
        }
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
