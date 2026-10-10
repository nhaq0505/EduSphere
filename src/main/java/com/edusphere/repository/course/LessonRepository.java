package com.edusphere.repository.course;

import com.edusphere.entity.course.Lesson;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

public interface LessonRepository extends JpaRepository<Lesson, Integer> {

    List<Lesson> findByCourse_CourseIdAndStatusOrderByOrderIndexAsc(Integer courseId, String status);
}
