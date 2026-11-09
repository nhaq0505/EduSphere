package com.edusphere.entity.course;

import com.edusphere.entity.account.Users;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.PrePersist;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDateTime;

@Getter
@Setter
@NoArgsConstructor
@Entity
@Table(name = "certificates")
public class Certificate {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "certificate_id")
    private Integer certificateId;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "student_id", referencedColumnName = "user_id", nullable = false)
    private Users student;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "course_id", referencedColumnName = "course_id", nullable = false)
    private Course course;

    @Column(name = "verification_code", nullable = false, unique = true, length = 100)
    private String verificationCode;

    @Column(name = "file_url", length = 2048)
    private String fileUrl;

    @Column(name = "issued_at", nullable = false)
    private LocalDateTime issuedAt;

    /** VALID | REVOKED */
    @Column(name = "status", nullable = false, length = 20)
    private String status = "VALID";

    @Column(name = "revoked_at")
    private LocalDateTime revokedAt;

    @Column(name = "revocation_reason", length = 2000)
    private String revocationReason;

    @Column(name = "credits_earned")
    private Integer creditsEarned = 3;

    @Column(name = "grade_percent")
    private Integer gradePercent = 100;

    @Column(name = "total_hours")
    private Integer totalHours = 18;

    @PrePersist
    private void prePersist() {
        if (issuedAt == null) issuedAt = LocalDateTime.now();
        if (status == null) status = "VALID";
        if (creditsEarned == null || creditsEarned <= 0) creditsEarned = 3;
        if (gradePercent == null || gradePercent <= 0) gradePercent = 100;
        if (totalHours == null || totalHours <= 0) totalHours = 18;
    }
}
