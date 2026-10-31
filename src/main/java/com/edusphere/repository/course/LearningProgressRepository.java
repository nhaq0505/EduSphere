package com.edusphere.repository.course;

import com.edusphere.entity.course.LearningProgress;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface LearningProgressRepository extends JpaRepository<LearningProgress, Integer> {

    Optional<LearningProgress> findByStudent_UserIdAndCourse_CourseId(Integer studentId, Integer courseId);

    List<LearningProgress> findByStudent_UserIdOrderByUpdatedAtDesc(Integer studentId);

    List<LearningProgress> findByCourse_CourseIdOrderByPercentCompleteDesc(Integer courseId);

    List<LearningProgress> findByCourse_CourseId(Integer courseId);
}

