package com.edusphere.service.course;

import com.edusphere.dto.result.ResultRow;
import com.edusphere.dto.result.StudentResultsView;
import com.edusphere.entity.course.Course;
import com.edusphere.entity.course.Grade;
import com.edusphere.entity.course.QuizAttempt;
import com.edusphere.entity.course.Submission;
import com.edusphere.repository.course.CourseRepository;
import com.edusphere.repository.course.EnrollmentRepository;
import com.edusphere.repository.course.GradeRepository;
import com.edusphere.repository.course.QuizAttemptRepository;
import com.edusphere.repository.course.SubmissionRepository;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.stream.Collectors;

import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * UC32 Publish Learning Results (Instructor) và UC33 View Learning Results (Student).
 * Tổng hợp điểm bài tập + quiz; việc công bố từng mục dùng lại AssignmentService / QuizService.
 * Mở rộng thêm thống kê phân bố điểm (Gradebook Analytics), lọc theo trạng thái/loại bài và tổng hợp theo học viên.
 */
@Service
public class LearningResultService {

  private static final String NOT_GRADED = "NOT_GRADED";
  private static final String READY = "READY";
  private static final String PUBLISHED = "PUBLISHED";

  private static final String KIND_ASSIGNMENT = "ASSIGNMENT";
  private static final String KIND_QUIZ = "QUIZ";

  private final CourseRepository courses;
  private final EnrollmentRepository enrollments;
  private final SubmissionRepository submissions;
  private final GradeRepository grades;
  private final QuizAttemptRepository attempts;
  private final AssignmentService assignmentService;
  private final QuizService quizService;

  public LearningResultService(
      CourseRepository courses,
      EnrollmentRepository enrollments,
      SubmissionRepository submissions,
      GradeRepository grades,
      QuizAttemptRepository attempts,
      AssignmentService assignmentService,
      QuizService quizService) {
    this.courses = courses;
    this.enrollments = enrollments;
    this.submissions = submissions;
    this.grades = grades;
    this.attempts = attempts;
    this.assignmentService = assignmentService;
    this.quizService = quizService;
  }

  // ===================== UC32 — INSTRUCTOR =====================

  @Transactional(readOnly = true)
  public Course ownedCourse(Integer courseId, Integer instructorId) {
    Course course = courses.findById(courseId)
        .orElseThrow(() -> new CourseActionException(HttpStatus.NOT_FOUND, "Không tìm thấy khóa học."));
    if (course.getInstructor() == null || !course.getInstructor().getUserId().equals(instructorId)) {
      throw new CourseActionException(HttpStatus.NOT_FOUND, "Không tìm thấy khóa học của bạn.");
    }
    return course;
  }

  /**
   * Toàn bộ kết quả của khóa học (mọi học viên), kèm trạng thái để giảng viên kiểm tra trước khi công bố.
   */
  @Transactional(readOnly = true)
  public List<ResultRow> instructorOverview(Integer courseId, Integer instructorId) {
    ownedCourse(courseId, instructorId);
    List<ResultRow> rows = new ArrayList<>();

    List<Submission> courseSubmissions = submissions.findByCourse_CourseIdOrderBySubmittedAtDesc(courseId);
    if (courseSubmissions != null) {
      for (Submission s : courseSubmissions) {
        if (s == null) {
          continue;
        }
        Grade grade = grades.findBySubmission_SubmissionId(s.getSubmissionId()).orElse(null);
        rows.add(assignmentRow(s, grade, true));
      }
    }

    List<QuizAttempt> courseAttempts = attempts.findByCourse_CourseIdAndStatusInOrderBySubmittedAtDesc(
        courseId, List.of("SUBMITTED", "SCORED"));
    if (courseAttempts != null) {
      for (QuizAttempt a : courseAttempts) {
        if (a == null) {
          continue;
        }
        rows.add(quizRow(a, true));
      }
    }

    rows.sort(Comparator.comparing(
        ResultRow::getSubmittedAt,
        Comparator.nullsLast(Comparator.reverseOrder())));
    return rows;
  }

