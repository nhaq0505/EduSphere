package com.edusphere.repository.course;

import com.edusphere.entity.course.StudyTimeLog;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

public interface StudyTimeLogRepository extends JpaRepository<StudyTimeLog, Integer> {

    Optional<StudyTimeLog> findByStudent_UserIdAndLesson_LessonIdAndStudyDate(
            Integer studentId, Integer lessonId, LocalDate studyDate);

    /** Mỗi dòng: [studyDate, tổng giây] */
    @Query("SELECT l.studyDate, SUM(l.secondsStudied) FROM StudyTimeLog l " +
           "WHERE l.student.userId = :studentId AND l.studyDate >= :from " +
           "GROUP BY l.studyDate ORDER BY l.studyDate")
    List<Object[]> sumSecondsByDay(@Param("studentId") Integer studentId, @Param("from") LocalDate from);

    /** Mỗi dòng: [courseId, tổng giây] */
    @Query("SELECT l.course.courseId, SUM(l.secondsStudied) FROM StudyTimeLog l " +
           "WHERE l.student.userId = :studentId GROUP BY l.course.courseId")
    List<Object[]> sumSecondsByCourse(@Param("studentId") Integer studentId);

    @Query("SELECT DISTINCT l.studyDate FROM StudyTimeLog l " +
           "WHERE l.student.userId = :studentId AND l.secondsStudied > 0 ORDER BY l.studyDate DESC")
    List<LocalDate> findStudyDates(@Param("studentId") Integer studentId);
}
