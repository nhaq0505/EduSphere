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
public class QuizView {

    private Integer quizId;
    private String title;
    private String status;
    private long questionCount;
    private BigDecimal maxScore;
    private LocalDateTime dueDate;
    private Integer timeLimitMinutes;
    private Integer maxAttempts;
}
