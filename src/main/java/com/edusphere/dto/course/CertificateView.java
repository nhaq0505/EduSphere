package com.edusphere.dto.course;

import lombok.Builder;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Collections;
import java.util.List;
import java.util.Locale;

/**
 * View DTO biểu diễn thông tin chi tiết của Chứng chỉ hoàn thành khóa học (Course Certificate)
 * và Tín chỉ tích lũy trên hệ thống EduSphere.
 */
@Getter
@Setter
@Builder
public class CertificateView {

  private static final DateTimeFormatter EN_LONG_DATE_FMT =
      DateTimeFormatter.ofPattern("MMMM d, yyyy", Locale.ENGLISH);
  private static final DateTimeFormatter EN_SHORT_DATE_FMT =
      DateTimeFormatter.ofPattern("MMM d, yyyy", Locale.ENGLISH);
  private static final DateTimeFormatter EN_MONTH_YEAR_FMT =
      DateTimeFormatter.ofPattern("MMMM yyyy", Locale.ENGLISH);
  private static final DateTimeFormatter VI_FULL_DATE_FMT =
      DateTimeFormatter.ofPattern("dd/MM/yyyy");
  private static final DateTimeFormatter ISO_DATE_FMT =
      DateTimeFormatter.ofPattern("yyyy-MM-dd");

  private Integer certificateId;
  private String verificationCode;
  private LocalDateTime issuedAt;
  private Integer creditsEarned;
  private Integer gradePercent;
  private Integer totalHours;
  private String status;

  private Integer studentId;
  private String studentName;
  private String studentEmail;
  private String studentAvatarUrl;

  private Integer courseId;
  private String courseTitle;
  private String courseDescription;
  private String courseThumbnailUrl;
  private String categoryName;
  private String levelLabel;
  private String instructorName;
  private String instructorTitle;

  private int lessonCount;
  private long enrolledCount;
  private double averageRating;
  private int ratingCount;

  private List<String> objectivesList;
  private List<String> skillsList;

  public String getFormattedIssuedDateEn() {
    final LocalDateTime effectiveTime = this.issuedAt != null ? this.issuedAt : LocalDateTime.now();
    return effectiveTime.format(EN_LONG_DATE_FMT);
  }

  public String getFormattedIssuedDateShortEn() {
    final LocalDateTime effectiveTime = this.issuedAt != null ? this.issuedAt : LocalDateTime.now();
    return effectiveTime.format(EN_SHORT_DATE_FMT);
  }

  public String getFormattedIssuedMonthYearEn() {
    final LocalDateTime effectiveTime = this.issuedAt != null ? this.issuedAt : LocalDateTime.now();
    return effectiveTime.format(EN_MONTH_YEAR_FMT);
  }

  public String getFormattedIssuedDateVi() {
    final LocalDateTime effectiveTime = this.issuedAt != null ? this.issuedAt : LocalDateTime.now();
    return effectiveTime.format(VI_FULL_DATE_FMT);
  }

  public String getFormattedIssuedDateIso() {
    final LocalDateTime effectiveTime = this.issuedAt != null ? this.issuedAt : LocalDateTime.now();
    return effectiveTime.format(ISO_DATE_FMT);
  }

  public int getIssuedYear() {
    final LocalDateTime effectiveTime = this.issuedAt != null ? this.issuedAt : LocalDateTime.now();
    return effectiveTime.getYear();
  }

  public int getIssuedMonth() {
    final LocalDateTime effectiveTime = this.issuedAt != null ? this.issuedAt : LocalDateTime.now();
    return effectiveTime.getMonthValue();
  }

  /**
   * Trả về xếp loại học lực dựa trên phần trăm điểm đạt được của chứng chỉ.
   */
  public String getHonorsDistinctionLabel() {
    final int grade = this.gradePercent != null ? this.gradePercent : 100;
    if (grade >= 95) {
      return "Xuất sắc (With High Distinction)";
    }
    if (grade >= 85) {
      return "Giỏi (With Distinction)";
    }
    if (grade >= 75) {
      return "Khá (Merit)";
    }
    return "Hoàn thành (Pass)";
  }

  /**
   * Trả về ký hiệu điểm chữ (A+, A, B+, B, C) tương ứng với phần trăm điểm.
   */
  public String getLetterGradeCode() {
    final int grade = this.gradePercent != null ? this.gradePercent : 100;
    if (grade >= 95) {
      return "A+";
    }
    if (grade >= 90) {
      return "A";
    }
    if (grade >= 85) {
      return "B+";
    }
    if (grade >= 80) {
      return "B";
    }
    return "C+";
  }

  public String getLetterGradeEquivalent() {
    return getLetterGradeCode();
  }

  public boolean isWithDistinction() {
    final int grade = this.gradePercent != null ? this.gradePercent : 100;
    return isValidStatus() && grade >= 85;
  }

  /**
   * Trả về chữ cái viết tắt tên học viên để hiển thị avatar mặc định.
   */
  public String getStudentInitials() {
    if (this.studentName == null || this.studentName.isBlank()) {
      return "HV";
    }
    final String[] tokens = this.studentName.trim().split("\\s+");
    if (tokens.length == 1) {
      return tokens[0].substring(0, Math.min(2, tokens[0].length())).toUpperCase(Locale.ROOT);
    }
    final String firstChar = tokens[0].substring(0, 1);
    final String lastChar = tokens[tokens.length - 1].substring(0, 1);
    return (firstChar + lastChar).toUpperCase(Locale.ROOT);
  }

  public List<String> getSafeObjectivesList() {
    return this.objectivesList != null ? this.objectivesList : Collections.emptyList();
  }

  public List<String> getSafeSkillsList() {
    return this.skillsList != null ? this.skillsList : Collections.emptyList();
  }

  public boolean isValidStatus() {
    return this.status == null || "VALID".equalsIgnoreCase(this.status);
  }
}
