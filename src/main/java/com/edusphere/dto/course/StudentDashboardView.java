package com.edusphere.dto.course;

import lombok.Builder;
import lombok.Getter;

import java.util.List;

@Getter
@Builder
public class StudentDashboardView {

    private final String studentName;
    private final double totalStudyHours;
    private final String totalStudyHoursFormatted;
    private final double targetStudyHours;
    private final String targetStudyHoursFormatted;
    private final int studyGoalPercent;

    private final int enrolledCoursesCount;
    private final int completedCoursesCount;
    private final int inProgressCoursesCount;
    private final int certificatesCount;
    private final List<CertificateView> certificates;

    private final boolean hasRatings;
    private final String averageRatingFormatted;

    private final List<ActiveCourseCard> activeCourses;

    private final String chart7dLabelsJson;
    private final String chart7dValuesJson;
    private final String chart30dLabelsJson;
    private final String chart30dValuesJson;
    private final String chart3mLabelsJson;
    private final String chart3mValuesJson;

    private final String achievementTitle;
    private final String achievementSubtitle;

    @Getter
    @Builder
    public static class ActiveCourseCard {
        private final Integer courseId;
        private final String title;
        private final String description;
        private final String thumbnailUrl;
        private final int progressPercent;
        private final String studiedHoursFormatted;
        private final String targetHoursFormatted;
        private final boolean completed;
        private final Integer certificateId;
    }
}
