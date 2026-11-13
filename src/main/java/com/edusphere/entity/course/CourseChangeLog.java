package com.edusphere.entity.course;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.PrePersist;
import jakarta.persistence.Table;

import java.time.LocalDateTime;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

/**
 * Lưu lịch sử toàn bộ thay đổi nội dung khóa học (Course, Chapter, Lesson, Video, Document, Quiz, Question)
 * để ADMIN theo dõi, đối chiếu dữ liệu trước/sau (Before/After) và kiểm duyệt.
 */
@Getter
@Setter
@NoArgsConstructor
@Entity
@Table(name = "course_change_logs")
public class CourseChangeLog {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "log_id")
    private Long logId;

    @Column(name = "course_id", nullable = false)
    private Integer courseId;

    @Column(name = "course_title", length = 255, columnDefinition = "nvarchar(255)")
    private String courseTitle;

    @Column(name = "actor_id", nullable = false)
    private Integer actorId;

    @Column(name = "actor_name", length = 255, columnDefinition = "nvarchar(255)")
    private String actorName;

    @Column(name = "actor_email", length = 255, columnDefinition = "nvarchar(255)")
    private String actorEmail;

    @Column(name = "actor_role", length = 30, columnDefinition = "nvarchar(30)")
    private String actorRole = "INSTRUCTOR";

    /**
     * Loại đối tượng thay đổi: COURSE, CHAPTER, LESSON, VIDEO, DOCUMENT, QUIZ, QUESTION
     */
    @Column(name = "entity_type", nullable = false, length = 40, columnDefinition = "nvarchar(40)")
    private String entityType;

    @Column(name = "entity_id")
    private Integer entityId;

    @Column(name = "entity_title", length = 500, columnDefinition = "nvarchar(500)")
    private String entityTitle;

    /**
     * ID bài học liên quan (nếu thay đổi thuộc về bài học, video, tài liệu, quiz gắn với bài học)
     */
    @Column(name = "parent_lesson_id")
    private Integer parentLessonId;

    /**
     * Hành động: CREATE, UPDATE, DELETE, REORDER, STATUS_CHANGE, VIDEO_UPLOAD, VIDEO_REPLACE, VIDEO_REMOVE
     */
    @Column(name = "action_type", nullable = false, length = 40, columnDefinition = "nvarchar(40)")
    private String actionType;

    @Column(name = "summary", nullable = false, length = 1000, columnDefinition = "nvarchar(1000)")
    private String summary;

    @Column(name = "changed_fields", length = 500, columnDefinition = "nvarchar(500)")
    private String changedFields;

    @Column(name = "before_data", columnDefinition = "nvarchar(max)")
    private String beforeData;

    @Column(name = "after_data", columnDefinition = "nvarchar(max)")
    private String afterData;

    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt;

    @PrePersist
    private void onCreate() {
        if (createdAt == null) {
            createdAt = LocalDateTime.now();
        }
    }
}
