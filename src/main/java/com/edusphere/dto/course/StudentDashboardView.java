package com.edusphere.dto.course;

import lombok.Builder;
import lombok.Getter;

import java.util.Collections;
import java.util.List;
import java.util.Locale;

/**
 * View DTO chứa toàn bộ dữ liệu hiển thị cho trang Dashboard Học Viên (Student Dashboard).
 * Bao gồm thống kê số giờ học thực tế, tiến độ mục tiêu, danh sách khóa học đang học,
 * kho chứng chỉ đã đạt, dữ liệu biểu đồ 7 ngày / 30 ngày / 3 tháng và các chỉ số phân tích học tập.
 */
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

  private final int currentStreakDays;
  private final int longestStreakDays;
  private final int activeStudyDaysLast30d;
  private final double weeklyStudyHours;
  private final String weeklyStudyHoursFormatted;
  private final double monthlyStudyHours;
  private final String monthlyStudyHoursFormatted;
  private final double dailyAverageMinutesLast7d;
  private final int totalCreditsEarned;
  private final String learningRankBadge;
  private final String studyVelocityLabel;
  private final List<StudyMilestoneItem> milestones;
  private final List<StudyHabitInsight> habitInsights;

  /**
   * Tính tỷ lệ phần trăm khóa học đã hoàn thành trên tổng số khóa đã đăng ký.
   */
  public int getCourseCompletionRatePercent() {
    if (this.enrolledCoursesCount <= 0) {
      return 0;
    }
    final double ratio = (this.completedCoursesCount * 100.0) / this.enrolledCoursesCount;
    return (int) Math.min(100, Math.max(0, Math.round(ratio)));
  }

  /**
   * Tính số giờ học còn lại để hoàn thành mục tiêu học tập.
   */
  public double getRemainingGoalHours() {
    final double diff = this.targetStudyHours - this.totalStudyHours;
    return diff > 0.0 ? Math.round(diff * 10.0) / 10.0 : 0.0;
  }

  /**
   * Định dạng chuỗi số giờ học còn lại để đạt mục tiêu.
   */
  public String getRemainingGoalHoursFormatted() {
    final double rem = getRemainingGoalHours();
    if (Math.abs(rem - Math.rint(rem)) < 0.05) {
      return String.valueOf((long) Math.rint(rem));
    }
    return String.format(Locale.US, "%.1f", rem);
  }

  /**
   * Kiểm tra học viên đã đạt mục tiêu số giờ học hay chưa.
   */
  public boolean isGoalCompleted() {
    return this.studyGoalPercent >= 100 || this.totalStudyHours >= this.targetStudyHours;
  }

  public boolean isHasActiveStreak() {
    return this.currentStreakDays > 0;
  }

  public int getCompletedLessonsCount() {
    int sum = 0;
    for (final ActiveCourseCard c : getSafeActiveCourses()) {
      if (c != null) {
        sum += Math.max(0, c.getCompletedLessonsCount());
      }
    }
    return sum;
  }

  /**
   * Trả về danh sách khóa học an toàn (không null).
   */
  public List<ActiveCourseCard> getSafeActiveCourses() {
    return this.activeCourses != null ? this.activeCourses : Collections.emptyList();
  }

  /**
   * Trả về danh sách chứng chỉ an toàn (không null).
   */
  public List<CertificateView> getSafeCertificates() {
    return this.certificates != null ? this.certificates : Collections.emptyList();
  }

  /**
   * Trả về thông điệp khích lệ dựa trên tiến độ học tập hiện tại của học viên.
   */
  public String getMotivationalBannerMessage() {
    if (isGoalCompleted()) {
      return "Tuyệt vời! Bạn đã hoàn thành 100% mục tiêu giờ học. Hãy tiếp tục chinh phục các khóa học mới!";
    }
    if (this.studyGoalPercent >= 70) {
      return "Bạn đang ở rất gần mục tiêu (" + this.studyGoalPercent
          + "%). Chỉ còn " + getRemainingGoalHoursFormatted() + " giờ học nữa thôi!";
    }
    if (this.studyGoalPercent >= 30) {
      return "Nhịp độ học tập ổn định! Hãy duy trì đều đặn mỗi ngày để bứt phá kiến thức.";
    }
    return "Cùng EduSphere khám phá tri thức và phát triển bản thân mỗi ngày!";
  }

  /**
   * Thẻ thông tin khóa học đang theo học hiển thị trên Student Dashboard.
   */
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
    private final int completedLessonsCount;
    private final int totalLessonsCount;
    private final String categoryLabel;
    private final String instructorDisplayName;

    public String getProgressStatusLabel() {
      if (this.completed || this.progressPercent >= 100) {
        return "Đã hoàn thành";
      }
      if (this.progressPercent >= 75) {
        return "Sắp hoàn thành";
      }
      if (this.progressPercent >= 25) {
        return "Đang tiến bộ";
      }
      if (this.progressPercent > 0) {
        return "Mới bắt đầu";
      }
      return "Chưa học bài nào";
    }

    public int getRemainingPercent() {
      return Math.max(0, 100 - Math.min(100, this.progressPercent));
    }
  }

  /**
   * Mốc thành tựu học tập của học viên.
   */
  @Getter
  @Builder
  public static class StudyMilestoneItem {
    private final String code;
    private final String icon;
    private final String title;
    private final String description;
    private final boolean achieved;
    private final int progressPercent;
    private final String badgeLabel;

    public boolean isUnlocked() {
      return this.achieved;
    }
  }

  /**
   * Nhận xét phân tích thói quen học tập của học viên.
   */
  @Getter
  @Builder
  public static class StudyHabitInsight {
    private final String category;
    private final String headline;
    private final String detailText;
    private final String metricValue;
    private final String tone;
  }
}
