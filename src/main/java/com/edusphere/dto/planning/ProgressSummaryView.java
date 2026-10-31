package com.edusphere.dto.planning;

import lombok.Builder;
import lombok.Getter;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Getter
@Builder
public class ProgressSummaryView {

    private final Integer courseId;
    private final String courseTitle;
    private final String categoryName;
    private final String instructorName;
    private final String enrollmentStatus;
    private final BigDecimal percentComplete;
    private final int completedLessons;
    private final int totalLessons;
    private final LocalDateTime lastAccessedAt;
    private final LocalDateTime enrolledAt;
    private final LocalDateTime completedAt;
}

