package com.edusphere.dto.planning;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
public class StudyPlanForm {

    @NotBlank(message = "Tiêu đề kế hoạch không được để trống")
    @Size(max = 255, message = "Tiêu đề tối đa 255 ký tự")
    private String title;

    private String description;

    @NotBlank(message = "Ngày bắt đầu không được để trống")
    private String startDate; // yyyy-MM-dd

    @NotBlank(message = "Ngày kết thúc không được để trống")
    private String endDate; // yyyy-MM-dd

    private String timezone = "Asia/Ho_Chi_Minh";

    private String status = "ACTIVE"; // ACTIVE, COMPLETED, CANCELLED
}

