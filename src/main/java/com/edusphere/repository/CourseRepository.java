package com.edusphere.repository;

import com.edusphere.entity.Course;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface CourseRepository extends JpaRepository<Course, Integer> {

    Page<Course> findByStatus(String status, Pageable pageable);

    Page<Course> findByStatusAndTitleContainingIgnoreCase(String status, String title, Pageable pageable);

    List<Course> findByInstructor_UserIdOrderByCreatedAtDesc(Integer instructorId);
}