  /**
   * Lọc danh sách kết quả của giảng viên theo loại bài (ALL / QUIZ / ASSIGNMENT),
   * trạng thái (ALL / PUBLISHED / READY / NOT_GRADED) và từ khóa tên học viên / tiêu đề.
   */
  @Transactional(readOnly = true)
  public List<ResultRow> filterInstructorOverview(
      Integer courseId,
      Integer instructorId,
      String kindFilter,
      String stateFilter,
      String keyword) {
    List<ResultRow> allRows = instructorOverview(courseId, instructorId);
    String normalizedKind = kindFilter == null ? "ALL" : kindFilter.trim().toUpperCase(Locale.ROOT);
    String normalizedState = stateFilter == null ? "ALL" : stateFilter.trim().toUpperCase(Locale.ROOT);
    String normalizedKeyword = keyword == null ? "" : keyword.trim().toLowerCase(Locale.ROOT);

    List<ResultRow> filtered = new ArrayList<>();
    for (ResultRow row : allRows) {
      if (row == null) {
        continue;
      }
      if (!"ALL".equals(normalizedKind) && !normalizedKind.isEmpty()) {
        if (!normalizedKind.equalsIgnoreCase(row.getKind())) {
          continue;
        }
      }
      if (!"ALL".equals(normalizedState) && !normalizedState.isEmpty()) {
        if (!normalizedState.equalsIgnoreCase(row.getState())) {
          continue;
        }
      }
      if (!normalizedKeyword.isEmpty()) {
        String title = row.getTitle() != null ? row.getTitle().toLowerCase(Locale.ROOT) : "";
        String studentName = row.getStudentName() != null ? row.getStudentName().toLowerCase(Locale.ROOT) : "";
        if (!title.contains(normalizedKeyword) && !studentName.contains(normalizedKeyword)) {
          continue;
        }
      }
      filtered.add(row);
    }
    return filtered;
  }

  @Transactional
  public void publishAssignment(
      Integer courseId,
      Integer assignmentId,
      Integer submissionId,
      Integer instructorId) {
    assignmentService.publishGrade(courseId, assignmentId, submissionId, instructorId);
  }

  @Transactional
  public void publishQuiz(
      Integer courseId,
      Integer quizId,
      Integer attemptId,
      Integer instructorId) {
    quizService.publishAttemptResult(courseId, quizId, attemptId, instructorId);
  }

  /**
   * Công bố tất cả kết quả đã chấm xong nhưng chưa công bố. Trả về số mục đã công bố.
   */
  @Transactional
  public int publishAllReady(Integer courseId, Integer instructorId) {
    int count = 0;
    for (ResultRow row : instructorOverview(courseId, instructorId)) {
      if (row == null || !READY.equals(row.getState())) {
        continue;
      }
      if (KIND_ASSIGNMENT.equals(row.getKind())) {
        assignmentService.publishGrade(courseId, row.getParentId(), row.getRefId(), instructorId);
      } else {
        quizService.publishAttemptResult(courseId, row.getParentId(), row.getRefId(), instructorId);
      }
      count++;
    }
    return count;
  }

  /**
   * Công bố hàng loạt chỉ riêng Bài tập hoặc chỉ riêng Quiz đã chấm xong.
   */
  @Transactional
  public int publishReadyByKind(Integer courseId, Integer instructorId, String kind) {
    if (kind == null || kind.isBlank()) {
      return publishAllReady(courseId, instructorId);
    }
    String normalizedKind = kind.trim().toUpperCase(Locale.ROOT);
    int count = 0;
    for (ResultRow row : instructorOverview(courseId, instructorId)) {
      if (row == null || !READY.equals(row.getState())) {
        continue;
      }
      if (!normalizedKind.equals(row.getKind())) {
        continue;
      }
      if (KIND_ASSIGNMENT.equals(row.getKind())) {
        assignmentService.publishGrade(courseId, row.getParentId(), row.getRefId(), instructorId);
      } else if (KIND_QUIZ.equals(row.getKind())) {
        quizService.publishAttemptResult(courseId, row.getParentId(), row.getRefId(), instructorId);
      }
      count++;
    }
    return count;
  }

