package com.edusphere.dto.course.ai;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AiMaterialEditForm {
    private String summary;
    private String keyPoints;
    private String terms;
    private String conclusion;
}

