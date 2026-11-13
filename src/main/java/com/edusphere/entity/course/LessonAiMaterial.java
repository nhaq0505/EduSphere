package com.edusphere.entity.course;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.OneToOne;
import jakarta.persistence.PrePersist;
import jakarta.persistence.PreUpdate;
import jakarta.persistence.Table;
import jakarta.persistence.UniqueConstraint;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDateTime;

/**
 * Lưu trữ tài liệu học tập được tạo tự động bởi AI (Faster-Whisper + Qwen 2.5:3B) từ video bài giảng.
 * Mỗi bài học (Lesson) liên kết với 1 bản ghi tài liệu AI duy nhất (1-to-1).
 */
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Entity
@Table(name = "lesson_ai_materials",
       uniqueConstraints = @UniqueConstraint(name = "UQ_lesson_ai_materials_lesson", columnNames = {"lesson_id"}))
public class LessonAiMaterial {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private Integer id;

    @OneToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "lesson_id", referencedColumnName = "lesson_id", nullable = false, unique = true)
    private Lesson lesson;

    /** Task ID nhận từ Python FastAPI background service */
    @Column(name = "task_id", length = 100)
    private String taskId;

    /** Trạng thái xử lý: PENDING, PROCESSING, COMPLETED, FAILED */
    @Column(name = "status", nullable = false, length = 30)
    @Builder.Default
    private String status = "PENDING";

    /** Bản ghi giọng nói thô có timestamp từ Whisper */
    @Column(name = "original_transcript", columnDefinition = "nvarchar(max)")
    private String originalTranscript;

    /** Bản ghi đã được Qwen 2.5:3B hiệu đính ngữ cảnh và thuật ngữ */
    @Column(name = "corrected_transcript", columnDefinition = "nvarchar(max)")
    private String correctedTranscript;

    /** Tóm tắt nội dung chính của bài học */
    @Column(name = "summary", columnDefinition = "nvarchar(max)")
    private String summary;

    /** Các kiến thức trọng tâm */
    @Column(name = "key_points", columnDefinition = "nvarchar(max)")
    private String keyPoints;

    /** Bảng thuật ngữ chuyên ngành */
    @Column(name = "terms", columnDefinition = "nvarchar(max)")
    private String terms;

    /** Tổng kết ghi nhớ cốt lõi */
    @Column(name = "conclusion", columnDefinition = "nvarchar(max)")
    private String conclusion;

    /** Tên mô hình AI sử dụng (ví dụ: qwen2.5:3b + whisper-small) */
    @Column(name = "ai_model", length = 100)
    private String aiModel;

    /** Thông báo lỗi nếu tác vụ AI thất bại */
    @Column(name = "error_message", length = 1000, columnDefinition = "nvarchar(1000)")
    private String errorMessage;

    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    @PrePersist
    public void prePersist() {
        if (createdAt == null) {
            createdAt = LocalDateTime.now();
        }
        if (updatedAt == null) {
            updatedAt = LocalDateTime.now();
        }
    }

    @PreUpdate
    public void preUpdate() {
        updatedAt = LocalDateTime.now();
    }
}

