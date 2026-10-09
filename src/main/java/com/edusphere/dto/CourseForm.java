package com.edusphere.dto;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

import java.math.BigDecimal;

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

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public Integer getCategoryId() { return categoryId; }
    public void setCategoryId(Integer categoryId) { this.categoryId = categoryId; }
    public String getLevel() { return level; }
    public void setLevel(String level) { this.level = level; }
    public BigDecimal getPrice() { return price; }
    public void setPrice(BigDecimal price) { this.price = price; }
}
