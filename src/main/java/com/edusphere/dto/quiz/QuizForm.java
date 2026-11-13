package com.edusphere.dto.quiz;

import jakarta.validation.constraints.DecimalMax;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

import java.math.BigDecimal;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
public class QuizForm {

    @NotBlank(message = "Tiêu đề không được để trống")
    @Size(max = 255, message = "Tiêu đề tối đa 255 ký tự")
    private String title;

    private String description;

    private Integer timeLimitMinutes;

    private Integer maxAttempts = 999;

    /** ISO datetime string: yyyy-MM-dd'T'HH:mm */
    private String startTime;
    private String dueDate;
    private String endTime;

    private String rules;

    /** Nullable — optional link to lesson */
    private Integer lessonId;

    /** Điểm tối thiểu để qua bài (% tổng điểm, ví dụ 50.0). null = không yêu cầu. */
    @DecimalMin(value = "0", message = "Điểm đạt tối thiểu phải từ 0%")
    @DecimalMax(value = "100", message = "Điểm đạt tối đa là 100%")
    private BigDecimal passingScore;

    /** Xáo trộn thứ tự câu hỏi */
    private boolean shuffleQuestions = false;

    /** Xáo trộn thứ tự đáp án */
    private boolean shuffleOptions = false;
}
