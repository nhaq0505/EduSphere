package com.edusphere.dto.quiz;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

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

    @Min(value = 1, message = "Số lần làm tối thiểu là 1")
    private Integer maxAttempts = 1;

    /** ISO datetime string: yyyy-MM-dd'T'HH:mm */
    private String startTime;

    private String dueDate;

    private String endTime;

    private String rules;

    /** Nullable — optional link to lesson */
    private Integer lessonId;
}
