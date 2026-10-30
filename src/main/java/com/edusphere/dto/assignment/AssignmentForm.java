package com.edusphere.dto.assignment;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

import java.math.BigDecimal;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
public class AssignmentForm {

    @NotBlank(message = "Tiêu đề không được để trống")
    @Size(max = 255, message = "Tiêu đề tối đa 255 ký tự")
    private String title;

    private String description;

    /** ISO datetime string: yyyy-MM-dd'T'HH:mm */
    private String dueDate;

    private String unlockAt;

    private String lockAt;

    @NotNull(message = "Điểm tối đa không được để trống")
    @DecimalMin(value = "0", message = "Điểm tối đa phải >= 0")
    private BigDecimal maxScore = BigDecimal.valueOf(100);

    private boolean allowResubmit = false;

    @Min(value = 1, message = "Số lần nộp tối thiểu là 1")
    private Integer maxAttempts = 1;

    /** Nullable — optional link to lesson */
    private Integer lessonId;
}
