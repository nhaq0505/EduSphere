package com.edusphere.dto.course;

import lombok.Getter;
import lombok.Setter;

import java.util.ArrayList;
import java.util.List;

/** Dữ liệu hiển thị trang Dashboard của học viên (số giờ học, khóa học đang học, thống kê). */
@Getter
@Setter
public class StudentDashboardView {

    private String fullName;

    // Thẻ 1: Số giờ học
    private double hoursStudied;
    private double targetHours;
    private int hoursPercent;
    private String hoursStudiedLabel;
    private String targetHoursLabel;

    // Thẻ 2, 3, 4
    private int enrolledCount;
    private int completedCount;
    private int inProgressCount;
    private int lessonsCompleted;
    private Double averageRating;     // null nếu chưa đánh giá khóa học nào
    private int ratingCount;

    // Chuỗi ngày học liên tiếp & hôm nay
    private int streakDays;
    private int todayMinutes;

    private List<CourseItem> activeCourses = new ArrayList<>();

    // Biểu đồ thống kê học tập (JSON: {"labels":[...],"values":[...]})
    private String chart7Json;
    private String chart30Json;
    private String chart90Json;

    // Thành tích
    private String achievementTitle;
    private String achievementDesc;

    @Getter
    @Setter
    public static class CourseItem {
        private Integer courseId;
        private String title;
        private String summary;
        private String thumbnailUrl;
        private int progressPercent;
        private int completedLessons;
        private int totalLessons;
        private double hoursStudied;
        private double targetHours;
        private String hoursStudiedLabel;
        private String targetHoursLabel;
        private Integer continueLessonId;
    }
}
