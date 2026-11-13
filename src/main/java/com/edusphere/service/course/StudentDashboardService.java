package com.edusphere.service.course;

import com.edusphere.dto.course.StudentDashboardView;
import com.edusphere.entity.course.Course;
import com.edusphere.entity.course.CourseComment;
import com.edusphere.entity.course.Enrollment;
import com.edusphere.entity.course.Lesson;
import com.edusphere.repository.course.CourseCommentRepository;
import com.edusphere.repository.course.EnrollmentRepository;
import com.edusphere.repository.course.LessonCompletionRepository;
import com.edusphere.repository.course.LessonRepository;
import com.edusphere.repository.course.StudyTimeLogRepository;
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

    private static final String PUBLISHED = "PUBLISHED";
    /** Bài học không có thông tin thời lượng được tính mặc định 15 phút. */
    private static final int DEFAULT_LESSON_SECONDS = 15 * 60;
    private static final DateTimeFormatter DD_MM = DateTimeFormatter.ofPattern("dd/MM");

    private final EnrollmentRepository enrollmentRepository;
    private final LessonRepository lessonRepository;
    private final LessonCompletionRepository lessonCompletionRepository;
    private final StudyTimeLogRepository studyTimeLogRepository;
    private final CourseCommentRepository commentRepository;

    public StudentDashboardService(EnrollmentRepository enrollmentRepository,
                                   LessonRepository lessonRepository,
                                   LessonCompletionRepository lessonCompletionRepository,
                                   StudyTimeLogRepository studyTimeLogRepository,
                                   CourseCommentRepository commentRepository) {
        this.enrollmentRepository = enrollmentRepository;
        this.lessonRepository = lessonRepository;
        this.lessonCompletionRepository = lessonCompletionRepository;
        this.studyTimeLogRepository = studyTimeLogRepository;
        this.commentRepository = commentRepository;
    }

    @Transactional(readOnly = true)
    public StudentDashboardView build(Integer studentId, String fullName) {
        StudentDashboardView view = new StudentDashboardView();
        view.setFullName(fullName);

        // ---- Thời gian học theo khóa học ----
        Map<Integer, Long> secondsByCourse = new HashMap<>();
        long totalSeconds = 0;
        for (Object[] row : studyTimeLogRepository.sumSecondsByCourse(studentId)) {
            long sec = ((Number) row[1]).longValue();
            secondsByCourse.put(((Number) row[0]).intValue(), sec);
            totalSeconds += sec;
        }

        // ---- Khóa học đã ghi danh ----
        List<Enrollment> enrollments = new ArrayList<>();
        for (Enrollment e : enrollmentRepository.findByStudent_UserIdOrderByEnrolledAtDesc(studentId)) {
            if (!"DROPPED".equalsIgnoreCase(e.getStatus())) {
                enrollments.add(e);
            }
        }

        double targetHoursSum = 0;
        int completed = 0;
        int lessonsDone = 0;
        List<StudentDashboardView.CourseItem> active = new ArrayList<>();

        for (Enrollment e : enrollments) {
            Course c = e.getCourse();
            List<Lesson> lessons = lessonRepository
                    .findByCourse_CourseIdAndStatusOrderByOrderIndexAsc(c.getCourseId(), PUBLISHED);
            int totalLessons = lessons.size();
            int doneLessons = (int) Math.min(totalLessons,
                    lessonCompletionRepository.countByStudent_UserIdAndCourse_CourseId(studentId, c.getCourseId()));
            lessonsDone += doneLessons;

            double target = targetHours(lessons);
            targetHoursSum += target;
            double studied = secondsByCourse.getOrDefault(c.getCourseId(), 0L) / 3600.0;
            int pct = totalLessons > 0 ? (int) Math.round(doneLessons * 100.0 / totalLessons) : 0;

            boolean isCompleted = "COMPLETED".equalsIgnoreCase(e.getStatus()) || (totalLessons > 0 && doneLessons >= totalLessons);
            if (isCompleted) {
                completed++;
                continue;
            }

            StudentDashboardView.CourseItem item = new StudentDashboardView.CourseItem();
            item.setCourseId(c.getCourseId());
            item.setTitle(c.getTitle());
            String desc = c.getDescription() == null ? "" : c.getDescription().trim();
            item.setSummary(desc.length() > 140 ? desc.substring(0, 140) + "…" : desc);
            item.setThumbnailUrl(c.getThumbnailUrl());
            item.setProgressPercent(pct);
            item.setCompletedLessons(doneLessons);
            item.setTotalLessons(totalLessons);
            item.setHoursStudied(round1(studied));
            item.setTargetHours(round1(target));
            item.setHoursStudiedLabel(hoursLabel(studied));
            item.setTargetHoursLabel(hoursLabel(target));
            active.add(item);
        }

        double studiedHours = totalSeconds / 3600.0;
        view.setHoursStudied(round1(studiedHours));
        view.setTargetHours(round1(targetHoursSum));
        view.setHoursStudiedLabel(hoursLabel(studiedHours));
        view.setTargetHoursLabel(hoursLabel(targetHoursSum));
        view.setHoursPercent(targetHoursSum > 0 ? (int) Math.min(100, Math.round(studiedHours * 100.0 / targetHoursSum)) : 0);
        view.setEnrolledCount(enrollments.size());
        view.setCompletedCount(completed);
        view.setInProgressCount(active.size());
        view.setLessonsCompleted(lessonsDone);
        view.setActiveCourses(active);

        // ---- Đánh giá trung bình (do chính học viên đánh giá các khóa học) ----
        List<CourseComment> ratings = commentRepository
                .findByUser_UserIdAndRatingIsNotNullAndStatus(studentId, "ACTIVE");
        if (!ratings.isEmpty()) {
            double avg = ratings.stream().mapToInt(CourseComment::getRating).average().orElse(0);
            view.setAverageRating(round1(avg));
            view.setRatingCount(ratings.size());
        }

        // ---- Thời gian học theo ngày: biểu đồ, hôm nay, chuỗi ngày ----
        LocalDate today = LocalDate.now();
        Map<LocalDate, Long> secondsByDay = new HashMap<>();
        for (Object[] row : studyTimeLogRepository.sumSecondsByDay(studentId, today.minusDays(89))) {
            secondsByDay.put((LocalDate) row[0], ((Number) row[1]).longValue());
        }
        view.setTodayMinutes((int) (secondsByDay.getOrDefault(today, 0L) / 60));
        view.setChart7Json(dailyChart(secondsByDay, today, 7, true));
        view.setChart30Json(dailyChart(secondsByDay, today, 30, false));
        view.setChart90Json(weeklyChart(secondsByDay, today, 13));
        view.setStreakDays(streak(studyTimeLogRepository.findStudyDates(studentId), today));

        // ---- Thành tích ----
        if (completed >= 2) {
            view.setAchievementTitle("Học viên xuất sắc");
        } else if (completed == 1) {
            view.setAchievementTitle("Học viên chăm chỉ");
        } else if (totalSeconds > 0) {
            view.setAchievementTitle("Học viên đang tiến bộ");
        } else {
            view.setAchievementTitle("Bắt đầu hành trình học tập");
        }
        view.setAchievementDesc(completed > 0
                ? "Hoàn thành " + completed + " khóa học"
                : "Hoàn thành khóa học đầu tiên để mở khóa thành tích");

        return view;
    }

    // ------------------------------------------------------------------ helpers

    private double targetHours(List<Lesson> lessons) {
        long seconds = 0;
        for (Lesson l : lessons) {
            Integer d = l.getVideoDuration();
            if (d != null && d > 0) {
                // Quy ước dữ liệu hiện có: > 60 là giây, ngược lại là phút
                seconds += d > 60 ? d : d * 60L;
            } else {
                seconds += DEFAULT_LESSON_SECONDS;
            }
        }
        return Math.max(0.5, seconds / 3600.0);
    }

    private String dailyChart(Map<LocalDate, Long> secondsByDay, LocalDate today, int days, boolean weekdayLabels) {
        List<String> labels = new ArrayList<>();
        List<Double> values = new ArrayList<>();
        for (int i = days - 1; i >= 0; i--) {
            LocalDate d = today.minusDays(i);
            labels.add(weekdayLabels ? weekdayLabel(d.getDayOfWeek()) : d.format(DD_MM));
            values.add(round2(secondsByDay.getOrDefault(d, 0L) / 3600.0));
        }
        return toJson(labels, values);
    }

    private String weeklyChart(Map<LocalDate, Long> secondsByDay, LocalDate today, int weeks) {
        List<String> labels = new ArrayList<>();
        List<Double> values = new ArrayList<>();
        for (int w = weeks - 1; w >= 0; w--) {
            LocalDate end = today.minusDays(w * 7L);
            LocalDate start = end.minusDays(6);
            long sec = 0;
            for (int i = 0; i < 7; i++) {
                sec += secondsByDay.getOrDefault(start.plusDays(i), 0L);
            }
            labels.add(start.format(DD_MM));
            values.add(round2(sec / 3600.0));
        }
        return toJson(labels, values);
    }

    private int streak(List<LocalDate> studyDatesDesc, LocalDate today) {
        if (studyDatesDesc.isEmpty()) {
            return 0;
        }
        LocalDate expected = studyDatesDesc.get(0).equals(today) ? today : today.minusDays(1);
        int count = 0;
        for (LocalDate d : studyDatesDesc) {
            if (d.equals(expected)) {
                count++;
                expected = expected.minusDays(1);
            } else if (d.isBefore(expected)) {
                break;
            }
        }
        return count;
    }

    private String weekdayLabel(DayOfWeek dow) {
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

    private String toJson(List<String> labels, List<Double> values) {
        StringBuilder sb = new StringBuilder("{\"labels\":[");
        for (int i = 0; i < labels.size(); i++) {
            if (i > 0) sb.append(',');
            sb.append('"').append(labels.get(i)).append('"');
        }
        sb.append("],\"values\":[");
        for (int i = 0; i < values.size(); i++) {
            if (i > 0) sb.append(',');
            sb.append(String.format(Locale.ROOT, "%.2f", values.get(i)));
        }
        sb.append("]}");
        return sb.toString();
    }

    private String hoursLabel(double hours) {
        double r = round1(hours);
        if (r == Math.floor(r)) {
            return String.valueOf((int) r);
        }
        return String.format(Locale.ROOT, "%.1f", r);
    }

    private double round1(double v) {
        return Math.round(v * 10.0) / 10.0;
    }

    private double round2(double v) {
        return Math.round(v * 100.0) / 100.0;
    }
}
