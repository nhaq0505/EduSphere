package com.edusphere.repository.course;

import com.edusphere.entity.course.Enrollment;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

public interface EnrollmentRepository extends JpaRepository<Enrollment, Integer> {

    Optional<Enrollment> findByStudent_UserIdAndCourse_CourseId(Integer studentId, Integer courseId);

    boolean existsByStudent_UserIdAndCourse_CourseId(Integer studentId, Integer courseId);

    List<Enrollment> findByStudent_UserIdOrderByEnrolledAtDesc(Integer studentId);

    List<Enrollment> findByCourse_CourseIdAndStatus(Integer courseId, String status);

    List<Enrollment> findByCourse_CourseIdOrderByEnrolledAtDesc(Integer courseId);
}
