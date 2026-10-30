package com.edusphere.dto.assignment;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotNull;

import java.math.BigDecimal;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
public class GradeForm {

    @NotNull(message = "Điểm số không được để trống")
    @DecimalMin(value = "0", message = "Điểm số phải >= 0")
    private BigDecimal score;

    private String feedback;
}
