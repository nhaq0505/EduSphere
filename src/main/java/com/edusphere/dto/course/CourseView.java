package com.edusphere.dto.course;

import java.math.BigDecimal;

import lombok.Getter;

/** Data for the public course pages; no entity or lazy relationship reaches JSP. */
@Getter
public class CourseView {

    private final Integer courseId;
    private final String title;
    private final String description;
    private final String summary;
    private final String categoryName;
    private final String instructorName;
    private final String levelLabel;
    private final String thumbnailUrl;
    private final BigDecimal price;
    private final String currency;
    private final Integer credits;

    public CourseView(Integer courseId, String title, String description, String categoryName,
                      String instructorName, String levelLabel, String thumbnailUrl, BigDecimal price, String currency) {
        this(courseId, title, description, categoryName, instructorName, levelLabel, thumbnailUrl, price, currency, 3);
    }

    public CourseView(Integer courseId, String title, String description, String categoryName,
                      String instructorName, String levelLabel, String thumbnailUrl, BigDecimal price, String currency,
                      Integer credits) {
        this.courseId = courseId;
        this.title = title;
        this.description = description;
        this.summary = description == null ? "" :
                (description.length() > 160 ? description.substring(0, 160) + "…" : description);
        this.categoryName = categoryName;
        this.instructorName = instructorName;
        this.levelLabel = levelLabel;
        this.thumbnailUrl = thumbnailUrl;
        this.price = price;
        this.currency = currency;
        this.credits = credits != null && credits > 0 ? credits : 3;
    }

    public boolean isFree() {
        return price.signum() == 0;
    }
}
