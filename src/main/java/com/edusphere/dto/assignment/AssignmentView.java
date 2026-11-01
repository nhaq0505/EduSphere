package com.edusphere.dto.assignment;

import java.math.BigDecimal;
import java.time.LocalDateTime;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class AssignmentView {

    private Integer assignmentId;
    private String title;
    private String description;
    private LocalDateTime dueDate;
    private BigDecimal maxScore;
    private String status;
    private long submissionCount;
    private String lessonTitle;
    private boolean allowResubmit;
    private Integer maxAttempts;
    private LocalDateTime unlockAt;
    private LocalDateTime lockAt;
    /** lessonId mà assignment gắn vào (nullable) */
    private Integer lessonId;
    /** Học viên đã nộp bài chưa (dùng trong study page) */
    private boolean hasSubmitted;
    /** Số lần đã nộp (dùng trong study page) */
    private int attemptCount;
}
