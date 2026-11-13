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
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * Lưu thời lượng học tập hàng ngày (tính bằng giây) của từng học viên theo từng khóa học.
 * Dùng để thống kê tổng số giờ học và biểu đồ học tập trên Student Dashboard.
 */
@Getter
@Setter
@NoArgsConstructor
@Entity
@Table(name = "student_study_logs",
       uniqueConstraints = @UniqueConstraint(columnNames = {"student_id", "course_id", "study_date"}))
public class StudentStudyLog {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "log_id")
    private Long logId;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "student_id", referencedColumnName = "user_id", nullable = false)
    private Users student;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "course_id", referencedColumnName = "course_id", nullable = false)
    private Course course;

    @Column(name = "study_date", nullable = false)
    private LocalDate studyDate;

    @Column(name = "duration_seconds", nullable = false)
    private Integer durationSeconds = 0;

    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;

    @PrePersist
    @PreUpdate
    private void onSave() {
        updatedAt = LocalDateTime.now();
        if (studyDate == null) {
            studyDate = LocalDate.now();
        }
        if (durationSeconds == null || durationSeconds < 0) {
            durationSeconds = 0;
        }
    }
}
