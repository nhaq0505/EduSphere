package com.edusphere.dto.quiz;

import java.math.BigDecimal;
import java.time.LocalDateTime;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class QuizAttemptView {

    private Integer attemptId;
    private Integer quizId;
    private String quizTitle;
    private String studentName;
    private BigDecimal score;
    private BigDecimal maxScore;
    private String status;
    private String resultStatus;
    private LocalDateTime submittedAt;
    private Integer attemptNumber;

    public String getFormattedSubmittedAt() {
        if (submittedAt == null) return null;
        return submittedAt.format(java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm"));
    }
}
