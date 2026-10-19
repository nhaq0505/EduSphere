package com.edusphere.dto.course;

import java.math.BigDecimal;
import java.time.LocalDateTime;

import lombok.Getter;

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
    private final int lessonCount;
    private final boolean readyForSubmit;
    private final boolean hidden;
    private final LocalDateTime publishedAt;

    public ManagedCourseView(Integer courseId, String title, String description, String categoryName,
                             String instructorName, String level, BigDecimal price, String status,
                             Integer versionNo, String latestReviewComment) {
        this(courseId, title, description, categoryName, instructorName, level, price, status,
                versionNo, latestReviewComment, 0, false, false, null);
    }

    public ManagedCourseView(Integer courseId, String title, String description, String categoryName,
                             String instructorName, String level, BigDecimal price, String status,
                             Integer versionNo, String latestReviewComment,
                             int lessonCount, boolean readyForSubmit, boolean hidden, LocalDateTime publishedAt) {
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
        this.lessonCount = lessonCount;
        this.readyForSubmit = readyForSubmit;
        this.hidden = hidden;
        this.publishedAt = publishedAt;
    }
}
