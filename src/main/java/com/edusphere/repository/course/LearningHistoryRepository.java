package com.edusphere.repository.course;

import com.edusphere.entity.course.LearningHistory;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface LearningHistoryRepository extends JpaRepository<LearningHistory, Long> {

    List<LearningHistory> findByStudent_UserIdOrderByOccurredAtDesc(Integer studentId);

    List<LearningHistory> findByStudent_UserIdAndCourse_CourseIdOrderByOccurredAtDesc(Integer studentId, Integer courseId);

    Page<LearningHistory> findByStudent_UserIdOrderByOccurredAtDesc(Integer studentId, Pageable pageable);

    void deleteByLesson_LessonId(Integer lessonId);
}

