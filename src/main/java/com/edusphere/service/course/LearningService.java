package com.edusphere.service.course;

import com.edusphere.dto.course.LessonItemView;
import com.edusphere.dto.course.MaterialView;
import com.edusphere.dto.course.StudyCourseView;
import com.edusphere.entity.course.Course;
import com.edusphere.entity.course.Enrollment;
import com.edusphere.entity.course.Lesson;
import com.edusphere.entity.course.LessonCompletion;
import com.edusphere.entity.account.Users;
import com.edusphere.repository.course.EnrollmentRepository;
import com.edusphere.repository.course.LessonCompletionRepository;
import com.edusphere.repository.course.LessonRepository;
import com.edusphere.repository.course.MaterialRepository;
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

    public LearningService(LessonRepository lessonRepository,
                           EnrollmentRepository enrollmentRepository,
                           LessonCompletionRepository lessonCompletionRepository,
                           MaterialRepository materialRepository,
                           UserRepository userRepository) {
        this(lessonRepository, enrollmentRepository, lessonCompletionRepository, materialRepository, userRepository, null);
    }

    @Autowired
    public LearningService(LessonRepository lessonRepository,
                           EnrollmentRepository enrollmentRepository,
                           LessonCompletionRepository lessonCompletionRepository,
                           MaterialRepository materialRepository,
                           UserRepository userRepository,
                           LearningProgressService learningProgressService) {
        this.lessonRepository = lessonRepository;
        this.enrollmentRepository = enrollmentRepository;
        this.lessonCompletionRepository = lessonCompletionRepository;
        this.materialRepository = materialRepository;
        this.userRepository = userRepository;
        this.learningProgressService = learningProgressService;
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
                    Collections.emptyList(), null, null, Collections.emptyList(), null, null, 0, 0, 0);
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
            LessonItemView itemView = new LessonItemView(l.getLessonId(), l.getTitle(), l.getOrderIndex(), isComp, isCur);
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
                progressPercent
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
        Enrollment enrollment = enrollmentRepository.findByStudent_UserIdAndCourse_CourseId(studentId, courseId)
                .orElseThrow(() -> new CourseActionException(HttpStatus.FORBIDDEN, "Bạn chưa ghi danh khóa học này."));
        if ("DROPPED".equalsIgnoreCase(enrollment.getStatus())) {
            throw new CourseActionException(HttpStatus.FORBIDDEN, "Khóa học này đã bị hủy ghi danh.");
        }
        return enrollment;
    }

    private String safeUrl(String value) {
        if (value == null) return null;
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
