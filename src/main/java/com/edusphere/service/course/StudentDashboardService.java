package com.edusphere.service.course;

import com.edusphere.dto.course.CertificateView;
import com.edusphere.dto.course.EnrolledCourseView;
import com.edusphere.dto.course.StudentDashboardView;
import com.edusphere.dto.course.StudentDashboardView.ActiveCourseCard;
import com.edusphere.dto.course.StudentDashboardView.StudyHabitInsight;
import com.edusphere.dto.course.StudentDashboardView.StudyMilestoneItem;
import com.edusphere.entity.course.Lesson;
import com.edusphere.repository.course.CourseRatingRepository;
import com.edusphere.repository.course.LessonRepository;
import com.edusphere.repository.course.StudentStudyLogRepository;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;

/**
 * Dịch vụ tổng hợp dữ liệu cho trang Dashboard Học Viên (Student Dashboard).
 * Chịu trách nhiệm tính toán số giờ học thực tế, tỷ lệ đạt mục tiêu, chuỗi ngày học liên tiếp (streak),
 * dữ liệu biểu đồ theo chu kỳ 7 ngày / 30 ngày / 3 tháng, danh sách khóa học đang học và hệ thống huy hiệu thành tích.
 */
@Service
public class StudentDashboardService {

  private static final double DEFAULT_MINIMUM_TARGET_HOURS = 10.0;
  private static final double SECONDS_PER_HOUR = 3600.0;
  private static final double SECONDS_PER_MINUTE = 60.0;
  private static final String LESSON_PUBLISHED_STATUS = "PUBLISHED";
  private static final DateTimeFormatter SHORT_DAY_MONTH_FORMAT = DateTimeFormatter.ofPattern("dd/MM");
  private static final DateTimeFormatter MONTH_YEAR_KEY_FORMAT = DateTimeFormatter.ofPattern("MM/yyyy");

  private final CourseManagementService courseManagementService;
  private final StudentStudyLogRepository studyLogRepository;
  private final CourseRatingRepository ratingRepository;
  private final LessonRepository lessonDataRepository;
  private final ObjectMapper jsonMapper = new ObjectMapper();

  @Autowired(required = false)
  private CertificateService certificateService;

  public StudentDashboardService(
      final CourseManagementService courseManagementService,
      final StudentStudyLogRepository studentStudyLogRepository,
      final CourseRatingRepository courseRatingRepository,
      final LessonRepository lessonRepository) {
    this.courseManagementService = courseManagementService;
    this.studyLogRepository = studentStudyLogRepository;
    this.ratingRepository = courseRatingRepository;
    this.lessonDataRepository = lessonRepository;
  }

