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
import jakarta.persistence.Table;
import jakarta.persistence.UniqueConstraint;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDate;
import java.time.LocalDateTime;

/** Nhật ký thời gian học theo ngày / bài học của học viên (phục vụ Dashboard số giờ học). */
@Getter
@Setter
@NoArgsConstructor
@Entity
@Table(name = "study_time_logs",
        uniqueConstraints = @UniqueConstraint(name = "UQ_study_time_logs",
                columnNames = {"student_id", "lesson_id", "study_date"}))
public class StudyTimeLog {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "log_id")
    private Integer logId;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "student_id", referencedColumnName = "user_id", nullable = false)
    private Users student;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "course_id", referencedColumnName = "course_id", nullable = false)
    private Course course;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "lesson_id", referencedColumnName = "lesson_id", nullable = false)
    private Lesson lesson;

    @Column(name = "study_date", nullable = false)
    private LocalDate studyDate;

    @Column(name = "seconds_studied", nullable = false)
    private Integer secondsStudied = 0;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
}
