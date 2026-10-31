package com.edusphere.repository.course;

import com.edusphere.entity.course.PersonalTask;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Repository
public interface PersonalTaskRepository extends JpaRepository<PersonalTask, Integer> {

    List<PersonalTask> findByPlan_PlanIdAndStudent_UserIdOrderByPlannedStartAtAsc(Integer planId, Integer studentId);

    List<PersonalTask> findByStudent_UserIdAndPlannedStartAtBetweenOrderByPlannedStartAtAsc(
            Integer studentId, LocalDateTime from, LocalDateTime to);

    Optional<PersonalTask> findByTaskIdAndStudent_UserId(Integer taskId, Integer studentId);

    long countByPlan_PlanIdAndStatus(Integer planId, String status);

    long countByPlan_PlanId(Integer planId);

    void deleteByPlan_PlanId(Integer planId);
}

