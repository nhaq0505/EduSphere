package com.edusphere.dto.result;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Locale;

/**
 * Một dòng kết quả học tập (bài tập hoặc bài kiểm tra quiz) phục vụ UC32 (Giảng viên công bố kết quả)
 * và UC33 (Học viên tra cứu kết quả học tập).
 * - kind: ASSIGNMENT | QUIZ
 * - state: NOT_GRADED (chờ chấm) | READY (đã chấm, chưa công bố) | PUBLISHED (đã công bố)
 */
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ResultRow {

  private static final DateTimeFormatter DISPLAY_DATE_TIME_FMT =
      DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
  private static final DateTimeFormatter DISPLAY_DATE_ONLY_FMT =
      DateTimeFormatter.ofPattern("dd/MM/yyyy");
  private static final BigDecimal HUNDRED = BigDecimal.valueOf(100);
  private static final BigDecimal PASSING_THRESHOLD_PERCENT = BigDecimal.valueOf(50);

  private String kind;
  private Integer parentId;      // assignmentId hoặc quizId
  private Integer refId;         // submissionId hoặc attemptId
  private String title;
  private String studentName;
  private Integer attemptNumber;
  private BigDecimal score;      // với học viên: chỉ có giá trị khi PUBLISHED
  private BigDecimal maxScore;
  private String feedback;       // với học viên: chỉ có giá trị khi PUBLISHED
  private String state;
  private LocalDateTime submittedAt;
  private LocalDateTime publishedAt;

  /**
   * Kiểm tra xem mục kết quả này có phải là bài Quiz hay không.
   */
  public boolean isQuizKind() {
    return "QUIZ".equalsIgnoreCase(this.kind);
  }

  /**
   * Kiểm tra xem mục kết quả này có phải là Bài tập (Assignment) hay không.
   */
  public boolean isAssignmentKind() {
    return "ASSIGNMENT".equalsIgnoreCase(this.kind);
  }

  /**
   * Kiểm tra kết quả đã được công bố chính thức cho học viên hay chưa.
   */
  public boolean isPublishedState() {
    return "PUBLISHED".equalsIgnoreCase(this.state);
  }

  /**
   * Kiểm tra kết quả đã chấm điểm xong và sẵn sàng để giảng viên công bố hay chưa.
   */
  public boolean isReadyState() {
    return "READY".equalsIgnoreCase(this.state);
  }

  /**
   * Kiểm tra bài làm vẫn đang chờ chấm điểm.
   */
  public boolean isNotGradedState() {
    return "NOT_GRADED".equalsIgnoreCase(this.state) || this.state == null;
  }

  /**
   * Tính tỷ lệ phần trăm điểm đạt được (0.0 -> 100.0) nếu đã có điểm hợp lệ.
   */
  public BigDecimal getScorePercentDecimal() {
    if (this.score == null || this.maxScore == null || this.maxScore.compareTo(BigDecimal.ZERO) <= 0) {
      return null;
    }
    return this.score.multiply(HUNDRED).divide(this.maxScore, 1, RoundingMode.HALF_UP);
  }

  public BigDecimal getScorePercent() {
    return getScorePercentDecimal();
  }

  public BigDecimal getScoreScale10() {
    final BigDecimal pct = getScorePercentDecimal();
    if (pct == null) {
      return null;
    }
    return pct.divide(BigDecimal.TEN, 2, RoundingMode.HALF_UP);
  }

  public String getKindLabel() {
    return getKindDisplayLabel();
  }

  public String getGradeBandLabel() {
    return getPerformanceLabelVi();
  }

  public String getStateLabel() {
    return getStateDisplayLabel();
  }

  /**
   * Trả về tỷ lệ phần trăm điểm làm tròn thành số nguyên (0 -> 100) để vẽ thanh tiến độ.
   */
  public int getScorePercentInt() {
    final BigDecimal pct = getScorePercentDecimal();
    if (pct == null) {
      return 0;
    }
    final int val = pct.setScale(0, RoundingMode.HALF_UP).intValue();
    return Math.min(100, Math.max(0, val));
  }

  /**
   * Trả về điểm quy đổi sang thang điểm 10 chuẩn (ví dụ: 8.5 / 10).
   */
  public String getScoreOnScaleTenFormatted() {
    final BigDecimal pct = getScorePercentDecimal();
    if (pct == null) {
      return "—";
    }
    final BigDecimal scaleTen = pct.divide(BigDecimal.TEN, 1, RoundingMode.HALF_UP);
    return String.format(Locale.US, "%.1f", scaleTen.doubleValue());
  }

  /**
   * Trả về điểm chữ học thuật (A+, A, B+, B, C, D, F) dựa trên phần trăm điểm đạt được.
   */
  public String getLetterGrade() {
    final BigDecimal pct = getScorePercentDecimal();
    if (pct == null) {
      return "—";
    }
    final double v = pct.doubleValue();
    if (v >= 90.0) {
      return "A+";
    }
    if (v >= 85.0) {
      return "A";
    }
    if (v >= 80.0) {
      return "B+";
    }
    if (v >= 70.0) {
      return "B";
    }
    if (v >= 60.0) {
      return "C";
    }
    if (v >= 50.0) {
      return "D";
    }
    return "F";
  }

  /**
   * Trả về xếp loại đánh giá tiếng Việt cho mục điểm số này.
   */
  public String getPerformanceLabelVi() {
    final BigDecimal pct = getScorePercentDecimal();
    if (pct == null) {
      return "Chưa có điểm";
    }
    final double v = pct.doubleValue();
    if (v >= 90.0) {
      return "Xuất sắc";
    }
    if (v >= 80.0) {
      return "Giỏi";
    }
    if (v >= 65.0) {
      return "Khá";
    }
    if (v >= 50.0) {
      return "Đạt yêu cầu";
    }
    return "Cần cố gắng";
  }

  /**
   * Kiểm tra bài làm đạt từ 50% điểm tối đa trở lên hay chưa.
   */
  public boolean isPassed() {
    final BigDecimal pct = getScorePercentDecimal();
    return pct != null && pct.compareTo(PASSING_THRESHOLD_PERCENT) >= 0;
  }

  /**
   * Định dạng thời gian nộp bài theo chuẩn dd/MM/yyyy HH:mm.
   */
  public String getFormattedSubmittedAt() {
    if (this.submittedAt == null) {
      return "—";
    }
    return this.submittedAt.format(DISPLAY_DATE_TIME_FMT);
  }

  /**
   * Định dạng thời gian công bố kết quả theo chuẩn dd/MM/yyyy HH:mm.
   */
  public String getFormattedPublishedAt() {
    if (this.publishedAt == null) {
      return "Chưa công bố";
    }
    return this.publishedAt.format(DISPLAY_DATE_TIME_FMT);
  }

  /**
   * Định dạng ngày nộp bài ngắn gọn dd/MM/yyyy.
   */
  public String getFormattedSubmittedDateOnly() {
    if (this.submittedAt == null) {
      return "—";
    }
    return this.submittedAt.format(DISPLAY_DATE_ONLY_FMT);
  }

  /**
   * Trả về nhãn tiếng Việt cho loại bài đánh giá.
   */
  public String getKindDisplayLabel() {
    return isQuizKind() ? "Bài kiểm tra Quiz" : "Bài tập tự luận";
  }

  /**
   * Trả về nhãn trạng thái tiếng Việt phục vụ hiển thị.
   */
  public String getStateDisplayLabel() {
    if (isPublishedState()) {
      return "Đã công bố";
    }
    if (isReadyState()) {
      return "Sẵn sàng công bố";
    }
    return "Đang chờ chấm";
  }
}
