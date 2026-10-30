package com.edusphere.repository.course;

import com.edusphere.entity.course.Quiz;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

public interface QuizRepository extends JpaRepository<Quiz, Integer> {

    List<Quiz> findByCourse_CourseIdOrderByCreatedAtDesc(Integer courseId);

    Optional<Quiz> findByQuizIdAndCourse_CourseId(Integer quizId, Integer courseId);

    List<Quiz> findByCourse_CourseIdAndStatus(Integer courseId, String status);
}
