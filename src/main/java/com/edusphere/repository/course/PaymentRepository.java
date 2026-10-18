package com.edusphere.repository.course;

import com.edusphere.entity.course.Payment;
import jakarta.persistence.LockModeType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Optional;

public interface PaymentRepository extends JpaRepository<Payment, Integer> {
    Optional<Payment> findFirstByStudent_UserIdAndCourse_CourseIdAndStatusOrderByCreatedAtDesc(
            Integer studentId, Integer courseId, String status);

    Optional<Payment> findByRequestKey(String requestKey);

    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("select payment from Payment payment join fetch payment.student join fetch payment.course where payment.paymentId = :id")
    Optional<Payment> findLockedById(@Param("id") Integer id);

    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("select payment from Payment payment join fetch payment.student join fetch payment.course where payment.requestKey = :requestKey")
    Optional<Payment> findLockedByRequestKey(@Param("requestKey") String requestKey);
}