  /**
   * Tổng hợp toàn bộ dữ liệu hiển thị cho Dashboard của một học viên cụ thể.
   */
  @Transactional
  public StudentDashboardView getDashboard(final Integer studentId, final String studentFullName) {
    final List<EnrolledCourseView> enrolledList = this.courseManagementService != null
        ? this.courseManagementService.enrolledCourses(studentId)
        : Collections.emptyList();

    final List<CertificateView> issuedCertificates = this.certificateService != null
        ? this.certificateService.syncAndGetMyCertificates(studentId)
        : Collections.emptyList();

    final int totalEnrolled = enrolledList.size();
    final int totalCompleted = countCompletedCourses(enrolledList);
    final int totalInProgress = Math.max(0, totalEnrolled - totalCompleted);

    final long totalStudiedSeconds = safeSumDurationSeconds(studentId);
    final double totalStudiedHours = roundToOneDecimal(totalStudiedSeconds / SECONDS_PER_HOUR);

    final Map<Integer, Long> durationByCourseMap = loadDurationSecondsPerCourse(studentId);

    double accumulatedTargetHours = 0.0;
    final List<ActiveCourseCard> activeCourseCards = new ArrayList<>();
    final List<Integer> enrolledCourseIds = new ArrayList<>();

    for (final EnrolledCourseView enrolledItem : enrolledList) {
      if (enrolledItem == null || enrolledItem.getCourseId() == null) {
        continue;
      }
      final Integer courseId = enrolledItem.getCourseId();
      enrolledCourseIds.add(courseId);

      final double singleCourseTargetHours = computeTargetHoursForCourse(courseId);
      accumulatedTargetHours += singleCourseTargetHours;

      final long courseSeconds = durationByCourseMap.getOrDefault(courseId, 0L);
      final double courseHours = roundToOneDecimal(courseSeconds / SECONDS_PER_HOUR);

      if (!enrolledItem.isCompleted() || activeCourseCards.isEmpty()) {
        final String categoryPrefix = (enrolledItem.getCategoryName() != null
            && !enrolledItem.getCategoryName().isBlank())
            ? enrolledItem.getCategoryName().trim() + " • "
            : "";
        final String instructorLabel = enrolledItem.getInstructorName() != null
            ? enrolledItem.getInstructorName()
            : "Giảng viên EduSphere";
        final String cardSubtitle = categoryPrefix + "GV: " + instructorLabel;

        activeCourseCards.add(
            ActiveCourseCard.builder()
                .courseId(courseId)
                .title(enrolledItem.getTitle())
                .description(cardSubtitle)
                .thumbnailUrl(enrolledItem.getThumbnailUrl())
                .progressPercent(enrolledItem.getProgressPercent())
                .studiedHoursFormatted(formatHourValue(courseHours))
                .targetHoursFormatted(formatHourValue(singleCourseTargetHours))
                .completed(enrolledItem.isCompleted())
                .certificateId(enrolledItem.getCertificateId())
                .completedLessonsCount((int) enrolledItem.getCompletedLessons())
                .totalLessonsCount((int) enrolledItem.getTotalLessons())
                .categoryLabel(enrolledItem.getCategoryName())
                .instructorDisplayName(instructorLabel)
                .build()
        );
      }
    }

    activeCourseCards.sort((first, second) -> {
      final int statusCmp = Boolean.compare(first.isCompleted(), second.isCompleted());
      if (statusCmp != 0) {
        return statusCmp;
      }
      return Integer.compare(second.getProgressPercent(), first.getProgressPercent());
    });

    final double effectiveTargetHours = Math.max(
        DEFAULT_MINIMUM_TARGET_HOURS,
        roundToOneDecimal(accumulatedTargetHours)
    );
    final int goalCompletionPercent = effectiveTargetHours > 0.0
        ? (int) Math.min(100, Math.round((totalStudiedHours * 100.0) / effectiveTargetHours))
        : 0;

    final RatingSummaryStats ratingStats = calculateEnrolledCoursesRating(enrolledCourseIds);

    final LocalDate currentDay = LocalDate.now();
    final Map<LocalDate, Long> recent30DaysMap = loadDailySecondsMap(
        studentId,
        currentDay.minusDays(29),
        currentDay
    );

    final TimeChartPayload chart7dPayload = buildDailyChartSeries(
        recent30DaysMap,
        currentDay.minusDays(6),
        currentDay,
        true
    );
    final TimeChartPayload chart30dPayload = buildDailyChartSeries(
        recent30DaysMap,
        currentDay.minusDays(29),
        currentDay,
        false
    );
    final TimeChartPayload chart3mPayload = buildQuarterlyMonthlyChartSeries(studentId, currentDay);

    final StreakMetrics streakMetrics = computeStreakMetrics(recent30DaysMap, currentDay);
    final double weeklyHours = computeWindowHours(recent30DaysMap, currentDay.minusDays(6), currentDay);
    final double monthlyHours = computeWindowHours(recent30DaysMap, currentDay.minusDays(29), currentDay);
    final double avgDailyMinutes7d = roundToOneDecimal((weeklyHours * 60.0) / 7.0);
    final int earnedCreditsTotal = calculateTotalCreditsEarned(issuedCertificates);

    final AchievementBadgeInfo badgeInfo = resolveAchievementBadge(
        totalEnrolled,
        totalCompleted,
        totalStudiedHours
    );

    final List<StudyMilestoneItem> milestoneItems = buildStudyMilestoneItems(
        totalStudiedHours,
        totalCompleted,
        issuedCertificates.size(),
        streakMetrics.currentStreakDays
    );
    final List<StudyHabitInsight> habitInsights = buildStudyHabitInsights(
        totalStudiedHours,
        effectiveTargetHours,
        weeklyHours,
        streakMetrics.currentStreakDays,
        streakMetrics.activeDaysCount,
        totalCompleted,
        totalEnrolled
    );

    final String resolvedStudentName = (studentFullName != null && !studentFullName.isBlank())
        ? studentFullName.trim()
        : "Học viên";

    return StudentDashboardView.builder()
        .studentName(resolvedStudentName)
        .totalStudyHours(totalStudiedHours)
        .totalStudyHoursFormatted(formatHourValue(totalStudiedHours))
        .targetStudyHours(effectiveTargetHours)
        .targetStudyHoursFormatted(formatHourValue(effectiveTargetHours))
        .studyGoalPercent(goalCompletionPercent)
        .enrolledCoursesCount(totalEnrolled)
        .completedCoursesCount(totalCompleted)
        .inProgressCoursesCount(totalInProgress)
        .certificatesCount(issuedCertificates.size())
        .certificates(issuedCertificates)
        .hasRatings(ratingStats.hasRatings)
        .averageRatingFormatted(ratingStats.formattedRating)
        .activeCourses(activeCourseCards)
        .chart7dLabelsJson(serializeToJson(chart7dPayload.labels))
        .chart7dValuesJson(serializeToJson(chart7dPayload.values))
        .chart30dLabelsJson(serializeToJson(chart30dPayload.labels))
        .chart30dValuesJson(serializeToJson(chart30dPayload.values))
        .chart3mLabelsJson(serializeToJson(chart3mPayload.labels))
        .chart3mValuesJson(serializeToJson(chart3mPayload.values))
        .achievementTitle(badgeInfo.title)
        .achievementSubtitle(badgeInfo.subtitle)
        .currentStreakDays(streakMetrics.currentStreakDays)
        .longestStreakDays(streakMetrics.longestStreakDays)
        .activeStudyDaysLast30d(streakMetrics.activeDaysCount)
        .weeklyStudyHours(weeklyHours)
        .weeklyStudyHoursFormatted(formatHourValue(weeklyHours))
        .monthlyStudyHours(monthlyHours)
        .monthlyStudyHoursFormatted(formatHourValue(monthlyHours))
        .dailyAverageMinutesLast7d(avgDailyMinutes7d)
        .totalCreditsEarned(earnedCreditsTotal)
        .learningRankBadge(badgeInfo.rankLabel)
        .studyVelocityLabel(resolveVelocityLabel(weeklyHours, streakMetrics.currentStreakDays))
        .milestones(milestoneItems)
        .habitInsights(habitInsights)
        .build();
  }

