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

import java.math.BigDecimal;
import java.time.LocalDateTime;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@Entity
@Table(name = "quiz_attempts")
public class QuizAttempt {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "attempt_id")
    private Integer attemptId;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "quiz_id", referencedColumnName = "quiz_id", nullable = false)
    private Quiz quiz;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "student_id", referencedColumnName = "user_id", nullable = false)
    private Users student;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "course_id", referencedColumnName = "course_id", nullable = false)
    private Course course;

    @Column(name = "attempt_number", nullable = false)
    private Integer attemptNumber = 1;

    @Column(name = "started_at", nullable = false)
    private LocalDateTime startedAt;

    @Column(name = "deadline_at")
    private LocalDateTime deadlineAt;

    @Column(name = "submitted_at")
    private LocalDateTime submittedAt;

    /** IN_PROGRESS / SUBMITTED / SCORED / ABANDONED */
    @Column(name = "status", nullable = false, length = 20)
    private String status = "IN_PROGRESS";

    @Column(name = "score", precision = 10, scale = 2)
    private BigDecimal score;

    @Column(name = "max_score", nullable = false, precision = 10, scale = 2)
    private BigDecimal maxScore = BigDecimal.ZERO;

    /** UNPUBLISHED / PUBLISHED */
    @Column(name = "result_status", nullable = false, length = 20)
    private String resultStatus = "UNPUBLISHED";

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "published_by", referencedColumnName = "user_id")
    private Users publishedBy;

    @Column(name = "published_at")
    private LocalDateTime publishedAt;

    @PrePersist
    private void onCreate() {
        if (startedAt == null) startedAt = LocalDateTime.now();
    }
}
