package com.edusphere.dto.planning;

import lombok.Builder;
import lombok.Getter;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Getter
@Builder
public class StudentProgressView {

    private final Integer studentId;
    private final String fullName;
    private final String email;
    private final String avatarUrl;
    private final String enrollmentStatus;
    private final LocalDateTime enrolledAt;
    private final LocalDateTime completedAt;
    private final BigDecimal percentComplete;
    private final int completedLessons;
    private final int totalLessons;
    private final LocalDateTime lastAccessedAt;
}