  private int countCompletedCourses(final List<EnrolledCourseView> enrolledList) {
    if (enrolledList == null || enrolledList.isEmpty()) {
      return 0;
    }
    int count = 0;
    for (final EnrolledCourseView item : enrolledList) {
      if (item != null && item.isCompleted()) {
        count++;
      }
    }
    return count;
  }

  private long safeSumDurationSeconds(final Integer studentId) {
    if (studentId == null || this.studyLogRepository == null) {
      return 0L;
    }
    try {
      return Math.max(0L, this.studyLogRepository.sumDurationSecondsByStudentId(studentId));
    } catch (final Exception ignored) {
      return 0L;
    }
  }

  private Map<Integer, Long> loadDurationSecondsPerCourse(final Integer studentId) {
    final Map<Integer, Long> map = new HashMap<>();
    if (studentId == null || this.studyLogRepository == null) {
      return map;
    }
    final List<Object[]> rawRows = this.studyLogRepository.sumDurationSecondsByStudentIdGroupByCourse(studentId);
    if (rawRows == null) {
      return map;
    }
    for (final Object[] row : rawRows) {
      if (row != null && row.length >= 2 && row[0] instanceof Number cNum && row[1] instanceof Number sNum) {
        map.put(cNum.intValue(), Math.max(0L, sNum.longValue()));
      }
    }
    return map;
  }

