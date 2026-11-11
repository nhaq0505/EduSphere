package com.edusphere.dto.course;

import lombok.AllArgsConstructor;
import lombok.Getter;

import java.util.List;
import java.util.Map;

/**
 * DTO tổng hợp thống kê sao, danh sách nhận xét và quyền đánh giá trên trang chi tiết khóa học.
 */
@Getter
@AllArgsConstructor
public class CourseRatingSummaryView {

    /** Điểm trung bình (làm tròn 1 chữ số thập phân, ví dụ 4.8) */
    private final double averageRating;

    /** Số sao làm tròn nguyên (1..5) để vẽ sao vàng */
    private final int roundedStars;

    /** Tổng số lượt đánh giá */
    private final long totalRatings;

    /** Số lượt đánh giá theo từng mức sao (key: 1..5) */
    private final Map<Integer, Long> starCounts;

    /** Tỷ lệ phần trăm theo từng mức sao (key: 1..5, giá trị 0..100) */
    private final Map<Integer, Integer> starPercents;

    /** Danh sách tất cả đánh giá của học viên */
    private final List<CourseRatingItemView> reviews;

    /** Đánh giá của chính học viên đang đăng nhập (null nếu chưa đánh giá) */
    private final CourseRatingItemView myRating;

    /** Học viên hiện tại có quyền gửi/cập nhật đánh giá hay không */
    private final boolean canRate;

    /** Người xem hiện tại có phải giảng viên sở hữu khóa học (hoặc Admin) để trả lời đánh giá không */
    private final boolean canReply;

    // --- Helper / Alias getters cho JSP EL ---

    public long getRatingCount() {
        return totalRatings;
    }

    public List<CourseRatingItemView> getItems() {
        return reviews;
    }

    public int starPercent(int star) {
        return (starPercents != null && starPercents.containsKey(star)) ? starPercents.get(star) : 0;
    }
}
