package com.edusphere.service.course;

import com.edusphere.entity.account.Users;
import com.edusphere.entity.course.Enrollment;
import com.edusphere.entity.course.Lesson;
import com.edusphere.entity.course.StudyTimeLog;
import com.edusphere.repository.account.UserRepository;
import com.edusphere.repository.course.EnrollmentRepository;
import com.edusphere.repository.course.LessonRepository;
import com.edusphere.repository.course.StudyTimeLogRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;

/** Ghi nhận thời gian học (giây) theo ngày để thống kê số giờ học trên Dashboard. */
@Service
public class StudyTimeService {

    /** Giới hạn mỗi lần ghi nhận để chống gian lận (ping ~5s, cho phép tối đa 60s). */
    private static final int MAX_SECONDS_PER_RECORD = 60;

    private final StudyTimeLogRepository logRepository;
    private final EnrollmentRepository enrollmentRepository;
    private final LessonRepository lessonRepository;
    private final UserRepository userRepository;

    public StudyTimeService(StudyTimeLogRepository logRepository,
                            EnrollmentRepository enrollmentRepository,
                            LessonRepository lessonRepository,
                            UserRepository userRepository) {
        this.logRepository = logRepository;
        this.enrollmentRepository = enrollmentRepository;
        this.lessonRepository = lessonRepository;
        this.userRepository = userRepository;
    }

    /** Ghi nhận thêm {@code seconds} giây học cho (học viên, bài học) trong ngày hôm nay. */
    @Transactional
    public void record(Integer studentId, Integer courseId, Integer lessonId, int seconds) {
        if (studentId == null || courseId == null || lessonId == null || seconds <= 0) {
            return;
        }
        int add = Math.min(seconds, MAX_SECONDS_PER_RECORD);

        // Chỉ ghi nhận cho học viên đã ghi danh (không tính giảng viên xem trước)
        Enrollment enrollment = enrollmentRepository
                .findByStudent_UserIdAndCourse_CourseId(studentId, courseId).orElse(null);
        if (enrollment == null || "DROPPED".equalsIgnoreCase(enrollment.getStatus())) {
            return;
        }

        LocalDate today = LocalDate.now();
        StudyTimeLog log = logRepository
                .findByStudent_UserIdAndLesson_LessonIdAndStudyDate(studentId, lessonId, today)
                .orElse(null);
        if (log == null) {
            Lesson lesson = lessonRepository.findByLessonIdAndCourse_CourseId(lessonId, courseId).orElse(null);
            Users student = userRepository.findById(studentId).orElse(null);
            if (lesson == null || student == null) {
                return;
            }
            log = new StudyTimeLog();
            log.setStudent(student);
            log.setCourse(lesson.getCourse());
            log.setLesson(lesson);
            log.setStudyDate(today);
            log.setSecondsStudied(0);
        }
        log.setSecondsStudied(log.getSecondsStudied() + add);
        log.setUpdatedAt(LocalDateTime.now());
        logRepository.save(log);
    }
}
