package com.edusphere.dto.planning;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
public class PersonalTaskForm {

    @NotBlank(message = "Tiêu đề nhiệm vụ không được để trống")
    @Size(max = 255, message = "Tiêu đề tối đa 255 ký tự")
    private String title;

    private String notes;

    private Integer courseId;

    private Integer relatedLessonId;

    private Integer relatedAssignmentId;

    private Integer relatedQuizId;

    @NotBlank(message = "Thời điểm bắt đầu không được để trống")
    private String plannedStartAt; // yyyy-MM-dd'T'HH:mm

    @NotBlank(message = "Thời điểm kết thúc không được để trống")
    private String plannedEndAt; // yyyy-MM-dd'T'HH:mm

    private String status = "PENDING"; // PENDING, DONE, SKIPPED
}