  private double computeTargetHoursForCourse(final Integer courseId) {
    if (courseId == null || this.lessonDataRepository == null) {
      return DEFAULT_MINIMUM_TARGET_HOURS;
    }
    final List<Lesson> publishedLessons = this.lessonDataRepository
        .findByCourse_CourseIdAndStatusOrderByOrderIndexAsc(courseId, LESSON_PUBLISHED_STATUS);
    if (publishedLessons == null || publishedLessons.isEmpty()) {
      return DEFAULT_MINIMUM_TARGET_HOURS;
    }

    long totalVideoSecs = 0L;
    for (final Lesson lesson : publishedLessons) {
      if (lesson == null) {
        continue;
      }
      final Integer videoDur = lesson.getVideoDuration();
      if (videoDur != null && videoDur > 0) {
        final long normalizedSecs = videoDur > 60 ? videoDur.longValue() : videoDur * 60L;
        totalVideoSecs += normalizedSecs;
      }
    }

    if (totalVideoSecs <= 0L) {
      return DEFAULT_MINIMUM_TARGET_HOURS;
    }
    return Math.max(1.0, roundToOneDecimal(totalVideoSecs / SECONDS_PER_HOUR));
  }

  private RatingSummaryStats calculateEnrolledCoursesRating(final List<Integer> enrolledCourseIds) {
    if (enrolledCourseIds == null || enrolledCourseIds.isEmpty() || this.ratingRepository == null) {
      return new RatingSummaryStats(false, "--");
    }
    final List<Object[]> rows = this.ratingRepository.summarizeByCourseIds(enrolledCourseIds);
    if (rows == null || rows.isEmpty()) {
      return new RatingSummaryStats(false, "--");
    }

    double weightedRatingSum = 0.0;
    long totalReviewsCount = 0L;
    for (final Object[] row : rows) {
      if (row == null || row.length < 3) {
        continue;
      }
      final double avgVal = row[1] instanceof Number avgNum ? avgNum.doubleValue() : 0.0;
      final long countVal = row[2] instanceof Number cntNum ? cntNum.longValue() : 0L;
      if (countVal > 0L && avgVal > 0.0) {
        weightedRatingSum += (avgVal * countVal);
        totalReviewsCount += countVal;
      }
    }

    if (totalReviewsCount <= 0L) {
      return new RatingSummaryStats(false, "--");
    }
    final double overallAverage = weightedRatingSum / totalReviewsCount;
    return new RatingSummaryStats(true, String.format(Locale.US, "%.1f", overallAverage));
  }

  private Map<LocalDate, Long> loadDailySecondsMap(
      final Integer studentId,
      final LocalDate startDate,
      final LocalDate endDate) {
    final Map<LocalDate, Long> dailySeconds = new LinkedHashMap<>();
    if (studentId == null || this.studyLogRepository == null) {
      return dailySeconds;
    }
    final List<Object[]> rows = this.studyLogRepository.sumDailyDurationSeconds(studentId, startDate, endDate);
    if (rows == null) {
      return dailySeconds;
    }
    for (final Object[] row : rows) {
      if (row != null && row.length >= 2) {
        final LocalDate parsedDate = convertToLocalDate(row[0]);
        final long seconds = row[1] instanceof Number num ? Math.max(0L, num.longValue()) : 0L;
        if (parsedDate != null) {
          dailySeconds.merge(parsedDate, seconds, Long::sum);
        }
      }
    }
    return dailySeconds;
  }

  private TimeChartPayload buildDailyChartSeries(
      final Map<LocalDate, Long> dailySecondsMap,
      final LocalDate startDate,
      final LocalDate endDate,
      final boolean useVietnameseWeekdayLabel) {
    final List<String> chartLabels = new ArrayList<>();
    final List<Double> chartValues = new ArrayList<>();

    LocalDate dayCursor = startDate;
    while (!dayCursor.isAfter(endDate)) {
      final String pointLabel = useVietnameseWeekdayLabel
          ? resolveVietnameseWeekdayLabel(dayCursor.getDayOfWeek())
          : dayCursor.format(SHORT_DAY_MONTH_FORMAT);
      chartLabels.add(pointLabel);

      final long daySeconds = dailySecondsMap.getOrDefault(dayCursor, 0L);
      chartValues.add(roundToTwoDecimals(daySeconds / SECONDS_PER_HOUR));
      dayCursor = dayCursor.plusDays(1);
    }

    return new TimeChartPayload(chartLabels, chartValues);
  }

