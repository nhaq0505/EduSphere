package com.edusphere.service.course;

import com.edusphere.dto.course.CertificateView;
import com.edusphere.dto.course.EnrolledCourseView;
import com.edusphere.dto.course.StudentDashboardView;
import com.edusphere.dto.course.StudentDashboardView.ActiveCourseCard;
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
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;

@Service
public class StudentDashboardService {

    private static final double DEFAULT_TARGET_HOURS = 10.0;
    private static final DateTimeFormatter SHORT_DATE_FMT = DateTimeFormatter.ofPattern("dd/MM");
    private static final DateTimeFormatter MONTH_FMT = DateTimeFormatter.ofPattern("MM/yyyy");

    private final CourseManagementService courseManagementService;
    private final StudentStudyLogRepository studentStudyLogRepository;
    private final CourseRatingRepository courseRatingRepository;
    private final LessonRepository lessonRepository;
    private final ObjectMapper objectMapper = new ObjectMapper();

    @Autowired(required = false)
    private CertificateService certificateService;

    public StudentDashboardService(CourseManagementService courseManagementService,
                                   StudentStudyLogRepository studentStudyLogRepository,
                                   CourseRatingRepository courseRatingRepository,
                                   LessonRepository lessonRepository) {
        this.courseManagementService = courseManagementService;
        this.studentStudyLogRepository = studentStudyLogRepository;
        this.courseRatingRepository = courseRatingRepository;
        this.lessonRepository = lessonRepository;
    }

