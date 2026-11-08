package com.edusphere.dto.course;

import java.util.Collections;
import java.util.List;

/**
 * DTO đại diện cho một Chương (Section) trong danh sách bài học của khóa học.
 * Được chuẩn bị sẵn từ backend để JSP chỉ việc render lặp đơn giản mà không cần
 * viết logic gom nhóm, ép kiểu hay xử lý nghiệp vụ phức tạp trong JSP.
 */
public record StudySectionView(
        Integer sectionId,
        String title,
        boolean active,
        List<LessonItemView> lessons
) {
    public StudySectionView {
        if (lessons == null) {
            lessons = Collections.emptyList();
        }
    }

    // JavaBean getters cho JSP EL (BeanELResolver)
    public Integer getSectionId()            { return this.sectionId(); }
    public String  getTitle()                { return this.title(); }
    public boolean isActive()                { return this.active(); }
    public List<LessonItemView> getLessons() { return this.lessons(); }
}

