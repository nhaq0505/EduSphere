package com.edusphere.dto.course;

import lombok.AllArgsConstructor;
import lombok.Getter;

/**
 * DTO hiển thị một lượt đánh giá của học viên trên giao diện khóa học.
 */
@Getter
@AllArgsConstructor
public class CourseRatingItemView {

    private final Integer ratingId;
    private final Integer studentId;
    private final String studentName;
    private final String studentInitial;
    private final int rating;
    private final String comment;
    private final String createdAtFormatted;
    private final boolean edited;
    private final String instructorReply;
    private final String repliedAtFormatted;
}
