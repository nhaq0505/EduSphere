package com.edusphere.service.course;

import com.edusphere.entity.account.Users;
import com.edusphere.entity.course.Enrollment;
import com.edusphere.entity.course.Lesson;
import com.edusphere.entity.course.StudyTimeLog;
import com.edusphere.repository.account.UserRepository;
import com.edusphere.repository.course.EnrollmentRepository;
import com.edusphere.repository.course.LessonRepository;
import com.edusphere.repository.course.StudyTimeLogRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Collections;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;

/**
 * Dịch vụ ghi nhận và phân tích thời gian học tập (tính bằng giây) theo từng ngày,
 * từng khóa học và từng bài giảng để phục vụ thống kê số giờ học trên Dashboard Học Viên.
 */
@Service
public class StudyTimeService {

  /** Giới hạn số giây tối đa cho mỗi lần ping để chống gian lận (ping ~5s, cho phép tối đa 60s). */
  private static final int MAX_SECONDS_PER_RECORD = 60;
  private static final int SECONDS_IN_MINUTE = 60;
  private static final int SECONDS_IN_HOUR = 3600;
  private static final int DAILY_RECOMMENDED_MINUTES = 30;

  private final StudyTimeLogRepository logRepository;
  private final EnrollmentRepository enrollmentRepository;
  private final LessonRepository lessonRepository;
  private final UserRepository userRepository;

  public StudyTimeService(
      final StudyTimeLogRepository logRepository,
      final EnrollmentRepository enrollmentRepository,
      final LessonRepository lessonRepository,
      final UserRepository userRepository) {
    this.logRepository = logRepository;
    this.enrollmentRepository = enrollmentRepository;
    this.lessonRepository = lessonRepository;
    this.userRepository = userRepository;
  }

  /**
   * Ghi nhận thêm {@code seconds} giây học cho cặp (học viên, bài học) trong ngày hôm nay.
   */
  @Transactional
  public void record(
      final Integer studentId,
      final Integer courseId,
      final Integer lessonId,
      final int seconds) {
    recordForDate(studentId, courseId, lessonId, seconds, LocalDate.now());
  }

  /**
   * Ghi nhận thời gian học tập cho một ngày cụ thể với đầy đủ kiểm tra hợp lệ.
   */
  @Transactional
  public int recordForDate(
      final Integer studentId,
      final Integer courseId,
      final Integer lessonId,
      final int seconds,
      final LocalDate targetDate) {
    if (studentId == null || courseId == null || lessonId == null || seconds <= 0) {
      return 0;
    }
    final int boundedSeconds = normalizeDurationSeconds(seconds);
    if (boundedSeconds <= 0) {
      return 0;
    }

    final Enrollment enrollment = this.enrollmentRepository
        .findByStudent_UserIdAndCourse_CourseId(studentId, courseId)
        .orElse(null);
    if (enrollment == null || "DROPPED".equalsIgnoreCase(enrollment.getStatus())) {
      return 0;
    }

    final LocalDate effectiveDate = targetDate != null ? targetDate : LocalDate.now();
    StudyTimeLog studyLog = this.logRepository
        .findByStudent_UserIdAndLesson_LessonIdAndStudyDate(studentId, lessonId, effectiveDate)
        .orElse(null);

    if (studyLog == null) {
      final Lesson lesson = this.lessonRepository
          .findByLessonIdAndCourse_CourseId(lessonId, courseId)
          .orElse(null);
      final Users student = this.userRepository.findById(studentId).orElse(null);
      if (lesson == null || student == null) {
        return 0;
      }
      studyLog = new StudyTimeLog();
      studyLog.setStudent(student);
      studyLog.setCourse(lesson.getCourse());
      studyLog.setLesson(lesson);
      studyLog.setStudyDate(effectiveDate);
      studyLog.setSecondsStudied(0);
    }

    final int previousSeconds = studyLog.getSecondsStudied() != null ? studyLog.getSecondsStudied() : 0;
    final int updatedSeconds = previousSeconds + boundedSeconds;
    studyLog.setSecondsStudied(updatedSeconds);
    studyLog.setUpdatedAt(LocalDateTime.now());
    this.logRepository.save(studyLog);
    return updatedSeconds;
  }

