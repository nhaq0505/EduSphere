package com.edusphere.dto.planning;

import lombok.Getter;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Getter
public class StudyPlanView {

    private final Integer planId;
    private final String title;
    private final String description;
    private final LocalDate startDate;
    private final LocalDate endDate;
    private final String timezone;
    private final String status;
    private final LocalDateTime createdAt;
    private final long totalTasks;
    private final long doneTasks;
    private final int progressPercent;

    public StudyPlanView(Integer planId, String title, String description,
                         LocalDate startDate, LocalDate endDate, String timezone,
                         String status, LocalDateTime createdAt,
                         long totalTasks, long doneTasks) {
        this.planId = planId;
        this.title = title;
        this.description = description;
        this.startDate = startDate;
        this.endDate = endDate;
        this.timezone = timezone;
        this.status = status;
        this.createdAt = createdAt;
        this.totalTasks = totalTasks;
        this.doneTasks = doneTasks;
        this.progressPercent = totalTasks > 0 ? (int) Math.round((double) doneTasks * 100.0 / totalTasks) : 0;
    }
}

