package com.edusphere.repository.course;

import com.edusphere.entity.course.QuizAnswer;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

public interface QuizAnswerRepository extends JpaRepository<QuizAnswer, Integer> {

    List<QuizAnswer> findByAttempt_AttemptIdOrderByQuestion_OrderIndexAsc(Integer attemptId);

    List<QuizAnswer> findByQuestion_QuestionId(Integer questionId);

    void deleteByQuestion_QuestionId(Integer questionId);
}
