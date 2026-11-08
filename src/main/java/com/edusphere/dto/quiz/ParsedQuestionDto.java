package com.edusphere.dto.quiz;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ParsedQuestionDto {

    private String content;

    @Builder.Default
    private String type = "SINGLE_CHOICE"; // SINGLE_CHOICE, MULTIPLE_CHOICE, TRUE_FALSE, SHORT_ANSWER, ESSAY

    @Builder.Default
    private String difficultyLevel = "MEDIUM"; // EASY, MEDIUM, HARD

    @Builder.Default
    private BigDecimal defaultScore = BigDecimal.valueOf(1.0);
    private String correctAnswer;
    private String explanation;
    private String sampleEssayAnswer;
    private String imageUrl;
    private String videoUrl;
    private String categoryName;

    @Builder.Default
    private List<ParsedOptionDto> options = new ArrayList<>();

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class ParsedOptionDto {
        private String content;
        private boolean correct;
        private int orderIndex;
    }
}

