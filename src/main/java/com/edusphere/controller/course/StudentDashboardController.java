package com.edusphere.controller.course;

import com.edusphere.dto.course.CertificateView;
import com.edusphere.dto.course.StudentDashboardView;
import com.edusphere.dto.course.StudentDashboardView.ActiveCourseCard;
import com.edusphere.security.CustomUserDetails;
import com.edusphere.service.course.StudentDashboardService;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;

/**
 * Controller phụ trách không gian Dashboard Học Viên (Student Dashboard).
 * Cung cấp trang tổng quan tiến độ học tập, thống kê số giờ học theo tuần/tháng/quý,
 * danh sách khóa học đang theo học, thành tích cá nhân và các endpoint dữ liệu bổ trợ.
 */
@Controller
@PreAuthorize("hasAnyRole('STUDENT', 'INSTRUCTOR', 'ADMINISTRATOR')")
public class StudentDashboardController {

  private static final String LOGIN_REDIRECT_VIEW = "redirect:/login";
  private static final String STUDENT_DASHBOARD_VIEW = "courses/student-dashboard";
  private static final DateTimeFormatter ISO_DATE_FORMATTER = DateTimeFormatter.ofPattern("yyyy-MM-dd");

  private final StudentDashboardService dashboardService;

  public StudentDashboardController(final StudentDashboardService dashboardService) {
    this.dashboardService = dashboardService;
  }

  /**
   * Hiển thị giao diện chính của Student Dashboard tại đường dẫn /student/dashboard.
   */
  @GetMapping(value = "/student/dashboard")
  public String studentDashboard(
      @AuthenticationPrincipal final CustomUserDetails authenticatedUser,
      @RequestParam(value = "range", required = false, defaultValue = "7d") final String defaultRange,
      @RequestParam(value = "filter", required = false, defaultValue = "all") final String courseFilter,
      final Model viewModel) {
    if (authenticatedUser == null) {
      return LOGIN_REDIRECT_VIEW;
    }

    final Integer studentUserId = authenticatedUser.getUserId();
    final String studentDisplayName = resolveStudentDisplayName(authenticatedUser);

    final StudentDashboardView dashboardData = this.dashboardService.getDashboard(
        studentUserId,
        studentDisplayName
    );

    final Map<String, Object> quickSummary = buildQuickSummaryMetrics(dashboardData);
    final List<Map<String, Object>> milestoneCards = buildLearningMilestoneCards(dashboardData);
    final List<Map<String, String>> studyRecommendations = buildPersonalizedRecommendations(dashboardData);

    viewModel.addAttribute("dashboard", dashboardData);
    viewModel.addAttribute("selectedRange", normalizeRangeKey(defaultRange));
    viewModel.addAttribute("selectedCourseFilter", normalizeFilterKey(courseFilter));
    viewModel.addAttribute("dashboardQuickSummary", quickSummary);
    viewModel.addAttribute("dashboardMilestones", milestoneCards);
    viewModel.addAttribute("dashboardRecommendations", studyRecommendations);
    viewModel.addAttribute("dashboardGeneratedDate", LocalDate.now().format(ISO_DATE_FORMATTER));

    return STUDENT_DASHBOARD_VIEW;
  }