  /**
   * Tính tổng số giây học viên đã tích lũy trên toàn bộ các khóa học.
   */
  @Transactional(readOnly = true)
  public long getTotalSecondsForStudent(final Integer studentId) {
    if (studentId == null || this.logRepository == null) {
      return 0L;
    }
    try {
      final List<Object[]> courseRows = this.logRepository.sumSecondsByCourse(studentId);
      if (courseRows == null) {
        return 0L;
      }
      long sum = 0L;
      for (final Object[] row : courseRows) {
        if (row != null && row.length >= 2 && row[1] instanceof Number num) {
          sum += Math.max(0L, num.longValue());
        }
      }
      return sum;
    } catch (final Exception ignored) {
      return 0L;
    }
  }

  /**
   * Tính tổng số giờ học viên đã tích lũy (làm tròn 1 chữ số thập phân).
   */
  @Transactional(readOnly = true)
  public double getTotalHoursForStudent(final Integer studentId) {
    final long totalSecs = getTotalSecondsForStudent(studentId);
    return Math.round((totalSecs / (double) SECONDS_IN_HOUR) * 10.0) / 10.0;
  }

  /**
   * Tính tổng số giây học viên đã học trong một khóa học cụ thể.
   */
  @Transactional(readOnly = true)
  public long getCourseSecondsForStudent(final Integer studentId, final Integer courseId) {
    if (studentId == null || courseId == null || this.logRepository == null) {
      return 0L;
    }
    try {
      final List<Object[]> courseRows = this.logRepository.sumSecondsByCourse(studentId);
      if (courseRows == null) {
        return 0L;
      }
      for (final Object[] row : courseRows) {
        if (row != null && row.length >= 2 && row[0] instanceof Number cId) {
          if (cId.intValue() == courseId && row[1] instanceof Number secs) {
            return Math.max(0L, secs.longValue());
          }
        }
      }
      return 0L;
    } catch (final Exception ignored) {
      return 0L;
    }
  }

  /**
   * Tính tổng số giờ học của học viên trong một khóa học cụ thể.
   */
  @Transactional(readOnly = true)
  public double getCourseHoursForStudent(final Integer studentId, final Integer courseId) {
    final long secs = getCourseSecondsForStudent(studentId, courseId);
    return Math.round((secs / (double) SECONDS_IN_HOUR) * 10.0) / 10.0;
  }

  /**
   * Lấy bản đồ số giây học tập theo từng ngày trong khoảng [fromDate, toDate].
   */
  @Transactional(readOnly = true)
  public Map<LocalDate, Long> getDailyStudySeconds(
      final Integer studentId,
      final LocalDate fromDate,
      final LocalDate toDate) {
    final Map<LocalDate, Long> result = new LinkedHashMap<>();
    if (fromDate == null || toDate == null || fromDate.isAfter(toDate)) {
      return result;
    }

    LocalDate initCursor = fromDate;
    while (!initCursor.isAfter(toDate)) {
      result.put(initCursor, 0L);
      initCursor = initCursor.plusDays(1);
    }

    if (studentId == null || this.logRepository == null) {
      return result;
    }

    final List<Object[]> rows = this.logRepository.sumSecondsByDay(studentId, fromDate);
    if (rows != null) {
      for (final Object[] row : rows) {
        if (row != null && row.length >= 2) {
          final LocalDate day = parseLocalDate(row[0]);
          final long secs = row[1] instanceof Number num ? Math.max(0L, num.longValue()) : 0L;
          if (day != null && result.containsKey(day)) {
            result.put(day, secs);
          }
        }
      }
    }
    return result;
  }

  /**
   * Tính chuỗi ngày học liên tiếp (streak) của học viên trong 30 ngày gần nhất.
   */
  @Transactional(readOnly = true)
  public int calculateCurrentStreakDays(final Integer studentId) {
    if (studentId == null) {
      return 0;
    }
    final LocalDate today = LocalDate.now();
    final Map<LocalDate, Long> last30Days = getDailyStudySeconds(studentId, today.minusDays(29), today);
    int streak = 0;
    LocalDate cursor = today;
    if (last30Days.getOrDefault(today, 0L) <= 0L
        && last30Days.getOrDefault(today.minusDays(1), 0L) > 0L) {
      cursor = today.minusDays(1);
    }
    while (!cursor.isBefore(today.minusDays(29))) {
      if (last30Days.getOrDefault(cursor, 0L) > 0L) {
        streak++;
        cursor = cursor.minusDays(1);
      } else {
        break;
      }
    }
    return streak;
  }

