package com.edusphere.dto.course;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
public class CourseChangeLogView {

    private Long logId;
    private Integer courseId;
    private String courseTitle;
    private Integer actorId;
    private String actorName;
    private String actorEmail;
    private String actorRole;

    private String entityType;
    private String entityTypeLabel;
    private Integer entityId;
    private String entityTitle;
    private Integer parentLessonId;

    private String actionType;
    private String actionTypeLabel;
    private String summary;
    private String changedFields;

    private String beforeData;
    private String afterData;
    private LocalDateTime createdAt;
    private String formattedCreatedAt;

    private Map<String, Object> beforeMap = new LinkedHashMap<>();
    private Map<String, Object> afterMap = new LinkedHashMap<>();
    private List<FieldDiffItem> fieldDiffs = new ArrayList<>();

    // Trạng thái tồn tại của tài nguyên hiện tại (bài học, video, tài liệu, quiz)
    private boolean resourceExists = true;
    private String resourceStatusMessage;

    // Thông tin phục vụ Admin xem trực tiếp Video / Tài liệu / Bài học / Quiz
    private String videoUrl;
    private String bunnyVideoId;
    private String oldVideoUrl;
    private String oldBunnyVideoId;
    private boolean videoResourceExists = true;
    private boolean oldVideoResourceExists = true;

    private String fileUrl;
    private String fileName;
    private String fileType;
    private Long fileSize;
    private boolean fileResourceExists = true;

    private String oldFileUrl;
    private String oldFileName;
    private boolean oldFileResourceExists = true;

    private String lessonContent;
    private String oldLessonContent;

    private List<Map<String, Object>> quizQuestions = new ArrayList<>();

    // Chi tiết bài học mới (phục vụ hiển thị đầy đủ Bài 2, Bài 3... khi giảng viên thêm bài học mới ở lần cập nhật 2+)
    private AdminLessonReviewView newLessonDetail;
    private String lessonTypeLabel;

    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    public static class FieldDiffItem {
        private String fieldKey;
        private String fieldLabel;
        private String beforeValue;
        private String afterValue;
        private boolean changed;
    }
}