    @Transactional
    public StudentDashboardView getDashboard(Integer studentId, String studentFullName) {
        List<EnrolledCourseView> enrolled = courseManagementService.enrolledCourses(studentId);
        List<CertificateView> certs = certificateService != null
                ? certificateService.syncAndGetMyCertificates(studentId)
                : List.of();
        int enrolledCount = enrolled.size();
        int completedCount = (int) enrolled.stream().filter(EnrolledCourseView::isCompleted).count();
        int inProgressCount = Math.max(0, enrolledCount - completedCount);

        long totalSeconds = studentStudyLogRepository.sumDurationSecondsByStudentId(studentId);
        double totalHours = roundOneDecimal(totalSeconds / 3600.0);

        Map<Integer, Long> secondsByCourse = new HashMap<>();
        for (Object[] row : studentStudyLogRepository.sumDurationSecondsByStudentIdGroupByCourse(studentId)) {
            Integer cId = ((Number) row[0]).intValue();
            long secs = ((Number) row[1]).longValue();
            secondsByCourse.put(cId, secs);
        }

        // Tính tổng giờ mục tiêu dựa trên thời lượng video các khóa học (tối thiểu 10 giờ)
        double computedTargetHours = 0.0;
        List<ActiveCourseCard> activeCards = new ArrayList<>();
        List<Integer> enrolledCourseIds = new ArrayList<>();

        for (EnrolledCourseView c : enrolled) {
            enrolledCourseIds.add(c.getCourseId());
            double courseTargetHours = computeCourseTargetHours(c.getCourseId());
            computedTargetHours += courseTargetHours;

            long courseSecs = secondsByCourse.getOrDefault(c.getCourseId(), 0L);
            double courseStudiedHours = roundOneDecimal(courseSecs / 3600.0);

            if (!c.isCompleted() || activeCards.isEmpty()) {
                String subtitle = (c.getCategoryName() != null && !c.getCategoryName().isBlank() ? c.getCategoryName() + " • " : "")
                        + "GV: " + c.getInstructorName();
                activeCards.add(ActiveCourseCard.builder()
                        .courseId(c.getCourseId())
                        .title(c.getTitle())
                        .description(subtitle)
                        .thumbnailUrl(c.getThumbnailUrl())
                        .progressPercent(c.getProgressPercent())
                        .studiedHoursFormatted(formatHours(courseStudiedHours))
                        .targetHoursFormatted(formatHours(courseTargetHours))
                        .completed(c.isCompleted())
                        .certificateId(c.getCertificateId())
                        .build());
            }
        }

        // Ưu tiên hiển thị các khóa đang học (chưa hoàn thành) lên đầu
        activeCards.sort((a, b) -> Boolean.compare(a.isCompleted(), b.isCompleted()));

        double targetHours = Math.max(DEFAULT_TARGET_HOURS, roundOneDecimal(computedTargetHours));
        int goalPercent = targetHours > 0
                ? (int) Math.min(100, Math.round((totalHours * 100.0) / targetHours))
                : 0;

        // Đánh giá trung bình của các khóa học đã tham gia
        boolean hasRatings = false;
        String avgRatingFormatted = "--";
        if (!enrolledCourseIds.isEmpty()) {
            List<Object[]> ratingRows = courseRatingRepository.summarizeByCourseIds(enrolledCourseIds);
            double sumWeighted = 0.0;
            long totalRatingsCount = 0L;
            for (Object[] row : ratingRows) {
                double avg = row[1] != null ? ((Number) row[1]).doubleValue() : 0.0;
                long cnt = row[2] != null ? ((Number) row[2]).longValue() : 0L;
                sumWeighted += avg * cnt;
                totalRatingsCount += cnt;
            }
            if (totalRatingsCount > 0) {
                hasRatings = true;
                double overallAvg = sumWeighted / totalRatingsCount;
                avgRatingFormatted = String.format(Locale.US, "%.1f", overallAvg);
            }
        }

        // Dữ liệu biểu đồ 7 ngày / 30 ngày / 3 tháng
        LocalDate today = LocalDate.now();
        ChartSeries chart7d = buildDailyChart(studentId, today.minusDays(6), today, true);
        ChartSeries chart30d = buildDailyChart(studentId, today.minusDays(29), today, false);
        ChartSeries chart3m = buildMonthlyChart(studentId, today);

        // Thành tích của bạn (dựa trên khóa hoàn thành & số giờ học, không dùng chứng chỉ)
        String achievementTitle;
        String achievementSubtitle;
        if (completedCount >= 2) {
            achievementTitle = "Học viên xuất sắc";
            achievementSubtitle = "Hoàn thành " + completedCount + " khóa học";
        } else if (completedCount == 1) {
            achievementTitle = "Học viên bứt phá";
            achievementSubtitle = "Hoàn thành 1 khóa học • " + formatHours(totalHours) + " giờ học";
        } else if (totalHours >= 1.0) {
            achievementTitle = "Học viên chăm chỉ";
            achievementSubtitle = "Đã tích lũy " + formatHours(totalHours) + " giờ học";
        } else {
            achievementTitle = "Khởi đầu hành trình";
            achievementSubtitle = enrolledCount > 0
                    ? "Đang theo học " + enrolledCount + " khóa học"
                    : "Bắt đầu bài học đầu tiên ngay hôm nay";
        }

        return StudentDashboardView.builder()
                .studentName(studentFullName != null && !studentFullName.isBlank() ? studentFullName : "Học viên")
                .totalStudyHours(totalHours)
                .totalStudyHoursFormatted(formatHours(totalHours))
                .targetStudyHours(targetHours)
                .targetStudyHoursFormatted(formatHours(targetHours))
                .studyGoalPercent(goalPercent)
                .enrolledCoursesCount(enrolledCount)
                .completedCoursesCount(completedCount)
                .inProgressCoursesCount(inProgressCount)
                .certificatesCount(certs.size())
                .certificates(certs)
                .hasRatings(hasRatings)
                .averageRatingFormatted(avgRatingFormatted)
                .activeCourses(activeCards)
                .chart7dLabelsJson(toJson(chart7d.labels))
                .chart7dValuesJson(toJson(chart7d.values))
                .chart30dLabelsJson(toJson(chart30d.labels))
                .chart30dValuesJson(toJson(chart30d.values))
                .chart3mLabelsJson(toJson(chart3m.labels))
                .chart3mValuesJson(toJson(chart3m.values))
                .achievementTitle(achievementTitle)
                .achievementSubtitle(achievementSubtitle)
                .build();
    }

