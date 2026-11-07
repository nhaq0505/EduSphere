package com.edusphere.dto.quiz;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.ArrayList;
import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ImportResultDto {

    private int totalRead;
    private int successCount;
    private int errorCount;
    private Integer targetCategoryId;

    @Builder.Default
    private List<String> warnings = new ArrayList<>();

    @Builder.Default
    private List<ParsedQuestionDto> validQuestions = new ArrayList<>();
}

