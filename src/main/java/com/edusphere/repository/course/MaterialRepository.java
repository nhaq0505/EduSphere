package com.edusphere.repository.course;

import com.edusphere.entity.course.Material;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface MaterialRepository extends JpaRepository<Material, Integer> {

    List<Material> findByLesson_LessonIdOrderByOrderIndexAsc(Integer lessonId);

    void deleteByLesson_LessonId(Integer lessonId);
}