  private TimeChartPayload buildQuarterlyMonthlyChartSeries(
      final Integer studentId,
      final LocalDate referenceToday) {
    final LocalDate firstDayThreeMonthsAgo = referenceToday.minusMonths(2).withDayOfMonth(1);
    final Map<String, Long> monthlyBucketSeconds = new HashMap<>();

    if (studentId != null && this.studyLogRepository != null) {
      final List<Object[]> rows = this.studyLogRepository.sumDailyDurationSeconds(
          studentId,
          firstDayThreeMonthsAgo,
          referenceToday
      );
      if (rows != null) {
        for (final Object[] row : rows) {
          if (row != null && row.length >= 2) {
            final LocalDate logDate = convertToLocalDate(row[0]);
            final long secs = row[1] instanceof Number num ? Math.max(0L, num.longValue()) : 0L;
            if (logDate != null) {
              final String monthKey = logDate.format(MONTH_YEAR_KEY_FORMAT);
              monthlyBucketSeconds.merge(monthKey, secs, Long::sum);
            }
          }
        }
      }
    }

    final List<String> monthLabels = new ArrayList<>();
    final List<Double> monthHours = new ArrayList<>();
    for (int offset = 2; offset >= 0; offset--) {
      final LocalDate targetMonth = referenceToday.minusMonths(offset);
      final String monthKey = targetMonth.format(MONTH_YEAR_KEY_FORMAT);
      monthLabels.add("Tháng " + targetMonth.getMonthValue());
      final long totalMonthSecs = monthlyBucketSeconds.getOrDefault(monthKey, 0L);
      monthHours.add(roundToTwoDecimals(totalMonthSecs / SECONDS_PER_HOUR));
    }

    return new TimeChartPayload(monthLabels, monthHours);
  }

  private StreakMetrics computeStreakMetrics(
      final Map<LocalDate, Long> dailySecondsMap,
      final LocalDate today) {
    int activeDays = 0;
    int longestStreak = 0;
    int runningStreak = 0;

    LocalDate cursor = today.minusDays(29);
    while (!cursor.isAfter(today)) {
      final long secs = dailySecondsMap.getOrDefault(cursor, 0L);
      if (secs > 0L) {
        activeDays++;
        runningStreak++;
        if (runningStreak > longestStreak) {
          longestStreak = runningStreak;
        }
      } else {
        runningStreak = 0;
      }
      cursor = cursor.plusDays(1);
    }

    int currentStreak = 0;
    LocalDate backwardsCursor = today;
    if (dailySecondsMap.getOrDefault(today, 0L) <= 0L
        && dailySecondsMap.getOrDefault(today.minusDays(1), 0L) > 0L) {
      backwardsCursor = today.minusDays(1);
    }
    while (!backwardsCursor.isBefore(today.minusDays(29))) {
      if (dailySecondsMap.getOrDefault(backwardsCursor, 0L) > 0L) {
        currentStreak++;
        backwardsCursor = backwardsCursor.minusDays(1);
      } else {
        break;
      }
    }

    return new StreakMetrics(currentStreak, longestStreak, activeDays);
  }

  private double computeWindowHours(
      final Map<LocalDate, Long> dailySecondsMap,
      final LocalDate fromDate,
      final LocalDate toDate) {
    long sumSeconds = 0L;
    LocalDate cursor = fromDate;
    while (!cursor.isAfter(toDate)) {
      sumSeconds += dailySecondsMap.getOrDefault(cursor, 0L);
      cursor = cursor.plusDays(1);
    }
    return roundToOneDecimal(sumSeconds / SECONDS_PER_HOUR);
  }

  private int calculateTotalCreditsEarned(final List<CertificateView> certs) {
    if (certs == null || certs.isEmpty()) {
      return 0;
    }
    int total = 0;
    for (final CertificateView c : certs) {
      if (c != null && c.getCreditsEarned() != null && c.getCreditsEarned() > 0) {
        total += c.getCreditsEarned();
      }
    }
    return total;
  }