  /**
   * Tính toán thống kê tổng quan bảng điểm (Gradebook Summary) cho giảng viên.
   */
  @Transactional(readOnly = true)
  public Map<String, Object> buildInstructorGradebookStats(List<ResultRow> rows) {
    Map<String, Object> stats = new LinkedHashMap<>();
    if (rows == null || rows.isEmpty()) {
      stats.put("totalCount", 0);
      stats.put("publishedCount", 0);
      stats.put("readyCount", 0);
      stats.put("notGradedCount", 0);
      stats.put("quizCount", 0);
      stats.put("assignmentCount", 0);
      stats.put("averagePercent", BigDecimal.ZERO);
      stats.put("passRatePercent", BigDecimal.ZERO);
      stats.put("excellentCount", 0);
      stats.put("goodCount", 0);
      stats.put("averageTierCount", 0);
      stats.put("belowAverageCount", 0);
      return stats;
    }

    int totalCount = rows.size();
    int publishedCount = 0;
    int readyCount = 0;
    int notGradedCount = 0;
    int quizCount = 0;
    int assignmentCount = 0;

    int scoredItems = 0;
    int passedItems = 0;
    int excellentCount = 0;
    int goodCount = 0;
    int averageTierCount = 0;
    int belowAverageCount = 0;
    BigDecimal sumPercent = BigDecimal.ZERO;

    for (ResultRow r : rows) {
      if (r == null) {
        continue;
      }
      if (PUBLISHED.equals(r.getState())) {
        publishedCount++;
      } else if (READY.equals(r.getState())) {
        readyCount++;
      } else {
        notGradedCount++;
      }

      if (KIND_QUIZ.equals(r.getKind())) {
        quizCount++;
      } else {
        assignmentCount++;
      }

      BigDecimal pct = r.getScorePercent();
      if (pct != null) {
        scoredItems++;
        sumPercent = sumPercent.add(pct);
        double val = pct.doubleValue();
        if (val >= 50.0) {
          passedItems++;
        }
        if (val >= 85.0) {
          excellentCount++;
        } else if (val >= 70.0) {
          goodCount++;
        } else if (val >= 50.0) {
          averageTierCount++;
        } else {
          belowAverageCount++;
        }
      }
    }

    BigDecimal averagePercent = scoredItems > 0
        ? sumPercent.divide(BigDecimal.valueOf(scoredItems), 1, RoundingMode.HALF_UP)
        : BigDecimal.ZERO;
    BigDecimal passRatePercent = scoredItems > 0
        ? BigDecimal.valueOf(passedItems * 100.0 / scoredItems).setScale(1, RoundingMode.HALF_UP)
        : BigDecimal.ZERO;

    stats.put("totalCount", totalCount);
    stats.put("publishedCount", publishedCount);
    stats.put("readyCount", readyCount);
    stats.put("notGradedCount", notGradedCount);
    stats.put("quizCount", quizCount);
    stats.put("assignmentCount", assignmentCount);
    stats.put("scoredItems", scoredItems);
    stats.put("averagePercent", averagePercent);
    stats.put("passRatePercent", passRatePercent);
    stats.put("excellentCount", excellentCount);
    stats.put("goodCount", goodCount);
    stats.put("averageTierCount", averageTierCount);
    stats.put("belowAverageCount", belowAverageCount);
    return stats;
  }

