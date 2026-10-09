package com.edusphere.repository;

import com.edusphere.entity.Lesson;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface LessonRepository extends JpaRepository<Lesson, Integer> {

    List<Lesson> findByCourse_CourseIdAndStatusOrderByOrderIndexAsc(Integer courseId, String status);
}
