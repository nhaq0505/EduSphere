package com.edusphere.dto.result;

import java.math.BigDecimal;
import java.util.List;

import lombok.AllArgsConstructor;
import lombok.Getter;

/** Tổng hợp kết quả học tập của một học viên trong một khóa học. */
@Getter
@AllArgsConstructor
public class StudentResultsView {
    private String courseTitle;
    private List<ResultRow> rows;
    private long publishedCount;
    /** Điểm trung bình (%) trên các kết quả đã công bố; null nếu chưa có. */
    private BigDecimal averagePercent;
}
