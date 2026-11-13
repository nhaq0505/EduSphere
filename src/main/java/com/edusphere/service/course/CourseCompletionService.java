package com.edusphere.service.course;

import com.edusphere.entity.course.Enrollment;
import com.edusphere.repository.course.EnrollmentRepository;
import com.edusphere.repository.course.LessonCompletionRepository;
import com.edusphere.repository.course.LessonRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;

/** Đánh dấu Enrollment = COMPLETED khi học viên hoàn thành toàn bộ bài học đã công bố. */
@Service
public class CourseCompletionService {

    private static final String PUBLISHED = "PUBLISHED";

    private final EnrollmentRepository enrollmentRepository;
    private final LessonRepository lessonRepository;
    private final LessonCompletionRepository lessonCompletionRepository;
    private final LearningProgressService learningProgressService;

    public CourseCompletionService(EnrollmentRepository enrollmentRepository,
                                   LessonRepository lessonRepository,
                                   LessonCompletionRepository lessonCompletionRepository,
                                   LearningProgressService learningProgressService) {
        this.enrollmentRepository = enrollmentRepository;
        this.lessonRepository = lessonRepository;
        this.lessonCompletionRepository = lessonCompletionRepository;
        this.learningProgressService = learningProgressService;
    }

    @Transactional
    public void markCompletedIfDone(Integer studentId, Integer courseId) {
        if (studentId == null || courseId == null) {
            return;
        }
        Enrollment enrollment = enrollmentRepository
                .findByStudent_UserIdAndCourse_CourseId(studentId, courseId).orElse(null);
        if (enrollment == null || !"ACTIVE".equalsIgnoreCase(enrollment.getStatus())) {
            return;
        }
        long total = lessonRepository.countByCourse_CourseIdAndStatus(courseId, PUBLISHED);
        long done = lessonCompletionRepository.countByStudent_UserIdAndCourse_CourseId(studentId, courseId);
        if (total > 0 && done >= total) {
            enrollment.setStatus("COMPLETED");
            enrollment.setCompletedAt(LocalDateTime.now());
            enrollmentRepository.save(enrollment);
            if (learningProgressService != null) {
                learningProgressService.recordActivity(enrollment.getStudent(), enrollment.getCourse(),
                        "COURSE_COMPLETED", null, null, null,
                        "Đã hoàn thành tất cả các bài học trong khóa học!");
            }
        }
    }
}
