package com.edusphere.dto.course;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
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

    // Bước 1 & Bước 2 details
    private String thumbnailUrl;
    private String promoVideoUrl;
    private String objectives;
    private String requirements;
    private List<CourseSectionView> sections = new ArrayList<>();

    /** Chú thích cập nhật từ instructor khi gửi duyệt (từ UPDATING) */
    private String changeNote;

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
        this(courseId, title, description, categoryName, instructorName, level, price, status,
                versionNo, latestReviewComment, lessonCount, readyForSubmit, hidden, publishedAt,
                null, null, null, null);
    }

    public ManagedCourseView(Integer courseId, String title, String description, String categoryName,
                             String instructorName, String level, BigDecimal price, String status,
                             Integer versionNo, String latestReviewComment,
                             int lessonCount, boolean readyForSubmit, boolean hidden, LocalDateTime publishedAt,
                             String thumbnailUrl, String promoVideoUrl, String objectives, String requirements) {
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
        this.thumbnailUrl = thumbnailUrl;
        this.promoVideoUrl = promoVideoUrl;
        this.objectives = objectives;
        this.requirements = requirements;
    }
}
