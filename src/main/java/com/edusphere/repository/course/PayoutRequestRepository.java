package com.edusphere.repository.course;

import com.edusphere.entity.course.PayoutRequest;
import jakarta.persistence.LockModeType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface PayoutRequestRepository extends JpaRepository<PayoutRequest, Integer> {

    /** Lấy danh sách yêu cầu rút tiền của một giảng viên (mới nhất lên đầu). */
    @Query("SELECT pr FROM PayoutRequest pr JOIN FETCH pr.instructor LEFT JOIN FETCH pr.processedBy WHERE pr.instructor.userId = :instructorId ORDER BY pr.requestedAt DESC")
    List<PayoutRequest> findByInstructorIdOrderByRequestedAtDesc(@Param("instructorId") Integer instructorId);

    /** Lấy toàn bộ yêu cầu rút tiền cho Admin (ưu tiên các lệnh PENDING lên đầu). */
    @Query("SELECT pr FROM PayoutRequest pr JOIN FETCH pr.instructor LEFT JOIN FETCH pr.processedBy ORDER BY CASE WHEN pr.status = 'PENDING' THEN 0 ELSE 1 END, pr.requestedAt DESC")
    List<PayoutRequest> findAllWithInstructorOrderByPendingFirst();

    /** Tìm chi tiết một yêu cầu rút tiền theo ID. */
    @Query("SELECT pr FROM PayoutRequest pr JOIN FETCH pr.instructor LEFT JOIN FETCH pr.processedBy WHERE pr.payoutId = :payoutId")
    Optional<PayoutRequest> findByIdWithDetails(@Param("payoutId") Integer payoutId);

    /** Tìm và khóa dòng dữ liệu (Pessimistic Lock) khi Admin duyệt/từ chối để chống xử lý trùng. */
    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("SELECT pr FROM PayoutRequest pr JOIN FETCH pr.instructor LEFT JOIN FETCH pr.processedBy WHERE pr.payoutId = :payoutId")
    Optional<PayoutRequest> findLockedByIdWithDetails(@Param("payoutId") Integer payoutId);
}
