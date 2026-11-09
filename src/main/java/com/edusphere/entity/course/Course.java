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

import java.math.BigDecimal;
import java.time.LocalDateTime;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@Entity
@Table(name = "courses")
public class Course {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "course_id")
    private Integer courseId;

    @Column(name = "title", nullable = false, length = 255)
    private String title;

    @Column(name = "description", columnDefinition = "nvarchar(max)")
    private String description;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "category_id", referencedColumnName = "category_id")
    private Category category;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "instructor_id", referencedColumnName = "user_id", nullable = false)
    private Users instructor;

    @Column(name = "level", nullable = false, length = 20)
    private String level = "ALL_LEVELS";

    @Column(name = "price", nullable = false, precision = 18, scale = 2)
    private BigDecimal price = BigDecimal.ZERO;

    /** Số tín chỉ của khóa học (mặc định 3 tín chỉ) */
    @Column(name = "credits", nullable = false)
    private Integer credits = 3;

    @Column(name = "currency", nullable = false, columnDefinition = "char(3)")
    private String currency = "VND";

    @Column(name = "thumbnail_url", length = 2048)
    private String thumbnailUrl;

    /** Video giới thiệu khóa học (Promo video / Trailer) */
    @Column(name = "promo_video_url", length = 2048)
    private String promoVideoUrl;

    /** Mục tiêu đầu ra (What students will learn) */
    @Column(name = "objectives", columnDefinition = "nvarchar(max)")
    private String objectives;

    /** Yêu cầu đầu vào (Requirements / Prerequisites) */
    @Column(name = "requirements", columnDefinition = "nvarchar(max)")
    private String requirements;

    @Column(name = "status", nullable = false, length = 20)
    private String status = "DRAFT";

    @Column(name = "version_no", nullable = false)
    private Integer versionNo = 1;

    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    @Column(name = "submitted_at")
    private LocalDateTime submittedAt;

    @Column(name = "approved_at")
    private LocalDateTime approvedAt;

    @Column(name = "published_at")
    private LocalDateTime publishedAt;

    @Column(name = "archived_at")
    private LocalDateTime archivedAt;

    /** Chú thích thay đổi từ Instructor khi gửi duyệt lại (UPDATING → SUBMITTED) */
    @Column(name = "change_note", columnDefinition = "nvarchar(2000)")
    private String changeNote;

    @jakarta.persistence.PrePersist
    private void setCreatedAt() {
        if (createdAt == null) createdAt = LocalDateTime.now();
        if (credits == null || credits <= 0) credits = 3;
    }
}
