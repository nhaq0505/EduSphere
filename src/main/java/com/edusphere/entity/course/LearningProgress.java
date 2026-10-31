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
import jakarta.persistence.UniqueConstraint;

import java.math.BigDecimal;
import java.time.LocalDateTime;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

/**
 * Tiến độ học tập tổng hợp của học viên trong một khóa học (UC37).
 * Được cập nhật tự động mỗi khi học viên hoàn thành bài học.
 * Unique constraint: (student_id, course_id) — mỗi cặp chỉ có một bản ghi.
 */
@Getter
@Setter
@NoArgsConstructor
@Entity
@Table(name = "learning_progress",
       uniqueConstraints = @UniqueConstraint(columnNames = {"student_id", "course_id"}))
public class LearningProgress {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "progress_id")
    private Integer progressId;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "student_id", referencedColumnName = "user_id", nullable = false)
    private Users student;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "course_id", referencedColumnName = "course_id", nullable = false)
    private Course course;

    /** Phần trăm hoàn thành (0–100.00) */
    @Column(name = "percent_complete", nullable = false, precision = 5, scale = 2)
    private BigDecimal percentComplete = BigDecimal.ZERO;

    /** Số bài học đã hoàn thành */
    @Column(name = "completed_lessons", nullable = false)
    private Integer completedLessons = 0;

    /** Tổng số bài học đã công bố trong khóa */
    @Column(name = "total_lessons", nullable = false)
    private Integer totalLessons = 0;

    /** Thời điểm học viên truy cập bài học gần nhất */
    @Column(name = "last_accessed_at")
    private LocalDateTime lastAccessedAt;

    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;

    @PrePersist
    @PreUpdate
    private void onUpdate() {
        updatedAt = LocalDateTime.now();
    }
}

