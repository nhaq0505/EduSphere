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
@Table(name = "quizzes")
public class Quiz {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "quiz_id")
    private Integer quizId;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "course_id", referencedColumnName = "course_id", nullable = false)
    private Course course;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "lesson_id", referencedColumnName = "lesson_id")
    private Lesson lesson;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "bank_id", referencedColumnName = "bank_id")
    private QuestionBank bank;

    @Column(name = "title", nullable = false, length = 255, columnDefinition = "nvarchar(255)")
    private String title;

    @Column(name = "description", columnDefinition = "nvarchar(max)")
    private String description;

    @Column(name = "time_limit_minutes")
    private Integer timeLimitMinutes;

    @Column(name = "max_attempts", nullable = false)
    private Integer maxAttempts = 999;

    @Column(name = "start_time")
    private LocalDateTime startTime;

    @Column(name = "due_date")
    private LocalDateTime dueDate;

    @Column(name = "end_time")
    private LocalDateTime endTime;

    @Column(name = "rules", columnDefinition = "nvarchar(max)")
    private String rules;

    /** Điểm tối thiểu để qua bài (% tổng điểm, ví dụ 50.0 = 50%). null = không yêu cầu. */
    @Column(name = "passing_score", precision = 5, scale = 2)
    private java.math.BigDecimal passingScore;

    /** Xáo trộn thứ tự câu hỏi */
    @Column(name = "shuffle_questions", nullable = false)
    private boolean shuffleQuestions = false;

    /** Xáo trộn thứ tự đáp án */
    @Column(name = "shuffle_options", nullable = false)
    private boolean shuffleOptions = false;

    /** DRAFT / PUBLISHED / ARCHIVED */
    @Column(name = "status", nullable = false, length = 20)
    private String status = "DRAFT";

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "created_by", referencedColumnName = "user_id", nullable = false)
    private Users createdBy;

    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt;

    @PrePersist
    private void onCreate() {
        if (createdAt == null) createdAt = LocalDateTime.now();
    }
}
