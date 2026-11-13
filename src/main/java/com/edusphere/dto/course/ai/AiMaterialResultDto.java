package com.edusphere.dto.course.ai;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AiMaterialResultDto {
    private Integer id;
    private Integer lessonId;
    private String taskId;
    private String status;
    private String originalTranscript;
    private String correctedTranscript;
    private String summary;
    private String keyPoints;
    private String terms;
    private String conclusion;
    private String aiModel;
    private String errorMessage;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}

