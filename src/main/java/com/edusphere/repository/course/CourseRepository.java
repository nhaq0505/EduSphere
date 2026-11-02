package com.edusphere.repository.course;

import com.edusphere.entity.course.Course;

import jakarta.persistence.LockModeType;

import java.util.List;
import java.util.Optional;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface CourseRepository extends JpaRepository<Course, Integer>, JpaSpecificationExecutor<Course> {

    Page<Course> findByStatus(String status, Pageable pageable);

    Page<Course> findByStatusAndTitleContainingIgnoreCase(String status, String title, Pageable pageable);

    List<Course> findByInstructor_UserIdOrderByCreatedAtDesc(Integer instructorId);

    Optional<Course> findByCourseIdAndStatus(Integer courseId, String status);

    List<Course> findByStatusOrderBySubmittedAtAsc(String status);

    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("select course from Course course where course.courseId = :id")
    Optional<Course> findLockedById(@Param("id") Integer id);

    @Query("select c from Course c where c.courseId = :courseId and (c.status in ('PUBLISHED', 'UPDATING') or (c.status = 'SUBMITTED' and c.publishedAt is not null))")
    Optional<Course> findPublicCourseById(@Param("courseId") Integer courseId);
}
