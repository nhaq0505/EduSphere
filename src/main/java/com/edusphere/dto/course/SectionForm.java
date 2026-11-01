package com.edusphere.dto.course;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class SectionForm {

    private Integer sectionId;

    @NotBlank(message = "Tên chương không được để trống")
    @Size(max = 255, message = "Tên chương tối đa 255 ký tự")
    private String title;

    private String description;

    private Integer orderIndex;
}

