package com.edusphere.dto.quiz;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

@Data
public class BankQuestionForm {

    private Integer categoryId;

    @NotBlank(message = "Nội dung câu hỏi không được để trống")
    private String content;

    private String imageUrl;
    private String videoUrl;

    private String type = "SINGLE_CHOICE"; // SINGLE_CHOICE, MULTIPLE_CHOICE, TRUE_FALSE, SHORT_ANSWER, ESSAY
    private String difficultyLevel = "MEDIUM"; // EASY, MEDIUM, HARD
    private BigDecimal defaultScore = BigDecimal.valueOf(1.0);

    private String correctAnswer;
    private String explanation;
    private String sampleEssayAnswer;
    private String tags;

    // Danh sách 4 đáp án cho câu hỏi trắc nghiệm
    private List<String> optionTexts = new ArrayList<>(List.of("", "", "", ""));
    private List<Boolean> optionCorrects = new ArrayList<>(List.of(false, false, false, false));
    private Integer singleCorrectIndex = 0;
}

