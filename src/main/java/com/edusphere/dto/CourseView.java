package com.edusphere.dto;

import lombok.Getter;

import java.math.BigDecimal;

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
    private final BigDecimal price;
    private final String currency;

    public CourseView(Integer courseId, String title, String description, String categoryName,
                      String instructorName, String levelLabel, BigDecimal price, String currency) {
        this.courseId = courseId;
        this.title = title;
        this.description = description;
        this.summary = description == null ? "" :
                (description.length() > 160 ? description.substring(0, 160) + "…" : description);
        this.categoryName = categoryName;
        this.instructorName = instructorName;
        this.levelLabel = levelLabel;
        this.price = price;
        this.currency = currency;
    }

    public boolean isFree() {
        return price.signum() == 0;
    }
}
