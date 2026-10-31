package com.edusphere.dto.planning;

import lombok.Builder;
import lombok.Getter;

import java.time.LocalDateTime;

@Getter
@Builder
public class HistoryItemView {

    private final Long historyId;
    private final Integer courseId;
    private final String courseTitle;
    private final String activityType;
    private final String activityLabel;
    private final Integer lessonId;
    private final String lessonTitle;
    private final Integer assignmentId;
    private final String assignmentTitle;
    private final Integer quizId;
    private final String quizTitle;
    private final String details;
    private final LocalDateTime occurredAt;
}

