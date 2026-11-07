package com.edusphere.repository.course;

import com.edusphere.entity.course.Question;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface QuestionRepository extends JpaRepository<Question, Integer> {

    List<Question> findByQuiz_QuizIdOrderByOrderIndexAsc(Integer quizId);

    long countByQuiz_QuizId(Integer quizId);

    @Modifying
    @Query("UPDATE Question q SET q.bankQuestion = null WHERE q.bankQuestion.bankQuestionId = :bankQuestionId")
    void detachBankQuestion(@Param("bankQuestionId") Integer bankQuestionId);

    @Modifying
    @Query("UPDATE Question q SET q.bankQuestion = null WHERE q.bankQuestion.bank.bankId = :bankId")
    void detachBank(@Param("bankId") Integer bankId);
}
