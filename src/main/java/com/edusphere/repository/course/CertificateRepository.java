package com.edusphere.repository.course;

import com.edusphere.entity.course.Certificate;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface CertificateRepository extends JpaRepository<Certificate, Integer> {

    Optional<Certificate> findByStudent_UserIdAndCourse_CourseId(Integer studentId, Integer courseId);

    Optional<Certificate> findByVerificationCode(String verificationCode);

    boolean existsByVerificationCode(String verificationCode);

    List<Certificate> findByStudent_UserIdAndStatusOrderByIssuedAtDesc(Integer studentId, String status);

    List<Certificate> findByStudent_UserIdOrderByIssuedAtDesc(Integer studentId);

    long countByCourse_CourseIdAndStatus(Integer courseId, String status);
}
