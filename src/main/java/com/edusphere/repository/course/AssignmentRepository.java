package com.edusphere.repository.course;

import com.edusphere.entity.course.Assignment;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

public interface AssignmentRepository extends JpaRepository<Assignment, Integer> {

    List<Assignment> findByCourse_CourseIdAndStatusOrderByDueDateAsc(Integer courseId, String status);

    List<Assignment> findByCourse_CourseIdOrderByCreatedAtDesc(Integer courseId);

    Optional<Assignment> findByAssignmentIdAndCourse_CourseId(Integer assignmentId, Integer courseId);

    /** Lấy tất cả assignment PUBLISHED gắn với một lesson cụ thể */
    List<Assignment> findByCourse_CourseIdAndLesson_LessonIdAndStatusOrderByDueDateAsc(
            Integer courseId, Integer lessonId, String status);

    List<Assignment> findByLesson_LessonId(Integer lessonId);
}