  /**
   * API JSON trả về dữ liệu thống kê tổng quan của học viên phục vụ đồng bộ biểu đồ hoặc widget.
   */
  @GetMapping(value = "/student/dashboard/summary-json", produces = MediaType.APPLICATION_JSON_VALUE)
  @ResponseBody
  public ResponseEntity<Map<String, Object>> studentDashboardSummaryJson(
      @AuthenticationPrincipal final CustomUserDetails authenticatedUser,
      @RequestParam(value = "range", required = false, defaultValue = "7d") final String rangeKey) {
    if (authenticatedUser == null) {
      final Map<String, Object> unauthPayload = new LinkedHashMap<>();
      unauthPayload.put("authenticated", Boolean.FALSE);
      unauthPayload.put("message", "Vui lòng đăng nhập để xem thống kê học tập.");
      return ResponseEntity.status(401).body(unauthPayload);
    }

    final Integer studentUserId = authenticatedUser.getUserId();
    final String studentDisplayName = resolveStudentDisplayName(authenticatedUser);
    final StudentDashboardView dashboardData = this.dashboardService.getDashboard(
        studentUserId,
        studentDisplayName
    );

    final Map<String, Object> responsePayload = new LinkedHashMap<>();
    responsePayload.put("authenticated", Boolean.TRUE);
    responsePayload.put("studentId", studentUserId);
    responsePayload.put("studentName", dashboardData.getStudentName());
    responsePayload.put("range", normalizeRangeKey(rangeKey));
    responsePayload.put("totalStudyHours", dashboardData.getTotalStudyHours());
    responsePayload.put("totalStudyHoursFormatted", dashboardData.getTotalStudyHoursFormatted());
    responsePayload.put("targetStudyHours", dashboardData.getTargetStudyHours());
    responsePayload.put("targetStudyHoursFormatted", dashboardData.getTargetStudyHoursFormatted());
    responsePayload.put("studyGoalPercent", dashboardData.getStudyGoalPercent());
    responsePayload.put("enrolledCoursesCount", dashboardData.getEnrolledCoursesCount());
    responsePayload.put("completedCoursesCount", dashboardData.getCompletedCoursesCount());
    responsePayload.put("inProgressCoursesCount", dashboardData.getInProgressCoursesCount());
    responsePayload.put("certificatesCount", dashboardData.getCertificatesCount());
    responsePayload.put("hasRatings", dashboardData.isHasRatings());
    responsePayload.put("averageRatingFormatted", dashboardData.getAverageRatingFormatted());
    responsePayload.put("achievementTitle", dashboardData.getAchievementTitle());
    responsePayload.put("achievementSubtitle", dashboardData.getAchievementSubtitle());
    responsePayload.put("milestones", buildLearningMilestoneCards(dashboardData));
    responsePayload.put("recommendations", buildPersonalizedRecommendations(dashboardData));

    return ResponseEntity.ok(responsePayload);
  }

  /**
   * API JSON trả về danh sách khóa học đang học được lọc theo trạng thái.
   */
  @GetMapping(value = "/student/dashboard/courses-json", produces = MediaType.APPLICATION_JSON_VALUE)
  @ResponseBody
  public ResponseEntity<Map<String, Object>> studentDashboardCoursesJson(
      @AuthenticationPrincipal final CustomUserDetails authenticatedUser,
      @RequestParam(value = "status", required = false, defaultValue = "all") final String statusFilter) {
    if (authenticatedUser == null) {
      final Map<String, Object> unauth = new LinkedHashMap<>();
      unauth.put("authenticated", Boolean.FALSE);
      return ResponseEntity.status(401).body(unauth);
    }

    final StudentDashboardView dashboardData = this.dashboardService.getDashboard(
        authenticatedUser.getUserId(),
        resolveStudentDisplayName(authenticatedUser)
    );

    final String normalizedStatus = normalizeFilterKey(statusFilter);
    final List<Map<String, Object>> filteredCourses = new ArrayList<>();
    if (dashboardData.getActiveCourses() != null) {
      for (final ActiveCourseCard card : dashboardData.getActiveCourses()) {
        if ("completed".equals(normalizedStatus) && !card.isCompleted()) {
          continue;
        }
        if ("in-progress".equals(normalizedStatus) && card.isCompleted()) {
          continue;
        }
        final Map<String, Object> item = new LinkedHashMap<>();
        item.put("courseId", card.getCourseId());
        item.put("title", card.getTitle());
        item.put("description", card.getDescription());
        item.put("thumbnailUrl", card.getThumbnailUrl());
        item.put("progressPercent", card.getProgressPercent());
        item.put("studiedHoursFormatted", card.getStudiedHoursFormatted());
        item.put("targetHoursFormatted", card.getTargetHoursFormatted());
        item.put("completed", card.isCompleted());
        item.put("certificateId", card.getCertificateId());
        item.put("progressTier", classifyProgressTier(card.getProgressPercent(), card.isCompleted()));
        filteredCourses.add(item);
      }
    }

    final Map<String, Object> result = new LinkedHashMap<>();
    result.put("authenticated", Boolean.TRUE);
    result.put("filter", normalizedStatus);
    result.put("count", filteredCourses.size());
    result.put("courses", filteredCourses);
    return ResponseEntity.ok(result);
  }

  private String resolveStudentDisplayName(final CustomUserDetails authenticatedUser) {
    if (authenticatedUser == null) {
      return "Học viên";
    }
    final String rawName = authenticatedUser.getFullName();
    if (rawName != null && !rawName.trim().isEmpty()) {
      return rawName.trim();
    }
    final String username = authenticatedUser.getUsername();
    if (username != null && !username.trim().isEmpty()) {
      final int atIndex = username.indexOf('@');
      return atIndex > 0 ? username.substring(0, atIndex) : username.trim();
    }
    return "Học viên";
  }

