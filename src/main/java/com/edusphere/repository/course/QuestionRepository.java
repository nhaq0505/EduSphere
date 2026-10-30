package com.edusphere.repository.course;

import com.edusphere.entity.course.Question;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

public interface QuestionRepository extends JpaRepository<Question, Integer> {

    List<Question> findByQuiz_QuizIdOrderByOrderIndexAsc(Integer quizId);

    long countByQuiz_QuizId(Integer quizId);
}
