package com.edusphere.entity.course;

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

/** Bài học thuộc một khóa học, được giảng viên quản lý và học viên xem khi công bố. */
@Getter
@Setter
@NoArgsConstructor
@Entity
@Table(name = "lessons")
public class Lesson {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "lesson_id")
    private Integer lessonId;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "course_id", referencedColumnName = "course_id", nullable = false)
    private Course course;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "section_id", referencedColumnName = "section_id")
    private CourseSection section;

    @Column(name = "title", nullable = false, length = 255)
    private String title;

    @Column(name = "lesson_type", length = 20)
    private String lessonType = "ARTICLE";

    @Column(name = "video_url", length = 2048)
    private String videoUrl;

    @Column(name = "video_duration")
    private Integer videoDuration;

    @Column(name = "allow_seek")
    private Boolean allowSeek = true;

    /** Bunny Stream Video GUID — null nếu chưa upload lên Bunny */
    @Column(name = "bunny_video_id", length = 100)
    private String bunnyVideoId;

    /** Trạng thái xử lý video Bunny: UPLOADING / PROCESSING / READY / FAILED */
    @Column(name = "video_status", length = 20)
    private String videoStatus;

    /**
     * Bắt buộc học viên xem đủ ngưỡng video (minWatchPercent%) mới được làm Quiz.
     * true = phải xem đủ, false = không bắt buộc.
     */
    @Column(name = "quiz_requires_video")
    private Boolean quizRequiresVideo = false;

    /**
     * Ngưỡng phần trăm video phải xem tối thiểu (0–100).
     * 0 = không yêu cầu; 100 = phải xem hết.
     * Chỉ có hiệu lực khi quizRequiresVideo = true.
     */
    @Column(name = "min_watch_percent")
    private Integer minWatchPercent = 0;

    @Column(name = "is_preview")
    private Boolean isPreview = false;

    @Column(name = "unlock_days_after_enroll")
    private Integer unlockDaysAfterEnroll;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "prerequisite_lesson_id", referencedColumnName = "lesson_id")
    private Lesson prerequisiteLesson;

    @Column(name = "instructor_notes", columnDefinition = "nvarchar(max)")
    private String instructorNotes;

    @Column(name = "content", columnDefinition = "nvarchar(max)")
    private String content;

    @Column(name = "order_index", nullable = false)
    private Integer orderIndex;

    @Column(name = "status", nullable = false, length = 20)
    private String status = "DRAFT";

    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
}
