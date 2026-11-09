package com.edusphere.dto.course;

import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Locale;

@Getter
@Setter
public class EnrolledCourseView {
    private static final DateTimeFormatter MONTH_YEAR_EN =
            DateTimeFormatter.ofPattern("MMMM yyyy", Locale.ENGLISH);

    private final Integer courseId;
    private final String title;
    private final String instructorName;
    private final String enrollmentStatus;
    private final String courseStatus;

    private Integer credits = 3;
    private int progressPercent = 0;
    private int completedLessons = 0;
    private int totalLessons = 0;
    private String thumbnailUrl;
    private String categoryName;
    private LocalDateTime enrolledAt;
    private LocalDateTime completedAt;
    private Integer certificateId;
    private String verificationCode;
    private Integer gradePercent;

    public EnrolledCourseView(Integer courseId, String title, String instructorName,
                              String enrollmentStatus, String courseStatus) {
        this.courseId = courseId;
        this.title = title;
        this.instructorName = instructorName;
        this.enrollmentStatus = enrollmentStatus;
        this.courseStatus = courseStatus;
    }

    public boolean isCompleted() {
        return "COMPLETED".equalsIgnoreCase(enrollmentStatus) || progressPercent >= 100 || certificateId != null;
    }

    public boolean isHasCertificate() {
        return certificateId != null;
    }

    public String getFormattedCompletedMonthYear() {
        LocalDateTime ref = completedAt != null ? completedAt : (enrolledAt != null ? enrolledAt : LocalDateTime.now());
        return ref.format(MONTH_YEAR_EN);
    }
}
