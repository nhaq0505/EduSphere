package com.edusphere.dto.course;

/**
 * DTO hiển thị một bài học trong danh sách sidebar của trang học.
 *
 * Lưu ý: Java record không sinh getter theo chuẩn JavaBean (getXxx/isXxx),
 * nhưng JSP EL (BeanELResolver) yêu cầu chuẩn đó.
 * Vì vậy các getter được khai báo tường minh và gọi qua `this` để tránh đệ quy.
 */
public record LessonItemView(
        Integer lessonId,
        String title,
        Integer orderIndex,
        boolean completed,
        boolean current,
        String lessonType,
        Integer videoDuration,
        boolean preview,
        Integer sectionId,
        String sectionTitle
) {
    /** Compact constructor cho tương thích ngược (5 tham số). */
    public LessonItemView(Integer lessonId, String title, Integer orderIndex, boolean completed, boolean current) {
        this(lessonId, title, orderIndex, completed, current, "ARTICLE", null, false, null, null);
    }

    // --- JavaBean-style getters cho JSP EL (BeanELResolver) ---

    public Integer getLessonId()      { return this.lessonId(); }
    public String  getTitle()         { return this.title(); }
    public Integer getOrderIndex()    { return this.orderIndex(); }
    public boolean isCompleted()      { return this.completed(); }
    public boolean isCurrent()        { return this.current(); }
    public String  getLessonType()    { return this.lessonType(); }
    public Integer getVideoDuration() { return this.videoDuration(); }
    /** isPreview() — trả về component "preview", không đệ quy. */
    public boolean isPreview()        { return this.preview(); }
    public Integer getSectionId()     { return this.sectionId(); }
    public String  getSectionTitle()  { return this.sectionTitle(); }
}
