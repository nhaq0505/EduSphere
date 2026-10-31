package com.edusphere.repository.course;

import com.edusphere.entity.course.StudyPlan;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface StudyPlanRepository extends JpaRepository<StudyPlan, Integer> {

    List<StudyPlan> findByStudent_UserIdOrderByCreatedAtDesc(Integer studentId);

    List<StudyPlan> findByStudent_UserIdAndStatus(Integer studentId, String status);

    Optional<StudyPlan> findByPlanIdAndStudent_UserId(Integer planId, Integer studentId);
}