  /**
   * Tổng hợp báo cáo tiến độ thời gian học tập trong tuần hiện tại của học viên.
   */
  @Transactional(readOnly = true)
  public Map<String, Object> buildWeeklyStudyReport(final Integer studentId) {
    final LocalDate today = LocalDate.now();
    final LocalDate startOfWindow = today.minusDays(6);
    final Map<LocalDate, Long> dailyMap = getDailyStudySeconds(studentId, startOfWindow, today);

    long totalWeekSecs = 0L;
    int activeDays = 0;
    long peakDaySecs = 0L;
    LocalDate peakDate = today;

    for (final Map.Entry<LocalDate, Long> entry : dailyMap.entrySet()) {
      final long secs = entry.getValue() != null ? entry.getValue() : 0L;
      totalWeekSecs += secs;
      if (secs > 0L) {
        activeDays++;
      }
      if (secs > peakDaySecs) {
        peakDaySecs = secs;
        peakDate = entry.getKey();
      }
    }

    final double totalWeekHours = Math.round((totalWeekSecs / (double) SECONDS_IN_HOUR) * 10.0) / 10.0;
    final int avgMinutesPerDay = (int) Math.round((totalWeekSecs / (double) SECONDS_IN_MINUTE) / 7.0);
    final boolean meetsRecommendedPace = avgMinutesPerDay >= DAILY_RECOMMENDED_MINUTES;

    final Map<String, Object> report = new LinkedHashMap<>();
    report.put("totalWeekSeconds", totalWeekSecs);
    report.put("totalWeekHours", totalWeekHours);
    report.put("totalWeekHoursFormatted", formatHoursLabel(totalWeekHours));
    report.put("activeDaysInWeek", activeDays);
    report.put("averageMinutesPerDay", avgMinutesPerDay);
    report.put("peakDate", peakDate.toString());
    report.put("peakDayMinutes", (int) Math.round(peakDaySecs / (double) SECONDS_IN_MINUTE));
    report.put("meetsRecommendedPace", meetsRecommendedPace);
    return report;
  }

  public int normalizeDurationSeconds(final int rawSeconds) {
    if (rawSeconds <= 0) {
      return 0;
    }
    return Math.min(rawSeconds, MAX_SECONDS_PER_RECORD);
  }

  public String formatHoursLabel(final double hours) {
    if (Math.abs(hours - Math.rint(hours)) < 0.05) {
      return String.valueOf((long) Math.rint(hours));
    }
    return String.format(Locale.US, "%.1f", hours);
  }

  public List<String> buildStudyTipsForPace(final int averageDailyMinutes, final int streakDays) {
    final List<String> tips = new ArrayList<>();
    if (streakDays >= 5) {
      tips.add("Bạn đang giữ chuỗi " + streakDays + " ngày học liên tiếp rất ấn tượng!");
    } else {
      tips.add("Hãy cố gắng hoàn thành ít nhất 1 bài giảng mỗi ngày để xây dựng chuỗi ngày học liên tục.");
    }
    if (averageDailyMinutes >= DAILY_RECOMMENDED_MINUTES) {
      tips.add("Thời lượng học trung bình mỗi ngày của bạn đạt mức khuyến nghị (" + averageDailyMinutes + " phút/ngày).");
    } else {
      tips.add("Tăng thời lượng học lên 30 phút/ngày sẽ giúp bạn rút ngắn 40% thời gian hoàn thành khóa học.");
    }
    return Collections.unmodifiableList(tips);
  }

  private LocalDate parseLocalDate(final Object raw) {
    if (raw instanceof LocalDate ld) {
      return ld;
    }
    if (raw instanceof java.sql.Date sd) {
      return sd.toLocalDate();
    }
    if (raw != null) {
      try {
        return LocalDate.parse(raw.toString());
      } catch (final Exception ignored) {
        return null;
      }
    }
    return null;
  }
}
