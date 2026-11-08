package com.edusphere.repository.course;

import com.edusphere.entity.course.PayoutRequest;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface PayoutRequestRepository extends JpaRepository<PayoutRequest, Integer> {

    @Query("SELECT pr FROM PayoutRequest pr JOIN FETCH pr.instructor LEFT JOIN FETCH pr.processedBy WHERE pr.instructor.userId = :instructorId ORDER BY pr.requestedAt DESC")
    List<PayoutRequest> findByInstructorIdOrderByRequestedAtDesc(@Param("instructorId") Integer instructorId);

    @Query("SELECT pr FROM PayoutRequest pr JOIN FETCH pr.instructor LEFT JOIN FETCH pr.processedBy ORDER BY CASE WHEN pr.status = 'PENDING' THEN 0 ELSE 1 END, pr.requestedAt DESC")
    List<PayoutRequest> findAllWithInstructorOrderByPendingFirst();

    @Query("SELECT pr FROM PayoutRequest pr JOIN FETCH pr.instructor LEFT JOIN FETCH pr.processedBy WHERE pr.payoutId = :payoutId")
    Optional<PayoutRequest> findByIdWithDetails(@Param("payoutId") Integer payoutId);
}
