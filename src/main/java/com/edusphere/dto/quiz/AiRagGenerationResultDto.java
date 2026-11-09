package com.edusphere.dto.quiz;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

/**
 * DTO chứa kết quả truy xuất ngữ cảnh RAG và danh sách câu hỏi nháp do AI sinh ra
 * để Giảng viên kiểm duyệt, chỉnh sửa trước khi lưu chính thức vào Ngân hàng câu hỏi.
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AiRagGenerationResultDto {

    private String modelUsed;
    private String topicPrompt;
    private Integer targetCategoryId;
    private String newCategoryName;

    @Builder.Default
    private List<RagChunkDto> retrievedChunks = new ArrayList<>();

    @Builder.Default
    private List<AiDraftQuestionDto> draftQuestions = new ArrayList<>();

    /**
     * Một đoạn ngữ cảnh (Chunk) được trích xuất và xếp hạng bởi bộ truy xuất RAG.
     */
    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class RagChunkDto {
        private int chunkIndex;
        private String sourceTitle;
        private String content;
        private double relevanceScore;
    }

    /**
     * Một câu hỏi nháp do AI sinh ra từ ngữ cảnh RAG, chờ Giảng viên kiểm duyệt.
     */
    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class AiDraftQuestionDto {
        private String content;

        @Builder.Default
        private String type = "SINGLE_CHOICE";

        @Builder.Default
        private String difficultyLevel = "MEDIUM";

        @Builder.Default
        private BigDecimal defaultScore = BigDecimal.valueOf(1.0);

        private String optionA;
        private String optionB;
        private String optionC;
        private String optionD;

        /** Ví dụ: "A", "B", "A,C", "TRUE", "FALSE" */
        private String correctAnswer;

        private String explanation;
        private String sampleEssayAnswer;

        /** Trích đoạn hoặc tên nguồn bài học RAG mà câu hỏi này bám sát */
        private String sourceExcerpt;
    }
}
