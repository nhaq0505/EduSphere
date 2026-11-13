package com.edusphere.repository.course;

import com.edusphere.entity.course.CourseChangeLog;

import java.time.LocalDateTime;
import java.util.List;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface CourseChangeLogRepository extends JpaRepository<CourseChangeLog, Long> {

    List<CourseChangeLog> findByCourseIdOrderByCreatedAtDesc(Integer courseId);

    List<CourseChangeLog> findTop50ByCourseIdOrderByCreatedAtDesc(Integer courseId);

    List<CourseChangeLog> findByActorIdOrderByCreatedAtDesc(Integer actorId);

    List<CourseChangeLog> findByCourseIdAndParentLessonIdOrderByCreatedAtDesc(Integer courseId, Integer parentLessonId);

    @Query("""
        SELECT l FROM CourseChangeLog l
        WHERE (:courseId IS NULL OR l.courseId = :courseId)
          AND (:teacherId IS NULL OR l.actorId = :teacherId)
          AND (:entityType IS NULL OR :entityType = '' OR l.entityType = :entityType)
          AND (:actionType IS NULL OR :actionType = '' OR l.actionType = :actionType)
          AND (:fromDate IS NULL OR l.createdAt >= :fromDate)
          AND (:toDate IS NULL OR l.createdAt <= :toDate)
          AND (
              :keyword IS NULL OR :keyword = ''
              OR LOWER(l.summary) LIKE LOWER(CONCAT('%', :keyword, '%'))
              OR LOWER(COALESCE(l.courseTitle, '')) LIKE LOWER(CONCAT('%', :keyword, '%'))
              OR LOWER(COALESCE(l.entityTitle, '')) LIKE LOWER(CONCAT('%', :keyword, '%'))
              OR LOWER(COALESCE(l.actorName, '')) LIKE LOWER(CONCAT('%', :keyword, '%'))
              OR LOWER(COALESCE(l.actorEmail, '')) LIKE LOWER(CONCAT('%', :keyword, '%'))
          )
        ORDER BY l.createdAt DESC, l.logId DESC
        """)
    Page<CourseChangeLog> searchLogs(
            @Param("courseId") Integer courseId,
            @Param("teacherId") Integer teacherId,
            @Param("entityType") String entityType,
            @Param("actionType") String actionType,
            @Param("keyword") String keyword,
            @Param("fromDate") LocalDateTime fromDate,
            @Param("toDate") LocalDateTime toDate,
            Pageable pageable);

    long countByCourseId(Integer courseId);

    long countByActorId(Integer actorId);

    long countByEntityType(String entityType);

    long countByActionType(String actionType);
}
