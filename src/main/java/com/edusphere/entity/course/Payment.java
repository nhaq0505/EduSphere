package com.edusphere.entity.course;

import com.edusphere.entity.account.Users;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Getter
@Setter
@NoArgsConstructor
@Entity
@Table(name = "payments")
public class Payment {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "payment_id")
    private Integer paymentId;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "student_id", nullable = false)
    private Users student;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "course_id", nullable = false)
    private Course course;

    @Column(name = "provider", nullable = false, length = 50)
    private String provider = "PAYOS";

    @Column(name = "provider_transaction_id", length = 255)
    private String providerTransactionId;

    @Column(name = "request_key", nullable = false, length = 100, unique = true)
    private String requestKey;

    @Column(name = "checkout_url", length = 2048)
    private String checkoutUrl;

    // Thông tin chuyển khoản PayOS trả về khi tạo link, dùng để hiện mã QR ngay trong trang EduSphere
    @Column(name = "qr_code", length = 1000)
    private String qrCode;

    @Column(name = "bank_bin", length = 20)
    private String bankBin;

    @Column(name = "account_number", length = 50)
    private String accountNumber;

    @Column(name = "account_name", columnDefinition = "nvarchar(150)")
    private String accountName;

    @Column(name = "transfer_note", length = 100)
    private String transferNote;

    @Column(name = "expires_at")
    private LocalDateTime expiresAt;

    @Column(name = "amount", nullable = false, precision = 18, scale = 2)
    private BigDecimal amount;

    @Column(name = "currency", nullable = false, columnDefinition = "char(3)")
    private String currency = "VND";

    @Column(name = "status", nullable = false, length = 20)
    private String status = "INITIATED";

    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt;

    @Column(name = "completed_at")
    private LocalDateTime completedAt;

    @PrePersist
    private void onCreate() {
        if (createdAt == null) createdAt = LocalDateTime.now();
    }
}
