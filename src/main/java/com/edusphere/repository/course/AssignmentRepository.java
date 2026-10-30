package com.edusphere.repository.course;

import com.edusphere.entity.course.Assignment;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

public interface AssignmentRepository extends JpaRepository<Assignment, Integer> {

    List<Assignment> findByCourse_CourseIdAndStatusOrderByDueDateAsc(Integer courseId, String status);

    List<Assignment> findByCourse_CourseIdOrderByCreatedAtDesc(Integer courseId);

    Optional<Assignment> findByAssignmentIdAndCourse_CourseId(Integer assignmentId, Integer courseId);
}
