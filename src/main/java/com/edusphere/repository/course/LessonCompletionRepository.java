package com.edusphere.repository.course;

import com.edusphere.entity.course.LessonCompletion;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface LessonCompletionRepository extends JpaRepository<LessonCompletion, Integer> {

    boolean existsByStudent_UserIdAndLesson_LessonId(Integer studentId, Integer lessonId);

    Optional<LessonCompletion> findByStudent_UserIdAndLesson_LessonId(Integer studentId, Integer lessonId);

    List<LessonCompletion> findByStudent_UserIdAndCourse_CourseId(Integer studentId, Integer courseId);

    long countByStudent_UserIdAndCourse_CourseId(Integer studentId, Integer courseId);

    void deleteByLesson_LessonId(Integer lessonId);
}
