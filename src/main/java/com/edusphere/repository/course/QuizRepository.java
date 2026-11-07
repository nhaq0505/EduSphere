package com.edusphere.repository.course;

import com.edusphere.entity.course.Quiz;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

public interface QuizRepository extends JpaRepository<Quiz, Integer> {

    List<Quiz> findByCourse_CourseIdOrderByCreatedAtDesc(Integer courseId);

    Optional<Quiz> findByQuizIdAndCourse_CourseId(Integer quizId, Integer courseId);

    List<Quiz> findByCourse_CourseIdAndStatus(Integer courseId, String status);

    /** Lấy quiz PUBLISHED gắn với lesson cụ thể */
    List<Quiz> findByCourse_CourseIdAndLesson_LessonIdAndStatus(
            Integer courseId, Integer lessonId, String status);

    List<Quiz> findByLesson_LessonId(Integer lessonId);

    @org.springframework.data.jpa.repository.Modifying
    @org.springframework.data.jpa.repository.Query("UPDATE Quiz q SET q.bank = null WHERE q.bank.bankId = :bankId")
    void detachBank(@org.springframework.data.repository.query.Param("bankId") Integer bankId);
}
