package com.edusphere.dto.course;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class LessonForm {

    @NotBlank(message = "Vui lòng nhập tên bài học.")
    @Size(max = 255, message = "Tên bài học tối đa 255 ký tự.")
    private String title;

    private String content;

    @Min(value = 1, message = "Vị trí bài học phải từ 1 trở lên.")
    private Integer orderIndex;

    // Bước 2: Thuộc chương mục nào
    private Integer sectionId;

    // Bước 3: Loại nội dung & thông tin video
    private String lessonType = "ARTICLE"; // ARTICLE, VIDEO, QUIZ, ASSIGNMENT
    private String videoUrl;
    private Integer videoDuration; // Số phút
    private Boolean allowSeek = true;

    /**
     * Bắt buộc xem video đủ % mới được làm Quiz gắn với bài học này.
     * Chỉ có nghĩa khi lessonType = VIDEO.
     */
    private Boolean quizRequiresVideo = false;

    /**
     * Ngưỡng % xem video tối thiểu (0–100).
     * 0 = không yêu cầu; 100 = xem hết.
     */
    private Integer minWatchPercent = 0;

    // Bước 4: Cấu hình nâng cao
    private Boolean isPreview = false; // Học thử / xem trước
    private Integer unlockDaysAfterEnroll; // Mở sau X ngày (Drip content)
    private Integer prerequisiteLessonId; // Cần học bài này trước
    private String instructorNotes; // Ghi chú riêng cho GV
}
