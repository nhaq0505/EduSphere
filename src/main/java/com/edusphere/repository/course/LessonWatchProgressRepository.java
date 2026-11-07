package com.edusphere.repository.course;

import com.edusphere.entity.course.LessonWatchProgress;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.Optional;

@Repository
public interface LessonWatchProgressRepository extends JpaRepository<LessonWatchProgress, Integer> {

    Optional<LessonWatchProgress> findByStudent_UserIdAndLesson_LessonId(
            Integer studentId, Integer lessonId);
}
