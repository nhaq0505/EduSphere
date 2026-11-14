package com.edusphere.dto.result;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.Collections;
import java.util.List;
import java.util.Locale;

/**
 * Tổng hợp kết quả học tập của một học viên trong một khóa học (UC33 View Learning Results).
 * Cung cấp danh sách từng bài tập / bài quiz đã làm cùng các chỉ số thống kê điểm trung bình,
 * xếp loại học lực, phân bổ điểm số và tỷ lệ hoàn thành.
 */
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class StudentResultsView {

  private String courseTitle;
  private List<ResultRow> rows;
  private long publishedCount;
  /** Điểm trung bình (%) trên các kết quả đã công bố; null nếu chưa có. */
  private BigDecimal averagePercent;

  /**
   * Trả về danh sách dòng kết quả an toàn (không null).
   */
  public List<ResultRow> getSafeRows() {
    return this.rows != null ? this.rows : Collections.emptyList();
  }

  /**
   * Tổng số bài tập và bài quiz đã nộp trong khóa học.
   */
  public int getTotalSubmissionsCount() {
    return getSafeRows().size();
  }

  public int getTotalCount() {
    return getTotalSubmissionsCount();
  }

  /**
   * Số lượng bài nộp đang chờ chấm hoặc chờ giảng viên công bố điểm.
   */
  public long getPendingResultsCount() {
    return Math.max(0L, getTotalSubmissionsCount() - this.publishedCount);
  }

  public long getPendingCount() {
    return getPendingResultsCount();
  }

  public long getQuizCount() {
    return getQuizItemsCount();
  }

  public long getAssignmentCount() {
    return getAssignmentItemsCount();
  }

  public BigDecimal getAverageScale10() {
    if (this.averagePercent == null) {
      return null;
    }
    return this.averagePercent.divide(BigDecimal.TEN, 2, RoundingMode.HALF_UP);
  }

  public BigDecimal getHighestPercent() {
    return getHighestPublishedPercent();
  }

  public BigDecimal getLowestPercent() {
    return getLowestPublishedPercent();
  }

  public String getAcademicStandingLabel() {
    if (this.averagePercent == null) {
      return "Chưa có điểm công bố";
    }
    final double avg = this.averagePercent.doubleValue();
    if (avg >= 85.0) {
      return "Xuất sắc";
    }
    if (avg >= 70.0) {
      return "Khá giỏi";
    }
    if (avg >= 50.0) {
      return "Đạt yêu cầu";
    }
    return "Cần cải thiện";
  }

  /**
   * Đếm số lượng mục kết quả thuộc loại Quiz.
   */
  public long getQuizItemsCount() {
    return getSafeRows().stream()
        .filter(r -> r != null && "QUIZ".equalsIgnoreCase(r.getKind()))
        .count();
  }

  /**
   * Đếm số lượng mục kết quả thuộc loại Bài tập (Assignment).
   */
  public long getAssignmentItemsCount() {
    return getSafeRows().stream()
        .filter(r -> r != null && "ASSIGNMENT".equalsIgnoreCase(r.getKind()))
        .count();
  }

  /**
   * Đếm số lượng bài đã công bố đạt từ 50% điểm tối đa trở lên.
   */
  public long getPassedPublishedCount() {
    return getSafeRows().stream()
        .filter(r -> r != null && r.isPublishedState() && r.isPassed())
        .count();
  }

  /**
   * Đếm số lượng bài đã công bố đạt loại Xuất sắc / Giỏi (>= 80%).
   */
  public long getDistinctionPublishedCount() {
    return getSafeRows().stream()
        .filter(r -> r != null && r.isPublishedState() && r.getScorePercentInt() >= 80)
        .count();
  }

  /**
   * Tính điểm phần trăm cao nhất trong các kết quả đã được công bố.
   */
  public BigDecimal getHighestPublishedPercent() {
    BigDecimal highest = null;
    for (final ResultRow row : getSafeRows()) {
      if (row != null && row.isPublishedState()) {
        final BigDecimal pct = row.getScorePercentDecimal();
        if (pct != null && (highest == null || pct.compareTo(highest) > 0)) {
          highest = pct;
        }
      }
    }
    return highest;
  }

  /**
   * Tính điểm phần trăm thấp nhất trong các kết quả đã được công bố.
   */
  public BigDecimal getLowestPublishedPercent() {
    BigDecimal lowest = null;
    for (final ResultRow row : getSafeRows()) {
      if (row != null && row.isPublishedState()) {
        final BigDecimal pct = row.getScorePercentDecimal();
        if (pct != null && (lowest == null || pct.compareTo(lowest) < 0)) {
          lowest = pct;
        }
      }
    }
    return lowest;
  }

  /**
   * Tính điểm trung bình (%) riêng cho các bài Quiz đã công bố.
   */
  public BigDecimal getQuizAveragePercent() {
    BigDecimal sum = BigDecimal.ZERO;
    long count = 0L;
    for (final ResultRow row : getSafeRows()) {
      if (row != null && row.isPublishedState() && row.isQuizKind()) {
        final BigDecimal pct = row.getScorePercentDecimal();
        if (pct != null) {
          sum = sum.add(pct);
          count++;
        }
      }
    }
    if (count == 0L) {
      return null;
    }
    return sum.divide(BigDecimal.valueOf(count), 1, RoundingMode.HALF_UP);
  }

  /**
   * Tính điểm trung bình (%) riêng cho các Bài tập (Assignment) đã công bố.
   */
  public BigDecimal getAssignmentAveragePercent() {
    BigDecimal sum = BigDecimal.ZERO;
    long count = 0L;
    for (final ResultRow row : getSafeRows()) {
      if (row != null && row.isPublishedState() && row.isAssignmentKind()) {
        final BigDecimal pct = row.getScorePercentDecimal();
        if (pct != null) {
          sum = sum.add(pct);
          count++;
        }
      }
    }
    if (count == 0L) {
      return null;
    }
    return sum.divide(BigDecimal.valueOf(count), 1, RoundingMode.HALF_UP);
  }

  /**
   * Quy đổi điểm trung bình chung sang thang điểm 10.
   */
  public String getAverageOnScaleTenFormatted() {
    if (this.averagePercent == null) {
      return "—";
    }
    final BigDecimal scaleTen = this.averagePercent.divide(BigDecimal.TEN, 1, RoundingMode.HALF_UP);
    return String.format(Locale.US, "%.1f", scaleTen.doubleValue());
  }

  /**
   * Xếp loại học lực tổng quát của học viên trong khóa học dựa trên điểm trung bình đã công bố.
   */
  public String getOverallStandingLabel() {
    if (this.averagePercent == null) {
      return "Chưa có điểm công bố";
    }
    final double avg = this.averagePercent.doubleValue();
    if (avg >= 90.0) {
      return "Xuất sắc (A+)";
    }
    if (avg >= 80.0) {
      return "Giỏi (A)";
    }
    if (avg >= 65.0) {
      return "Khá (B)";
    }
    if (avg >= 50.0) {
      return "Đạt yêu cầu (C)";
    }
    return "Cần cải thiện (D/F)";
  }

  /**
   * Trả về mã điểm chữ tổng kết khóa học (A+, A, B+, B, C, D, F).
   */
  public String getOverallLetterGrade() {
    if (this.averagePercent == null) {
      return "—";
    }
    final double avg = this.averagePercent.doubleValue();
    if (avg >= 90.0) {
      return "A+";
    }
    if (avg >= 85.0) {
      return "A";
    }
    if (avg >= 80.0) {
      return "B+";
    }
    if (avg >= 70.0) {
      return "B";
    }
    if (avg >= 60.0) {
      return "C";
    }
    if (avg >= 50.0) {
      return "D";
    }
    return "F";
  }
}
