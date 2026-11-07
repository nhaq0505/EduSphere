package com.edusphere.entity.course;

import com.edusphere.entity.account.Users;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import java.time.LocalDateTime;

/**
 * Lưu tiến độ xem video của từng học viên cho từng bài học.
 * Unique constraint: (student_id, lesson_id) — một bản ghi duy nhất, được UPSERT mỗi khi học viên gửi progress.
 */
@Getter
@Setter
@NoArgsConstructor
@Entity
@Table(name = "lesson_watch_progress",
       uniqueConstraints = @UniqueConstraint(columnNames = {"student_id", "lesson_id"}))
public class LessonWatchProgress {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "watch_id")
    private Integer watchId;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "student_id", referencedColumnName = "user_id", nullable = false)
    private Users student;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "course_id", referencedColumnName = "course_id", nullable = false)
    private Course course;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "lesson_id", referencedColumnName = "lesson_id", nullable = false)
    private Lesson lesson;

    /** Phần trăm video đã xem (0–100) */
    @Column(name = "watch_percent", nullable = false)
    private Integer watchPercent = 0;

    /** Vị trí dừng lại gần nhất (giây) — để restore khi quay lại */
    @Column(name = "last_position", nullable = false)
    private Integer lastPosition = 0;

    /** Các khoảng thời gian video đã xem dưới dạng JSON string, ví dụ: "[[0,20],[25,45]]" */
    @Column(name = "watched_segments", columnDefinition = "nvarchar(max)")
    private String watchedSegments = "[]";

    /** Trạng thái mở khóa Quiz (true khi đã xem đủ >= 80% thời lượng video) */
    @Column(name = "quiz_unlocked", nullable = false)
    private Boolean quizUnlocked = false;

    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;

    @PrePersist
    @PreUpdate
    private void onUpdate() {
        updatedAt = LocalDateTime.now();
    }
}
