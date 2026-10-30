package com.edusphere.repository.course;

import com.edusphere.entity.course.AnswerOption;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

public interface AnswerOptionRepository extends JpaRepository<AnswerOption, Integer> {

    List<AnswerOption> findByQuestion_QuestionIdOrderByOrderIndexAsc(Integer questionId);
}
