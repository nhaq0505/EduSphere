package com.edusphere.dto.course;

import lombok.Builder;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Locale;

@Getter
@Setter
@Builder
public class CertificateView {

    private static final DateTimeFormatter EN_LONG_DATE =
            DateTimeFormatter.ofPattern("MMMM d, yyyy", Locale.ENGLISH);
    private static final DateTimeFormatter EN_SHORT_DATE =
            DateTimeFormatter.ofPattern("MMM d, yyyy", Locale.ENGLISH);
    private static final DateTimeFormatter EN_MONTH_YEAR =
            DateTimeFormatter.ofPattern("MMMM yyyy", Locale.ENGLISH);
    private static final DateTimeFormatter VI_DATE =
            DateTimeFormatter.ofPattern("dd/MM/yyyy");

    private Integer certificateId;
    private String verificationCode;
    private LocalDateTime issuedAt;
    private Integer creditsEarned;
    private Integer gradePercent;
    private Integer totalHours;
    private String status;

    private Integer studentId;
    private String studentName;
    private String studentEmail;
    private String studentAvatarUrl;

    private Integer courseId;
    private String courseTitle;
    private String courseDescription;
    private String courseThumbnailUrl;
    private String categoryName;
    private String levelLabel;
    private String instructorName;
    private String instructorTitle;

    private int lessonCount;
    private long enrolledCount;
    private double averageRating;
    private int ratingCount;

    private List<String> objectivesList;
    private List<String> skillsList;

    public String getFormattedIssuedDateEn() {
        LocalDateTime dt = issuedAt != null ? issuedAt : LocalDateTime.now();
        return dt.format(EN_LONG_DATE);
    }

    public String getFormattedIssuedDateShortEn() {
        LocalDateTime dt = issuedAt != null ? issuedAt : LocalDateTime.now();
        return dt.format(EN_SHORT_DATE);
    }

    public String getFormattedIssuedMonthYearEn() {
        LocalDateTime dt = issuedAt != null ? issuedAt : LocalDateTime.now();
        return dt.format(EN_MONTH_YEAR);
    }

    public String getFormattedIssuedDateVi() {
        LocalDateTime dt = issuedAt != null ? issuedAt : LocalDateTime.now();
        return dt.format(VI_DATE);
    }
}
