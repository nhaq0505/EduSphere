package com.edusphere.repository.course;

import com.edusphere.entity.course.LessonAiMaterial;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface LessonAiMaterialRepository extends JpaRepository<LessonAiMaterial, Integer> {

    /**
     * Tìm tài liệu AI theo lessonId
     */
    Optional<LessonAiMaterial> findByLesson_LessonId(Integer lessonId);

    /**
     * Tìm tài liệu AI theo taskId của Python service
     */
    Optional<LessonAiMaterial> findByTaskId(String taskId);

    /**
     * Kiểm tra xem bài học đã có tài liệu AI chưa
     */
    boolean existsByLesson_LessonId(Integer lessonId);

    /**
     * Xóa tài liệu AI theo lessonId
     */
    void deleteByLesson_LessonId(Integer lessonId);
}

