package com.edusphere.dto.planning;

import lombok.Builder;
import lombok.Getter;

import java.time.LocalDateTime;

@Getter
@Builder
public class PersonalTaskView {

    private final Integer taskId;
    private final Integer planId;
    private final String planTitle;
    private final String title;
    private final String notes;
    private final Integer courseId;
    private final String courseTitle;
    private final Integer relatedLessonId;
    private final String lessonTitle;
    private final Integer relatedAssignmentId;
    private final String assignmentTitle;
    private final Integer relatedQuizId;
    private final String quizTitle;
    private final LocalDateTime plannedStartAt;
    private final LocalDateTime plannedEndAt;
    private final String status;
    private final LocalDateTime completedAt;
}

