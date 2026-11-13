package com.edusphere.repository.course;

import com.edusphere.entity.course.StudentStudyLog;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

public interface StudentStudyLogRepository extends JpaRepository<StudentStudyLog, Long> {

    Optional<StudentStudyLog> findByStudent_UserIdAndCourse_CourseIdAndStudyDate(
            Integer studentId, Integer courseId, LocalDate studyDate);

    @Query("SELECT COALESCE(SUM(l.durationSeconds), 0) FROM StudentStudyLog l WHERE l.student.userId = :studentId")
    long sumDurationSecondsByStudentId(@Param("studentId") Integer studentId);

    @Query("""
            SELECT l.course.courseId, COALESCE(SUM(l.durationSeconds), 0)
            FROM StudentStudyLog l
            WHERE l.student.userId = :studentId
            GROUP BY l.course.courseId
            """)
    List<Object[]> sumDurationSecondsByStudentIdGroupByCourse(@Param("studentId") Integer studentId);

    @Query("""
            SELECT l.studyDate, COALESCE(SUM(l.durationSeconds), 0)
            FROM StudentStudyLog l
            WHERE l.student.userId = :studentId
              AND l.studyDate >= :startDate
              AND l.studyDate <= :endDate
            GROUP BY l.studyDate
            ORDER BY l.studyDate ASC
            """)
    List<Object[]> sumDailyDurationSeconds(
            @Param("studentId") Integer studentId,
            @Param("startDate") LocalDate startDate,
            @Param("endDate") LocalDate endDate);
}
