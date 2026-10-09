package com.edusphere.repository;

import com.edusphere.entity.Enrollment;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface EnrollmentRepository extends JpaRepository<Enrollment, Integer> {

    Optional<Enrollment> findByStudent_UserIdAndCourse_CourseId(Integer studentId, Integer courseId);

    boolean existsByStudent_UserIdAndCourse_CourseId(Integer studentId, Integer courseId);

    List<Enrollment> findByStudent_UserIdOrderByEnrolledAtDesc(Integer studentId);
}
