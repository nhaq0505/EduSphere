package com.edusphere.repository.course;

import com.edusphere.entity.course.Lesson;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

public interface LessonRepository extends JpaRepository<Lesson, Integer> {

    List<Lesson> findByCourse_CourseIdAndStatusOrderByOrderIndexAsc(Integer courseId, String status);

    Optional<Lesson> findByLessonIdAndCourse_CourseIdAndStatus(Integer lessonId, Integer courseId, String status);

    Optional<Lesson> findByLessonIdAndCourse_CourseId(Integer lessonId, Integer courseId);

    List<Lesson> findByCourse_CourseIdOrderByOrderIndexAsc(Integer courseId);

    long countByCourse_CourseId(Integer courseId);
}
