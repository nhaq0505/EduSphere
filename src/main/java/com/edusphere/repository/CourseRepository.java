package com.edusphere.repository;

import com.edusphere.entity.Course;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;

import java.util.List;
import java.util.Optional;

public interface CourseRepository extends JpaRepository<Course, Integer>, JpaSpecificationExecutor<Course> {

    Page<Course> findByStatus(String status, Pageable pageable);

    Page<Course> findByStatusAndTitleContainingIgnoreCase(String status, String title, Pageable pageable);

    List<Course> findByInstructor_UserIdOrderByCreatedAtDesc(Integer instructorId);

    Optional<Course> findByCourseIdAndStatus(Integer courseId, String status);
}
