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
import jakarta.persistence.PreUpdate;
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
@Table(name = "assignments")
public class Assignment {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "assignment_id")
    private Integer assignmentId;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "course_id", referencedColumnName = "course_id", nullable = false)
    private Course course;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "lesson_id", referencedColumnName = "lesson_id")
    private Lesson lesson;

    @Column(name = "title", nullable = false, length = 255, columnDefinition = "nvarchar(255)")
    private String title;

    @Column(name = "description", columnDefinition = "nvarchar(max)")
    private String description;

    @Column(name = "unlock_at")
    private LocalDateTime unlockAt;

    @Column(name = "due_date", nullable = false)
    private LocalDateTime dueDate;

    @Column(name = "lock_at")
    private LocalDateTime lockAt;

    @Column(name = "max_score", nullable = false, precision = 10, scale = 2)
    private BigDecimal maxScore = BigDecimal.valueOf(100);

    @Column(name = "allow_resubmit", nullable = false)
    private boolean allowResubmit = false;

    @Column(name = "max_attempts", nullable = false)
    private Integer maxAttempts = 1;

    /** DRAFT / PUBLISHED / ARCHIVED */
    @Column(name = "status", nullable = false, length = 20)
    private String status = "DRAFT";

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "created_by", referencedColumnName = "user_id", nullable = false)
    private Users createdBy;

    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    @PrePersist
    private void onCreate() {
        if (createdAt == null) createdAt = LocalDateTime.now();
    }

    @PreUpdate
    private void onUpdate() {
        updatedAt = LocalDateTime.now();
    }
}
