package com.edusphere.repository.course;

import com.edusphere.entity.course.Submission;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

public interface SubmissionRepository extends JpaRepository<Submission, Integer> {

    List<Submission> findByAssignment_AssignmentIdOrderBySubmittedAtDesc(Integer assignmentId);

    Optional<Submission> findTopByAssignment_AssignmentIdAndStudent_UserIdOrderByAttemptNumberDesc(
            Integer assignmentId, Integer studentId);

    List<Submission> findByAssignment_AssignmentIdAndStudent_UserId(Integer assignmentId, Integer studentId);

    int countByAssignment_AssignmentIdAndStudent_UserId(Integer assignmentId, Integer studentId);

    List<Submission> findByCourse_CourseIdOrderBySubmittedAtDesc(Integer courseId);

    List<Submission> findByCourse_CourseIdAndStudent_UserIdOrderBySubmittedAtDesc(Integer courseId, Integer studentId);
}
