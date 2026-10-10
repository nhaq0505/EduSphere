package com.edusphere.repository.course;

import com.edusphere.entity.course.CourseReview;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

public interface CourseReviewRepository extends JpaRepository<CourseReview, Integer> {

    List<CourseReview> findByCourse_CourseIdOrderByReviewedAtDesc(Integer courseId);

    Optional<CourseReview> findFirstByCourse_CourseIdOrderByReviewedAtDescReviewIdDesc(Integer courseId);
}
