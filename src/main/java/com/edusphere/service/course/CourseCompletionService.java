package com.edusphere.service.course;

import com.edusphere.entity.course.Enrollment;
import com.edusphere.entity.course.Lesson;
import com.edusphere.repository.course.EnrollmentRepository;
import com.edusphere.repository.course.LessonCompletionRepository;
import com.edusphere.repository.course.LessonRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * Dịch vụ kiểm tra tiến độ bài giảng và tự động đánh dấu Enrollment = COMPLETED
 * khi học viên hoàn thành 100% các bài học đã công bố trong khóa học.
 */
@Service
public class CourseCompletionService {

  private static final String PUBLISHED_STATUS = "PUBLISHED";
  private static final String ENROLLMENT_ACTIVE = "ACTIVE";
  private static final String ENROLLMENT_COMPLETED = "COMPLETED";
  private static final String ACTIVITY_COURSE_COMPLETED = "COURSE_COMPLETED";

  private final EnrollmentRepository enrollmentRepository;
  private final LessonRepository lessonRepository;
  private final LessonCompletionRepository lessonCompletionRepository;
  private final LearningProgressService learningProgressService;

  public CourseCompletionService(
      final EnrollmentRepository enrollmentRepository,
      final LessonRepository lessonRepository,
      final LessonCompletionRepository lessonCompletionRepository,
      final LearningProgressService learningProgressService) {
    this.enrollmentRepository = enrollmentRepository;
    this.lessonRepository = lessonRepository;
    this.lessonCompletionRepository = lessonCompletionRepository;
    this.learningProgressService = learningProgressService;
  }

  /**
   * Kiểm tra và cập nhật trạng thái hoàn thành khóa học nếu học viên đã học xong toàn bộ bài giảng.
   */
  @Transactional
  public void markCompletedIfDone(final Integer studentId, final Integer courseId) {
    evaluateAndMarkCompletion(studentId, courseId);
  }

  /**
   * Kiểm tra điều kiện hoàn thành và trả về true nếu khóa học vừa được chuyển sang COMPLETED
   * hoặc đã ở trạng thái COMPLETED từ trước.
   */
  @Transactional
  public boolean evaluateAndMarkCompletion(final Integer studentId, final Integer courseId) {
    if (studentId == null || courseId == null) {
      return false;
    }

    final Enrollment enrollment = this.enrollmentRepository
        .findByStudent_UserIdAndCourse_CourseId(studentId, courseId)
        .orElse(null);
    if (enrollment == null) {
      return false;
    }
    if (ENROLLMENT_COMPLETED.equalsIgnoreCase(enrollment.getStatus())) {
      return true;
    }
    if (!ENROLLMENT_ACTIVE.equalsIgnoreCase(enrollment.getStatus())) {
      return false;
    }

    final long totalPublishedLessons = this.lessonRepository
        .countByCourse_CourseIdAndStatus(courseId, PUBLISHED_STATUS);
    final long completedLessons = this.lessonCompletionRepository
        .countByStudent_UserIdAndCourse_CourseId(studentId, courseId);

    if (totalPublishedLessons > 0 && completedLessons >= totalPublishedLessons) {
      enrollment.setStatus(ENROLLMENT_COMPLETED);
      enrollment.setCompletedAt(LocalDateTime.now());
      this.enrollmentRepository.save(enrollment);

      if (this.learningProgressService != null) {
        try {
          this.learningProgressService.recordActivity(
              enrollment.getStudent(),
              enrollment.getCourse(),
              ACTIVITY_COURSE_COMPLETED,
              null,
              null,
              null,
              "Đã hoàn thành tất cả các bài học trong khóa học!"
          );
        } catch (final Exception ignored) {
        }
      }
      return true;
    }
    return false;
  }

  /**
   * Tính phần trăm hoàn thành bài học của học viên trong một khóa học (0 - 100%).
   */
  @Transactional(readOnly = true)
  public int calculateLessonCompletionPercent(final Integer studentId, final Integer courseId) {
    if (studentId == null || courseId == null) {
      return 0;
    }
    final long totalPublished = this.lessonRepository
        .countByCourse_CourseIdAndStatus(courseId, PUBLISHED_STATUS);
    if (totalPublished <= 0L) {
      return 0;
    }
    final long completed = this.lessonCompletionRepository
        .countByStudent_UserIdAndCourse_CourseId(studentId, courseId);
    final double ratio = (completed * 100.0) / totalPublished;
    return (int) Math.min(100, Math.max(0, Math.round(ratio)));
  }

  /**
   * Trả về bản tóm tắt chi tiết tiến độ hoàn thành khóa học của học viên.
   */
  @Transactional(readOnly = true)
  public Map<String, Object> getCourseCompletionSummary(final Integer studentId, final Integer courseId) {
    final Map<String, Object> summary = new LinkedHashMap<>();
    if (studentId == null || courseId == null) {
      summary.put("eligibleForCertificate", Boolean.FALSE);
      summary.put("progressPercent", 0);
      return summary;
    }

    final long totalLessons = this.lessonRepository
        .countByCourse_CourseIdAndStatus(courseId, PUBLISHED_STATUS);
    final long completedLessons = this.lessonCompletionRepository
        .countByStudent_UserIdAndCourse_CourseId(studentId, courseId);
    final long remainingLessons = Math.max(0L, totalLessons - completedLessons);
    final int percent = totalLessons > 0
        ? (int) Math.min(100, Math.round((completedLessons * 100.0) / totalLessons))
        : 0;

    final List<Lesson> publishedList = this.lessonRepository
        .findByCourse_CourseIdAndStatusOrderByOrderIndexAsc(courseId, PUBLISHED_STATUS);
    long totalEstimatedMinutes = 0L;
    if (publishedList != null) {
      for (final Lesson l : publishedList) {
        if (l != null && l.getVideoDuration() != null && l.getVideoDuration() > 0) {
          final int d = l.getVideoDuration();
          totalEstimatedMinutes += (d > 60 ? Math.round(d / 60.0) : d);
        }
      }
    }

    summary.put("courseId", courseId);
    summary.put("studentId", studentId);
    summary.put("totalPublishedLessons", totalLessons);
    summary.put("completedLessons", completedLessons);
    summary.put("remainingLessons", remainingLessons);
    summary.put("progressPercent", percent);
    summary.put("eligibleForCertificate", totalLessons > 0 && completedLessons >= totalLessons);
    summary.put("estimatedCourseMinutes", totalEstimatedMinutes);
    return summary;
  }
}
