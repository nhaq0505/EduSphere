package com.edusphere.repository;

import com.edusphere.entity.CourseReview;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface CourseReviewRepository extends JpaRepository<CourseReview, Integer> {

    List<CourseReview> findByCourse_CourseIdOrderByReviewedAtDesc(Integer courseId);
}
