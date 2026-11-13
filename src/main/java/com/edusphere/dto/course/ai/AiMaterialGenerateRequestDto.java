package com.edusphere.dto.course.ai;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AiMaterialGenerateRequestDto {
    private Integer lessonId;
    private String videoUrl;
    private String bunnyVideoId;
    private String libraryId;
    private String bunnyApiKey;
    private String filePath;
    private Boolean forceRegenerate;
}

