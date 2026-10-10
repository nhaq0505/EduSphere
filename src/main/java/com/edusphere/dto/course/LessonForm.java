package com.edusphere.dto.course;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class LessonForm {
    @NotBlank(message = "Vui lòng nhập tên bài học.")
    @Size(max = 255, message = "Tên bài học tối đa 255 ký tự.")
    private String title;

    private String content;

    @Min(value = 1, message = "Vị trí bài học phải từ 1 trở lên.")
    private Integer orderIndex;
}
