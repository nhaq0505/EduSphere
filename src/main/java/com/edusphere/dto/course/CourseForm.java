package com.edusphere.dto.course;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.Getter;
import lombok.Setter;

import java.math.BigDecimal;

@Getter
@Setter
public class CourseForm {

    @NotBlank(message = "Tên khóa học không được để trống")
    @Size(max = 255, message = "Tên khóa học tối đa 255 ký tự")
    private String title;

    private String description;
    private Integer categoryId;

    @NotBlank(message = "Vui lòng chọn trình độ")
    private String level = "ALL_LEVELS";

    @NotNull(message = "Vui lòng nhập học phí")
    @DecimalMin(value = "0.00", message = "Học phí không được âm")
    private BigDecimal price = BigDecimal.ZERO;

    @Min(value = 1, message = "Số tín chỉ tối thiểu là 1")
    @Max(value = 30, message = "Số tín chỉ tối đa là 30")
    private Integer credits = 3;

    // Bước 1: Thông tin nâng cao
    private String thumbnailUrl;
    private String promoVideoUrl;
    private String objectives;   // What students will learn (Mục tiêu đầu ra)
    private String requirements; // Prerequisites (Yêu cầu đầu vào)
}