  private String normalizeRangeKey(final String rawRange) {
    if (rawRange == null || rawRange.isBlank()) {
      return "7d";
    }
    final String clean = rawRange.trim().toLowerCase(Locale.ROOT);
    return switch (clean) {
      case "30d", "30", "month" -> "30d";
      case "3m", "90d", "90", "quarter" -> "3m";
      default -> "7d";
    };
  }

  private String normalizeFilterKey(final String rawFilter) {
    if (rawFilter == null || rawFilter.isBlank()) {
      return "all";
    }
    final String clean = rawFilter.trim().toLowerCase(Locale.ROOT);
    return switch (clean) {
      case "completed", "done" -> "completed";
      case "in-progress", "active", "studying" -> "in-progress";
      default -> "all";
    };
  }

  private String classifyProgressTier(final int progressPercent, final boolean completed) {
    if (completed || progressPercent >= 100) {
      return "COMPLETED";
    }
    if (progressPercent >= 75) {
      return "ALMOST_DONE";
    }
    if (progressPercent >= 35) {
      return "STEADY_PROGRESS";
    }
    if (progressPercent > 0) {
      return "JUST_STARTED";
    }
    return "NOT_STARTED";
  }

  private Map<String, Object> buildQuickSummaryMetrics(final StudentDashboardView view) {
    final Map<String, Object> summary = new LinkedHashMap<>();
    if (view == null) {
      summary.put("completionRatePercent", 0);
      summary.put("remainingGoalHoursFormatted", "10");
      summary.put("paceStatusLabel", "Khởi động");
      return summary;
    }

    final int enrolled = Math.max(0, view.getEnrolledCoursesCount());
    final int completed = Math.max(0, view.getCompletedCoursesCount());
    final int completionRate = enrolled > 0
        ? (int) Math.min(100, Math.round((completed * 100.0) / enrolled))
        : 0;

    final double remainingHours = Math.max(0.0, view.getTargetStudyHours() - view.getTotalStudyHours());
    final String remainingFormatted = Math.abs(remainingHours - Math.rint(remainingHours)) < 0.05
        ? String.valueOf((long) Math.rint(remainingHours))
        : String.format(Locale.US, "%.1f", remainingHours);

    final String paceLabel;
    if (view.getStudyGoalPercent() >= 100) {
      paceLabel = "Hoàn thành mục tiêu";
    } else if (view.getStudyGoalPercent() >= 60) {
      paceLabel = "Tiến độ rất tốt";
    } else if (view.getStudyGoalPercent() >= 25) {
      paceLabel = "Đang duy trì nhịp học";
    } else {
      paceLabel = "Khởi động hành trình";
    }

    int totalCredits = 0;
    if (view.getCertificates() != null) {
      for (final CertificateView cert : view.getCertificates()) {
        if (cert != null && cert.getCreditsEarned() != null) {
          totalCredits += cert.getCreditsEarned();
        }
      }
    }

    summary.put("completionRatePercent", completionRate);
    summary.put("remainingGoalHoursFormatted", remainingFormatted);
    summary.put("paceStatusLabel", paceLabel);
    summary.put("totalCreditsEarned", totalCredits);
    return summary;
  }

