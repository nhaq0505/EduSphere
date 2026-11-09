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

import java.time.LocalDateTime;

/**
 * Thực thể lưu đánh giá sao (1–5 sao) và nhận xét của học viên đối với khóa học.
 * Mỗi học viên chỉ có tối đa 1 bản ghi đánh giá trên mỗi khóa học (có thể cập nhật lại).
 */
@Getter
@Setter
@NoArgsConstructor
@Entity
@Table(
    name = "course_ratings",
    uniqueConstraints = @UniqueConstraint(
        name = "UQ_course_ratings_course_student",
        columnNames = {"course_id", "student_id"}
    )
)
public class CourseRating {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "rating_id")
    private Integer ratingId;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "course_id", referencedColumnName = "course_id", nullable = false)
    private Course course;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "student_id", referencedColumnName = "user_id", nullable = false)
    private Users student;

    /** Số sao đánh giá từ 1 đến 5 */
    @Column(name = "rating", nullable = false)
    private Integer rating;

    /** Nhận xét chi tiết của học viên */
    @Column(name = "comment", length = 2000, columnDefinition = "nvarchar(2000)")
    private String comment;

    /** Phản hồi từ giảng viên (nếu có) */
    @Column(name = "instructor_reply", length = 2000, columnDefinition = "nvarchar(2000)")
    private String instructorReply;

    @Column(name = "replied_at")
    private LocalDateTime repliedAt;

    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    @PrePersist
    protected void onCreate() {
        if (createdAt == null) {
            createdAt = LocalDateTime.now();
        }
    }

    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }
}
