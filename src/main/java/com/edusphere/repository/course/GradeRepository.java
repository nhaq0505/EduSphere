package com.edusphere.repository.course;

import com.edusphere.entity.course.Grade;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

public interface GradeRepository extends JpaRepository<Grade, Integer> {

    Optional<Grade> findBySubmission_SubmissionId(Integer submissionId);
}
