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

import java.time.LocalDateTime;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

/**
 * Nhiệm vụ học tập cá nhân của học viên trong một kế hoạch (UC35).
 * Không ảnh hưởng đến due_date / unlock_at / lock_at chính thức.
 * status: TODO | IN_PROGRESS | DONE | CANCELLED | PENDING | SKIPPED
 */
@Getter
@Setter
@NoArgsConstructor
@Entity
@Table(name = "personal_tasks")
public class PersonalTask {

    public static final String STATUS_TODO = "TODO";
    public static final String STATUS_IN_PROGRESS = "IN_PROGRESS";
    public static final String STATUS_DONE = "DONE";
    public static final String STATUS_CANCELLED = "CANCELLED";
    public static final String STATUS_PENDING = "PENDING";
    public static final String STATUS_SKIPPED = "SKIPPED";

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "task_id")
    private Integer taskId;

    /** Kế hoạch cha chứa nhiệm vụ này */
    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "plan_id", referencedColumnName = "plan_id", nullable = false)
    private StudyPlan plan;

    /** Học viên sở hữu nhiệm vụ này */
    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "student_id", referencedColumnName = "user_id", nullable = false)
    private Users student;

    @Column(name = "title", nullable = false, length = 255, columnDefinition = "nvarchar(255)")
    private String title;

    @Column(name = "notes", columnDefinition = "nvarchar(max)")
    private String notes;

    /** Khóa học liên quan (tuỳ chọn) */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "course_id", referencedColumnName = "course_id")
    private Course course;

    /** Bài học liên quan (tuỳ chọn) — KHÔNG thay đổi official due date */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "related_lesson_id", referencedColumnName = "lesson_id")
    private Lesson relatedLesson;

    /** Bài tập liên quan (tuỳ chọn) — KHÔNG thay đổi official due date */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "related_assignment_id", referencedColumnName = "assignment_id")
    private Assignment relatedAssignment;

    /** Quiz liên quan (tuỳ chọn) — KHÔNG thay đổi official due date */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "related_quiz_id", referencedColumnName = "quiz_id")
    private Quiz relatedQuiz;

    /** Thời điểm bắt đầu lịch cá nhân (KHÔNG phải official unlock_at) */
    @Column(name = "planned_start_at", nullable = false)
    private LocalDateTime plannedStartAt;

    /** Thời điểm kết thúc lịch cá nhân (KHÔNG phải official due_date / lock_at) */
    @Column(name = "planned_end_at", nullable = false)
    private LocalDateTime plannedEndAt;

    /** TODO / IN_PROGRESS / DONE / CANCELLED / PENDING / SKIPPED */
    @Column(name = "status", nullable = false, length = 20)
    private String status = STATUS_TODO;

    @Column(name = "completed_at")
    private LocalDateTime completedAt;
}