    private double computeCourseTargetHours(Integer courseId) {
        List<Lesson> lessons = lessonRepository.findByCourse_CourseIdAndStatusOrderByOrderIndexAsc(courseId, "PUBLISHED");
        long totalVideoSeconds = 0L;
        for (Lesson lesson : lessons) {
            Integer dur = lesson.getVideoDuration();
            if (dur != null && dur > 0) {
                totalVideoSeconds += dur > 60 ? dur : dur * 60L;
            }
        }
        if (totalVideoSeconds <= 0) {
            return DEFAULT_TARGET_HOURS;
        }
        return Math.max(1.0, roundOneDecimal(totalVideoSeconds / 3600.0));
    }

    private ChartSeries buildDailyChart(Integer studentId, LocalDate start, LocalDate end, boolean useWeekdayNames) {
        Map<LocalDate, Long> dailySeconds = new HashMap<>();
        for (Object[] row : studentStudyLogRepository.sumDailyDurationSeconds(studentId, start, end)) {
            LocalDate date = toLocalDate(row[0]);
            long secs = ((Number) row[1]).longValue();
            if (date != null) {
                dailySeconds.put(date, secs);
            }
        }

        List<String> labels = new ArrayList<>();
        List<Double> values = new ArrayList<>();
        LocalDate cursor = start;
        while (!cursor.isAfter(end)) {
            labels.add(useWeekdayNames ? formatVietnameseDayOfWeek(cursor.getDayOfWeek()) : cursor.format(SHORT_DATE_FMT));
            long secs = dailySeconds.getOrDefault(cursor, 0L);
            values.add(roundTwoDecimals(secs / 3600.0));
            cursor = cursor.plusDays(1);
        }
        return new ChartSeries(labels, values);
    }

    private ChartSeries buildMonthlyChart(Integer studentId, LocalDate today) {
        LocalDate start = today.minusMonths(2).withDayOfMonth(1);
        Map<String, Long> monthlySeconds = new HashMap<>();
        for (Object[] row : studentStudyLogRepository.sumDailyDurationSeconds(studentId, start, today)) {
            LocalDate date = toLocalDate(row[0]);
            long secs = ((Number) row[1]).longValue();
            if (date != null) {
                String key = date.format(MONTH_FMT);
                monthlySeconds.merge(key, secs, Long::sum);
            }
        }

        List<String> labels = new ArrayList<>();
        List<Double> values = new ArrayList<>();
        for (int i = 2; i >= 0; i--) {
            LocalDate m = today.minusMonths(i);
            String key = m.format(MONTH_FMT);
            labels.add("Tháng " + m.getMonthValue());
            values.add(roundTwoDecimals(monthlySeconds.getOrDefault(key, 0L) / 3600.0));
        }
        return new ChartSeries(labels, values);
    }

    private LocalDate toLocalDate(Object val) {
        if (val instanceof LocalDate ld) {
            return ld;
        }
        if (val instanceof java.sql.Date sd) {
            return sd.toLocalDate();
        }
        if (val != null) {
            return LocalDate.parse(val.toString());
        }
        return null;
    }

    private String formatVietnameseDayOfWeek(DayOfWeek dow) {
        return switch (dow) {
            case MONDAY -> "Thứ 2";
            case TUESDAY -> "Thứ 3";
            case WEDNESDAY -> "Thứ 4";
            case THURSDAY -> "Thứ 5";
            case FRIDAY -> "Thứ 6";
            case SATURDAY -> "Thứ 7";
            case SUNDAY -> "CN";
        };
    }

    private double roundOneDecimal(double val) {
        return Math.round(val * 10.0) / 10.0;
    }

    private double roundTwoDecimals(double val) {
        return Math.round(val * 100.0) / 100.0;
    }

    private String formatHours(double hours) {
        if (Math.abs(hours - Math.rint(hours)) < 0.05) {
            return String.valueOf((long) Math.rint(hours));
        }
        return String.format(Locale.US, "%.1f", hours);
    }

    private String toJson(Object data) {
        try {
            return objectMapper.writeValueAsString(data);
        } catch (JsonProcessingException e) {
            return "[]";
        }
    }

    private record ChartSeries(List<String> labels, List<Double> values) {
    }
}
