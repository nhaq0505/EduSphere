package com.edusphere.dto.course.ai;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AiMaterialTaskResponseDto {
    private String taskId;
    private Integer lessonId;
    private String status;      // PENDING, DOWNLOADING, EXTRACTING_AUDIO, TRANSCRIBING, CORRECTING, GENERATING, COMPLETED, FAILED
    private Integer progress;   // 0 - 100
    private String currentStep;
    private String message;
    private String error;
}