  private AchievementBadgeInfo resolveAchievementBadge(
      final int enrolledCount,
      final int completedCount,
      final double totalHours) {
    if (completedCount >= 2) {
      return new AchievementBadgeInfo(
          "Học viên xuất sắc",
          "Hoàn thành " + completedCount + " khóa học",
          "Hạng Kim Cương"
      );
    }
    if (completedCount == 1) {
      return new AchievementBadgeInfo(
          "Học viên bứt phá",
          "Hoàn thành 1 khóa học • " + formatHourValue(totalHours) + " giờ học",
          "Hạng Vàng"
      );
    }
    if (totalHours >= 1.0) {
      return new AchievementBadgeInfo(
          "Học viên chăm chỉ",
          "Đã tích lũy " + formatHourValue(totalHours) + " giờ học",
          "Hạng Bạc"
      );
    }
    final String fallbackSubtitle = enrolledCount > 0
        ? "Đang theo học " + enrolledCount + " khóa học"
        : "Bắt đầu bài học đầu tiên ngay hôm nay";
    return new AchievementBadgeInfo(
        "Khởi đầu hành trình",
        fallbackSubtitle,
        "Hạng Đồng"
    );
  }

  private String resolveVelocityLabel(final double weeklyHours, final int currentStreak) {
    if (weeklyHours >= 5.0 || currentStreak >= 5) {
      return "Tốc độ học tập cao";
    }
    if (weeklyHours >= 2.0 || currentStreak >= 2) {
      return "Nhịp độ học ổn định";
    }
    if (weeklyHours > 0.0) {
      return "Đang khởi động tuần mới";
    }
    return "Chưa ghi nhận giờ học tuần này";
  }

  private List<StudyMilestoneItem> buildStudyMilestoneItems(
      final double totalHours,
      final int completedCourses,
      final int certificatesCount,
      final int streakDays) {
    final List<StudyMilestoneItem> items = new ArrayList<>();

    items.add(
        StudyMilestoneItem.builder()
            .code("MILESTONE_FIRST_HOUR")
            .icon("⏱️")
            .title("Giờ học đầu tiên")
            .description("Hoàn thành 1 giờ học tập tích lũy trên EduSphere")
            .achieved(totalHours >= 1.0)
            .progressPercent((int) Math.min(100, Math.round(totalHours * 100.0)))
            .badgeLabel(totalHours >= 1.0 ? "Đã đạt" : "Đang thực hiện")
            .build()
    );

    items.add(
        StudyMilestoneItem.builder()
            .code("MILESTONE_STREAK_3D")
            .icon("🔥")
            .title("Chuỗi 3 ngày liên tiếp")
            .description("Duy trì thói quen vào học 3 ngày liên tục")
            .achieved(streakDays >= 3)
            .progressPercent((int) Math.min(100, Math.round((streakDays / 3.0) * 100.0)))
            .badgeLabel(streakDays >= 3 ? "Đã đạt" : (streakDays + "/3 ngày"))
            .build()
    );

    items.add(
        StudyMilestoneItem.builder()
            .code("MILESTONE_FIRST_COURSE")
            .icon("🎓")
            .title("Tốt nghiệp khóa đầu tiên")
            .description("Hoàn thành 100% bài giảng và nhận chứng chỉ khóa học")
            .achieved(completedCourses >= 1 || certificatesCount >= 1)
            .progressPercent((completedCourses >= 1 || certificatesCount >= 1) ? 100 : 0)
            .badgeLabel((completedCourses >= 1 || certificatesCount >= 1) ? "Đã đạt" : "Chưa mở khóa")
            .build()
    );

    items.add(
        StudyMilestoneItem.builder()
            .code("MILESTONE_TEN_HOURS")
            .icon("🚀")
            .title("Chuyên cần 10 giờ")
            .description("Tích lũy 10 giờ học chuyên sâu trên toàn hệ thống")
            .achieved(totalHours >= 10.0)
            .progressPercent((int) Math.min(100, Math.round((totalHours / 10.0) * 100.0)))
            .badgeLabel(totalHours >= 10.0 ? "Đã đạt" : (formatHourValue(totalHours) + "/10h"))
            .build()
    );

    return items;
  }

