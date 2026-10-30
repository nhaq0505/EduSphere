package com.edusphere.repository.course;

import com.edusphere.entity.course.QuizAttempt;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface QuizAttemptRepository extends JpaRepository<QuizAttempt, Integer> {

    List<QuizAttempt> findByQuiz_QuizIdAndStudent_UserIdOrderByAttemptNumberDesc(Integer quizId, Integer studentId);

    Optional<QuizAttempt> findByAttemptIdAndStudent_UserId(Integer attemptId, Integer studentId);

    int countByQuiz_QuizIdAndStudent_UserId(Integer quizId, Integer studentId);

    Optional<QuizAttempt> findFirstByQuiz_QuizIdAndStudent_UserIdAndStatus(
            Integer quizId, Integer studentId, String status);

    @Query("SELECT a FROM QuizAttempt a WHERE a.quiz.quizId = :quizId ORDER BY a.student.userId ASC, a.attemptNumber DESC")
    List<QuizAttempt> findByQuizIdOrderByStudentAndAttempt(@Param("quizId") Integer quizId);

    List<QuizAttempt> findByCourse_CourseIdAndStatusInOrderBySubmittedAtDesc(
            Integer courseId, java.util.Collection<String> statuses);

    List<QuizAttempt> findByCourse_CourseIdAndStudent_UserIdAndStatusInOrderBySubmittedAtDesc(
            Integer courseId, Integer studentId, java.util.Collection<String> statuses);
}
