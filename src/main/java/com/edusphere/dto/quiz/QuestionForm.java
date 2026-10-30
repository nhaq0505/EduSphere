package com.edusphere.dto.quiz;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
public class QuestionForm {

    @NotBlank(message = "Nội dung câu hỏi không được để trống")
    private String content;

    @NotNull(message = "Loại câu hỏi không được để trống")
    private String type;

    @NotNull(message = "Điểm không được để trống")
    @DecimalMin(value = "0", message = "Điểm phải >= 0")
    private BigDecimal score = BigDecimal.valueOf(1);

    /** For TRUE_FALSE / SHORT_ANSWER */
    private String correctAnswer;

    private String explanation;

    /** Nội dung từng lựa chọn (cho SINGLE_CHOICE, MULTIPLE_CHOICE) */
    private List<String> optionContents = new ArrayList<>();

    /** Đánh dấu đúng/sai tương ứng với optionContents */
    private List<Boolean> optionCorrects = new ArrayList<>();
}
