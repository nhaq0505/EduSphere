package com.edusphere.dto.course;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class MaterialForm {
    @NotBlank(message = "Vui lòng nhập tên tài liệu.")
    @Size(max = 255, message = "Tên tài liệu tối đa 255 ký tự.")
    private String title;

    @NotBlank(message = "Vui lòng chọn loại tài liệu.")
    @Pattern(regexp = "DOCUMENT|LINK|VIDEO", message = "Loại tài liệu không hợp lệ.")
    private String type;

    @NotBlank(message = "Vui lòng nhập đường dẫn tài liệu.")
    @Size(max = 2048, message = "Đường dẫn tối đa 2048 ký tự.")
    @Pattern(regexp = "https?://[^\\s]+", flags = Pattern.Flag.CASE_INSENSITIVE,
             message = "Đường dẫn phải bắt đầu bằng http:// hoặc https://.")
    private String fileUrl;
}