  private List<Map<String, Object>> buildLearningMilestoneCards(final StudentDashboardView view) {
    final List<Map<String, Object>> milestones = new ArrayList<>();
    final double hours = view != null ? view.getTotalStudyHours() : 0.0;
    final int completed = view != null ? view.getCompletedCoursesCount() : 0;
    final int certs = view != null ? view.getCertificatesCount() : 0;

    final Map<String, Object> firstHour = new LinkedHashMap<>();
    firstHour.put("code", "FIRST_HOUR");
    firstHour.put("title", "Khởi đầu bền bỉ");
    firstHour.put("description", "Tích lũy tối thiểu 1 giờ học tập thực tế trên hệ thống");
    firstHour.put("unlocked", hours >= 1.0);
    firstHour.put("progressPercent", (int) Math.min(100, Math.round(hours * 100.0)));
    milestones.add(firstHour);

    final Map<String, Object> tenHours = new LinkedHashMap<>();
    tenHours.put("code", "TEN_HOURS");
    tenHours.put("title", "Chinh phục 10 giờ học");
    tenHours.put("description", "Đạt mốc 10 giờ học tập chuyên sâu");
    tenHours.put("unlocked", hours >= 10.0);
    tenHours.put("progressPercent", (int) Math.min(100, Math.round((hours / 10.0) * 100.0)));
    milestones.add(tenHours);

    final Map<String, Object> firstCert = new LinkedHashMap<>();
    firstCert.put("code", "FIRST_CERTIFICATE");
    firstCert.put("title", "Chứng chỉ đầu tiên");
    firstCert.put("description", "Hoàn thành 100% một khóa học và nhận chứng chỉ điện tử");
    firstCert.put("unlocked", completed >= 1 || certs >= 1);
    firstCert.put("progressPercent", (completed >= 1 || certs >= 1) ? 100 : 0);
    milestones.add(firstCert);

    final Map<String, Object> multiCourse = new LinkedHashMap<>();
    multiCourse.put("code", "MULTI_COURSE_MASTER");
    multiCourse.put("title", "Học viên toàn diện");
    multiCourse.put("description", "Hoàn thành từ 3 khóa học trở lên");
    multiCourse.put("unlocked", completed >= 3);
    multiCourse.put("progressPercent", (int) Math.min(100, Math.round((completed / 3.0) * 100.0)));
    milestones.add(multiCourse);

    return milestones;
  }

  private List<Map<String, String>> buildPersonalizedRecommendations(final StudentDashboardView view) {
    final List<Map<String, String>> recs = new ArrayList<>();
    if (view == null) {
      return recs;
    }

    if (view.getEnrolledCoursesCount() == 0) {
      final Map<String, String> r = new LinkedHashMap<>();
      r.put("icon", "🚀");
      r.put("title", "Đăng ký khóa học đầu tiên");
      r.put("detail", "Khám phá danh mục khóa học đa dạng để bắt đầu tích lũy giờ học và chứng chỉ.");
      r.put("actionUrl", "/courses");
      r.put("actionLabel", "Khám phá ngay");
      recs.add(r);
      return recs;
    }

    if (view.getActiveCourses() != null && !view.getActiveCourses().isEmpty()) {
      ActiveCourseCard bestCandidate = null;
      for (final ActiveCourseCard c : view.getActiveCourses()) {
        if (!c.isCompleted()) {
          if (bestCandidate == null || c.getProgressPercent() > bestCandidate.getProgressPercent()) {
            bestCandidate = c;
          }
        }
      }
      if (bestCandidate != null) {
        final Map<String, String> r = new LinkedHashMap<>();
        r.put("icon", "🎯");
        r.put("title", "Hoàn thiện khóa học: " + bestCandidate.getTitle());
        r.put("detail", "Bạn đã đạt " + bestCandidate.getProgressPercent()
            + "% tiến độ. Hãy tiếp tục học để sớm nhận chứng chỉ hoàn thành!");
        r.put("actionUrl", "/courses/" + bestCandidate.getCourseId() + "/learn");
        r.put("actionLabel", "Tiếp tục học");
        recs.add(r);
      }
    }

    if (view.getStudyGoalPercent() < 100) {
      final Map<String, String> r = new LinkedHashMap<>();
      r.put("icon", "⏱️");
      r.put("title", "Duy trì thói quen 30 phút mỗi ngày");
      r.put("detail", "Bạn đã hoàn thành " + view.getStudyGoalPercent()
          + "% mục tiêu giờ học. Học đều đặn mỗi ngày giúp ghi nhớ kiến thức lâu hơn.");
      r.put("actionUrl", "/planning/plans");
      r.put("actionLabel", "Lập kế hoạch học");
      recs.add(r);
    }

    if (view.getCertificatesCount() > 0) {
      final Map<String, String> r = new LinkedHashMap<>();
      r.put("icon", "🏅");
      r.put("title", "Chia sẻ hồ sơ chứng chỉ của bạn");
      r.put("detail", "Bạn đã sở hữu " + view.getCertificatesCount()
          + " chứng chỉ EduSphere. Tải ảnh chứng chỉ độ phân giải cao hoặc thêm vào LinkedIn.");
      r.put("actionUrl", "/certificates");
      r.put("actionLabel", "Mở kho chứng chỉ");
      recs.add(r);
    }

    return recs;
  }
}
