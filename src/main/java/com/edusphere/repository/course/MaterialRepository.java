package com.edusphere.repository.course;

import com.edusphere.entity.course.Material;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface MaterialRepository extends JpaRepository<Material, Integer> {

    List<Material> findByLesson_LessonIdOrderByOrderIndexAsc(Integer lessonId);
}