  /**
   * Tổng hợp điểm trung bình theo từng học viên trong khóa học để giảng viên theo dõi.
   */
  @Transactional(readOnly = true)
  public List<Map<String, Object>> buildStudentPerformanceLeaderboard(List<ResultRow> rows) {
    if (rows == null || rows.isEmpty()) {
      return List.of();
    }
    Map<String, List<ResultRow>> groupedByStudent = rows.stream()
        .filter(r -> r != null && r.getStudentName() != null && !r.getStudentName().isBlank())
        .collect(Collectors.groupingBy(ResultRow::getStudentName, LinkedHashMap::new, Collectors.toList()));

    List<Map<String, Object>> leaderboard = new ArrayList<>();
    for (Map.Entry<String, List<ResultRow>> entry : groupedByStudent.entrySet()) {
      String studentName = entry.getKey();
      List<ResultRow> studentRows = entry.getValue();

      int totalSubmissions = studentRows.size();
      int publishedSubmissions = 0;
      int scoredCount = 0;
      BigDecimal sumPct = BigDecimal.ZERO;
      LocalDateTime latestSubmission = null;

      for (ResultRow r : studentRows) {
        if (PUBLISHED.equals(r.getState())) {
          publishedSubmissions++;
        }
        BigDecimal pct = r.getScorePercent();
        if (pct != null) {
          scoredCount++;
          sumPct = sumPct.add(pct);
        }
        if (r.getSubmittedAt() != null) {
          if (latestSubmission == null || r.getSubmittedAt().isAfter(latestSubmission)) {
            latestSubmission = r.getSubmittedAt();
          }
        }
      }

      BigDecimal avgPct = scoredCount > 0
          ? sumPct.divide(BigDecimal.valueOf(scoredCount), 1, RoundingMode.HALF_UP)
          : null;

      Map<String, Object> item = new LinkedHashMap<>();
      item.put("studentName", studentName);
      item.put("totalSubmissions", totalSubmissions);
      item.put("publishedSubmissions", publishedSubmissions);
      item.put("averagePercent", avgPct);
      item.put("standing", classifyStanding(avgPct));
      item.put("latestSubmittedAt", latestSubmission);
      leaderboard.add(item);
    }

    leaderboard.sort((a, b) -> {
      BigDecimal avgA = (BigDecimal) a.get("averagePercent");
      BigDecimal avgB = (BigDecimal) b.get("averagePercent");
      if (avgA == null && avgB == null) {
        return 0;
      }
      if (avgA == null) {
        return 1;
      }
      if (avgB == null) {
        return -1;
      }
      return avgB.compareTo(avgA);
    });
    return leaderboard;
  }

  /**
   * Xuất dữ liệu bảng điểm ra định dạng CSV cho giảng viên tải về.
   */
  public String exportInstructorResultsCsv(Course course, List<ResultRow> rows) {
    StringBuilder sb = new StringBuilder();
    sb.append('\uFEFF'); // UTF-8 BOM cho Excel tiếng Việt
    sb.append("Loai,Tieu de,Hoc vien,Lan nop,Diem dat,Diem toi da,Ty le (%),Xep loai,Trang thai,Thoi gian nop,Thoi gian cong bo\n");
    if (rows != null) {
      for (ResultRow r : rows) {
        if (r == null) {
          continue;
        }
        sb.append(escapeCsv(r.getKindLabel())).append(',');
        sb.append(escapeCsv(r.getTitle())).append(',');
        sb.append(escapeCsv(r.getStudentName())).append(',');
        sb.append(r.getAttemptNumber() != null ? r.getAttemptNumber() : 1).append(',');
        sb.append(r.getScore() != null ? r.getScore().toPlainString() : "").append(',');
        sb.append(r.getMaxScore() != null ? r.getMaxScore().toPlainString() : "").append(',');
        sb.append(r.getScorePercent() != null ? r.getScorePercent().toPlainString() : "").append(',');
        sb.append(escapeCsv(r.getGradeBandLabel())).append(',');
        sb.append(escapeCsv(r.getStateLabel())).append(',');
        sb.append(escapeCsv(r.getFormattedSubmittedAt())).append(',');
        sb.append(escapeCsv(r.getFormattedPublishedAt())).append('\n');
      }
    }
    return sb.toString();
  }

  // ===================== UC33 — STUDENT =====================

