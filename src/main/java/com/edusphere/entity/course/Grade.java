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
import jakarta.persistence.OneToOne;
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
@Table(name = "grades")
public class Grade {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "grade_id")
    private Integer gradeId;

    @OneToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "submission_id", referencedColumnName = "submission_id", nullable = false, unique = true)
    private Submission submission;

    @Column(name = "score", nullable = false, precision = 10, scale = 2)
    private BigDecimal score;

    @Column(name = "max_score", nullable = false, precision = 10, scale = 2)
    private BigDecimal maxScore;

    @Column(name = "feedback", columnDefinition = "nvarchar(max)")
    private String feedback;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "graded_by", referencedColumnName = "user_id", nullable = false)
    private Users gradedBy;

    @Column(name = "graded_at", nullable = false)
    private LocalDateTime gradedAt;

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
        if (gradedAt == null) gradedAt = LocalDateTime.now();
    }
}