  private List<StudyHabitInsight> buildStudyHabitInsights(
      final double totalHours,
      final double targetHours,
      final double weeklyHours,
      final int currentStreak,
      final int activeDays30d,
      final int completedCourses,
      final int enrolledCourses) {
    final List<StudyHabitInsight> list = new ArrayList<>();

    list.add(
        StudyHabitInsight.builder()
            .category("THỜI LƯỢNG TUẦN")
            .headline("7 ngày gần nhất")
            .detailText(weeklyHours > 0
                ? "Bạn đã dành " + formatHourValue(weeklyHours) + " giờ học trong tuần qua."
                : "Hãy dành ít nhất 15-30 phút hôm nay để duy trì đà học tập.")
            .metricValue(formatHourValue(weeklyHours) + " giờ")
            .tone(weeklyHours >= 2.0 ? "positive" : "neutral")
            .build()
    );

    list.add(
        StudyHabitInsight.builder()
            .category("ĐỘ ĐỀU ĐẶN")
            .headline("Tần suất học 30 ngày")
            .detailText("Ghi nhận hoạt động học tập trong " + activeDays30d
                + "/30 ngày gần đây (Chuỗi hiện tại: " + currentStreak + " ngày).")
            .metricValue(activeDays30d + " ngày")
            .tone(activeDays30d >= 7 ? "positive" : "info")
            .build()
    );

    final double remaining = Math.max(0.0, targetHours - totalHours);
    list.add(
        StudyHabitInsight.builder()
            .category("MỤC TIÊU")
            .headline("Tiến độ hoàn thành")
            .detailText(remaining <= 0.0
                ? "Bạn đã vượt mục tiêu " + formatHourValue(targetHours) + " giờ học đề ra!"
                : "Còn " + formatHourValue(remaining) + " giờ học nữa để cán đích mục tiêu.")
            .metricValue(completedCourses + "/" + enrolledCourses + " khóa")
            .tone(remaining <= 0.0 ? "positive" : "warning")
            .build()
    );

    return list;
  }

  private LocalDate convertToLocalDate(final Object rawDateValue) {
    if (rawDateValue instanceof LocalDate localDate) {
      return localDate;
    }
    if (rawDateValue instanceof java.sql.Date sqlDate) {
      return sqlDate.toLocalDate();
    }
    if (rawDateValue != null) {
      try {
        return LocalDate.parse(rawDateValue.toString());
      } catch (final Exception ignored) {
        return null;
      }
    }
    return null;
  }

  private String resolveVietnameseWeekdayLabel(final DayOfWeek dayOfWeek) {
    if (dayOfWeek == null) {
      return "";
    }
    return switch (dayOfWeek) {
      case MONDAY -> "Thứ 2";
      case TUESDAY -> "Thứ 3";
      case WEDNESDAY -> "Thứ 4";
      case THURSDAY -> "Thứ 5";
      case FRIDAY -> "Thứ 6";
      case SATURDAY -> "Thứ 7";
      case SUNDAY -> "CN";
    };
  }

  private double roundToOneDecimal(final double value) {
    return Math.round(value * 10.0) / 10.0;
  }

  private double roundToTwoDecimals(final double value) {
    return Math.round(value * 100.0) / 100.0;
  }

  private String formatHourValue(final double hours) {
    if (Math.abs(hours - Math.rint(hours)) < 0.05) {
      return String.valueOf((long) Math.rint(hours));
    }
    return String.format(Locale.US, "%.1f", hours);
  }

  private String serializeToJson(final Object payload) {
    try {
      return this.jsonMapper.writeValueAsString(payload);
    } catch (final JsonProcessingException ex) {
      return "[]";
    }
  }

  private record TimeChartPayload(List<String> labels, List<Double> values) {
  }

  private record RatingSummaryStats(boolean hasRatings, String formattedRating) {
  }

  private record StreakMetrics(int currentStreakDays, int longestStreakDays, int activeDaysCount) {
  }

  private record AchievementBadgeInfo(String title, String subtitle, String rankLabel) {
  }
}
