package com.edusphere.dto.quiz;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class QuestionBankForm {

    @NotBlank(message = "Tên ngân hàng câu hỏi không được để trống")
    @Size(max = 255, message = "Tên ngân hàng không được vượt quá 255 ký tự")
    private String name;

    private String description;

    private Integer courseId;
}

