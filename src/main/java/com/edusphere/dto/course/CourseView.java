package com.edusphere.dto.course;

import java.math.BigDecimal;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;

import lombok.Getter;

/**
 * DTO chứa dữ liệu cho trang chi tiết và danh sách khóa học công khai.
 * Không để lộ thực thể Hibernate hoặc các quan hệ Lazy ra tầng View (JSP).
 */
@Getter
public class CourseView {

    private final Integer courseId;
    private final String title;
    private final String description;
    private final String summary;
    private final String categoryName;
    private final String instructorName;
    private final String instructorAvatarUrl;
    private final String instructorEmail;
    private final String levelLabel;
    private final String thumbnailUrl;
    private final BigDecimal price;
    private final String currency;
    private final double averageRating;
    private final long ratingCount;
    private final String objectives;
    private final String requirements;
    private final Integer credits;
    private final int sectionCount;
    private final int lessonCount;
    private final Integer totalDurationMinutes;
    private final String formattedDuration;

    public CourseView(Integer courseId, String title, String description, String categoryName,
                      String instructorName, String levelLabel, String thumbnailUrl, BigDecimal price, String currency) {
        this(courseId, title, description, categoryName, instructorName, levelLabel, thumbnailUrl, price, currency, 0.0, 0L);
    }

    public CourseView(Integer courseId, String title, String description, String categoryName,
                      String instructorName, String levelLabel, String thumbnailUrl, BigDecimal price, String currency,
                      double averageRating, long ratingCount) {
        this(courseId, title, description, categoryName, instructorName, null, null, levelLabel, thumbnailUrl, price, currency,
                averageRating, ratingCount, null, null, 3, 0, 0, 0, null);
    }

    public CourseView(Integer courseId, String title, String description, String categoryName,
                      String instructorName, String instructorAvatarUrl, String instructorEmail,
                      String levelLabel, String thumbnailUrl, BigDecimal price, String currency,
                      double averageRating, long ratingCount,
                      String objectives, String requirements, Integer credits,
                      int sectionCount, int lessonCount, Integer totalDurationMinutes, String formattedDuration) {
        this.courseId = courseId;
        this.title = title;
        this.description = description;
        this.summary = description == null ? "" :
                (description.length() > 160 ? description.substring(0, 160) + "…" : description);
        this.categoryName = categoryName;
        this.instructorName = instructorName;
        this.instructorAvatarUrl = instructorAvatarUrl;
        this.instructorEmail = instructorEmail;
        this.levelLabel = levelLabel;
        this.thumbnailUrl = thumbnailUrl;
        this.price = price != null ? price : BigDecimal.ZERO;
        this.currency = currency != null ? currency : "VND";
        this.averageRating = averageRating;
        this.ratingCount = ratingCount;
        this.objectives = objectives;
        this.requirements = requirements;
        this.credits = credits != null ? credits : 3;
        this.sectionCount = sectionCount;
        this.lessonCount = lessonCount;
        this.totalDurationMinutes = totalDurationMinutes;
        this.formattedDuration = formattedDuration;
    }

    public boolean isFree() {
        return price.signum() == 0;
    }

    /**
     * Tách danh sách mục tiêu đầu ra theo từng dòng (nếu có dữ liệu thực tế).
     * Trả về danh sách rỗng nếu không có dữ liệu — tuyệt đối không sinh dữ liệu giả.
     */
    public List<String> getObjectiveList() {
        if (objectives == null || objectives.isBlank()) {
            return Collections.emptyList();
        }
        return Arrays.stream(objectives.split("\\r?\\n"))
                .map(String::trim)
                .filter(s -> !s.isEmpty())
                .toList();
    }

    /**
     * Tách danh sách yêu cầu đầu vào theo từng dòng (nếu có dữ liệu thực tế).
     */
    public List<String> getRequirementList() {
        if (requirements == null || requirements.isBlank()) {
            return Collections.emptyList();
        }
        return Arrays.stream(requirements.split("\\r?\\n"))
                .map(String::trim)
                .filter(s -> !s.isEmpty())
                .toList();
    }
}
