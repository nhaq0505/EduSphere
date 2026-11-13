package com.edusphere.dto.course;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

/**
 * DTO tổng hợp đầy đủ nội dung 1 bài học (Video, Nội dung văn bản, Tài liệu đính kèm,
 * Quiz & Câu hỏi, và Lịch sử thay đổi Trước/Sau) để Admin bấm vào xem trực tiếp.
 */
@Getter
@Setter
@NoArgsConstructor
public class AdminLessonReviewView {

    private Integer lessonId;
    private Integer courseId;
    private Integer sectionId;
    private String sectionTitle;
    private String title;
    private String lessonType;
    private String status;
    private Integer orderIndex;

    private String content;
    private String videoUrl;
    private String bunnyVideoId;
    private String videoStatus;
    private Integer videoDuration;
    private Boolean allowSeek;
    private Boolean quizRequiresVideo;
    private Integer minWatchPercent;

    private Boolean isPreview;
    private Integer unlockDaysAfterEnroll;
    private Integer prerequisiteLessonId;
    private String prerequisiteLessonTitle;
    private String instructorNotes;

    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    /**
     * Phân loại thay đổi của bài học để hiển thị nổi bật cho Admin:
     * - "NEW": Bài học mới tạo (chưa công bố hoặc vừa thêm)
     * - "UPDATED": Bài học đã công bố nhưng vừa được giảng viên cập nhật nội dung/video/tài liệu/quiz
     * - "PUBLISHED": Bài học đã công bố và giữ nguyên
     */
    private String changeState = "PUBLISHED";
    private boolean newlyCreated;
    private boolean recentlyUpdated;
    private String latestChangeSummary;

    private boolean videoExists = true;
    private List<MaterialItem> materials = new ArrayList<>();
    private List<QuizItem> quizzes = new ArrayList<>();
    private List<CourseChangeLogView> changeLogs = new ArrayList<>();

    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    public static class MaterialItem {
        private Integer materialId;
        private String title;
        private String type;
        private String fileUrl;
        private String originalFileName;
        private Long sizeBytes;
        private LocalDateTime uploadedAt;
        private boolean fileExists;
    }

    @Getter
    @Setter
    @NoArgsConstructor
    public static class QuizItem {
        private Integer quizId;
        private String title;
        private String description;
        private Integer timeLimitMinutes;
        private Integer maxAttempts;
        private BigDecimal passingScore;
        private String status;
        private boolean shuffleQuestions;
        private boolean shuffleOptions;
        private List<QuestionItem> questions = new ArrayList<>();
    }

    @Getter
    @Setter
    @NoArgsConstructor
    public static class QuestionItem {
        private Integer questionId;
        private Integer orderIndex;
        private String content;
        private String type;
        private BigDecimal score;
        private String correctAnswer;
        private String explanation;
        private String imageUrl;
        private String videoUrl;
        private String sampleEssayAnswer;
        private List<OptionItem> options = new ArrayList<>();
    }

    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    public static class OptionItem {
        private Integer optionId;
        private Integer orderIndex;
        private String content;
        private boolean correct;

        public boolean isCorrect() {
            return correct;
        }

        public boolean getCorrect() {
            return correct;
        }
    }
}
