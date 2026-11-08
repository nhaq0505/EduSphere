package com.edusphere.repository.course;

import com.edusphere.entity.course.QuestionBank;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface QuestionBankRepository extends JpaRepository<QuestionBank, Integer> {

    List<QuestionBank> findByInstructor_UserIdOrderByCreatedAtDesc(Integer instructorId);

    List<QuestionBank> findByInstructor_UserIdAndStatusOrderByCreatedAtDesc(Integer instructorId, String status);

    Optional<QuestionBank> findByBankIdAndInstructor_UserId(Integer bankId, Integer instructorId);

    long countByInstructor_UserId(Integer instructorId);
}