  @Transactional(readOnly = true)
  public StudentResultsView studentResults(Integer courseId, Integer studentId) {
    var enrollment = enrollments.findByStudent_UserIdAndCourse_CourseId(studentId, courseId)
        .filter(e -> "ACTIVE".equals(e.getStatus()) || "COMPLETED".equals(e.getStatus()))
        .orElseThrow(() -> new CourseActionException(HttpStatus.FORBIDDEN, "Bạn chưa ghi danh khóa học này."));

    List<ResultRow> rows = new ArrayList<>();
    List<Submission> studentSubmissions = submissions
        .findByCourse_CourseIdAndStudent_UserIdOrderBySubmittedAtDesc(courseId, studentId);
    if (studentSubmissions != null) {
      for (Submission s : studentSubmissions) {
        if (s == null) {
          continue;
        }
        Grade grade = grades.findBySubmission_SubmissionId(s.getSubmissionId()).orElse(null);
        rows.add(assignmentRow(s, grade, false));
      }
    }

    List<QuizAttempt> studentAttempts = attempts
        .findByCourse_CourseIdAndStudent_UserIdAndStatusInOrderBySubmittedAtDesc(
            courseId, studentId, List.of("SUBMITTED", "SCORED"));
    if (studentAttempts != null) {
      for (QuizAttempt a : studentAttempts) {
        if (a == null) {
          continue;
        }
        rows.add(quizRow(a, false));
      }
    }

    rows.sort(Comparator.comparing(
        ResultRow::getSubmittedAt,
        Comparator.nullsLast(Comparator.reverseOrder())));

    long published = rows.stream()
        .filter(r -> PUBLISHED.equals(r.getState()))
        .count();

    BigDecimal average = null;
    if (published > 0) {
      BigDecimal sum = BigDecimal.ZERO;
      long validScoreCount = 0;
      for (ResultRow r : rows) {
        if (PUBLISHED.equals(r.getState())
            && r.getMaxScore() != null
            && r.getMaxScore().signum() > 0
            && r.getScore() != null) {
          sum = sum.add(r.getScore()
              .multiply(BigDecimal.valueOf(100))
              .divide(r.getMaxScore(), 4, RoundingMode.HALF_UP));
          validScoreCount++;
        }
      }
      if (validScoreCount > 0) {
        average = sum.divide(BigDecimal.valueOf(published), 1, RoundingMode.HALF_UP);
      } else {
        average = BigDecimal.ZERO.setScale(1, RoundingMode.HALF_UP);
      }
    }

    return new StudentResultsView(
        enrollment.getCourse().getTitle(),
        rows,
        published,
        average);
  }

  // ===================== helpers =====================

  /**
   * includeHidden=true (giảng viên): luôn thấy điểm;
   * false (học viên): chỉ thấy điểm khi đã công bố.
   */
  private ResultRow assignmentRow(Submission s, Grade g, boolean includeHidden) {
    String state = g == null ? NOT_GRADED : (PUBLISHED.equals(g.getResultStatus()) ? PUBLISHED : READY);
    boolean visible = includeHidden || PUBLISHED.equals(state);
    return new ResultRow(
        KIND_ASSIGNMENT,
        s.getAssignment().getAssignmentId(),
        s.getSubmissionId(),
        s.getAssignment().getTitle(),
        s.getStudent().getFullName(),
        s.getAttemptNumber(),
        visible && g != null ? g.getScore() : null,
        s.getAssignment().getMaxScore(),
        visible && g != null ? g.getFeedback() : null,
        state,
        s.getSubmittedAt(),
        g != null ? g.getPublishedAt() : null);
  }

  private ResultRow quizRow(QuizAttempt a, boolean includeHidden) {
    String state;
    if (PUBLISHED.equals(a.getResultStatus())) {
      state = PUBLISHED;
    } else if ("SCORED".equals(a.getStatus())) {
      state = READY;
    } else {
      state = NOT_GRADED;
    }
    boolean visible = includeHidden || PUBLISHED.equals(state);
    return new ResultRow(
        KIND_QUIZ,
        a.getQuiz().getQuizId(),
        a.getAttemptId(),
        a.getQuiz().getTitle(),
        a.getStudent().getFullName(),
        a.getAttemptNumber(),
        visible ? a.getScore() : null,
        a.getMaxScore(),
        null,
        state,
        a.getSubmittedAt(),
        a.getPublishedAt());
  }

  private String classifyStanding(BigDecimal avgPct) {
    if (avgPct == null) {
      return "Chưa có điểm";
    }
    double v = avgPct.doubleValue();
    if (v >= 85.0) {
      return "Xuất sắc";
    }
    if (v >= 70.0) {
      return "Khá giỏi";
    }
    if (v >= 50.0) {
      return "Đạt yêu cầu";
    }
    return "Cần cải thiện";
  }

  private String escapeCsv(String raw) {
    if (raw == null) {
      return "";
    }
    String cleaned = raw.replace("\"", "\"\"");
    if (cleaned.contains(",") || cleaned.contains("\"") || cleaned.contains("\n")) {
      return "\"" + cleaned + "\"";
    }
    return cleaned;
  }
}
