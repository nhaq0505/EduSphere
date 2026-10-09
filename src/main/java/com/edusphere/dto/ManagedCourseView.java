package com.edusphere.dto;

import lombok.Getter;

import java.math.BigDecimal;

@Getter
public class ManagedCourseView {
    private final Integer courseId;
    private final String title;
    private final String description;
    private final String categoryName;
    private final String instructorName;
    private final String level;
    private final BigDecimal price;
    private final String status;
    private final Integer versionNo;
    private final String latestReviewComment;

    public ManagedCourseView(Integer courseId, String title, String description, String categoryName,
                             String instructorName, String level, BigDecimal price, String status,
                             Integer versionNo, String latestReviewComment) {
        this.courseId = courseId;
        this.title = title;
        this.description = description;
        this.categoryName = categoryName;
        this.instructorName = instructorName;
        this.level = level;
        this.price = price;
        this.status = status;
        this.versionNo = versionNo;
        this.latestReviewComment = latestReviewComment;
    }
}
