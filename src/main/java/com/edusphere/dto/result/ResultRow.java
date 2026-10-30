package com.edusphere.dto.result;

import java.math.BigDecimal;
import java.time.LocalDateTime;

import lombok.AllArgsConstructor;
import lombok.Getter;

/**
 * Một dòng kết quả học tập (bài tập hoặc quiz).
 * kind: ASSIGNMENT | QUIZ
 * state: NOT_GRADED (chờ chấm) | READY (đã chấm, chưa công bố) | PUBLISHED (đã công bố)
 */
@Getter
@AllArgsConstructor
public class ResultRow {
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
}
