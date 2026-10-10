package com.edusphere.dto.course;

public record LessonItemView(
        Integer lessonId,
        String title,
        Integer orderIndex,
        boolean completed,
        boolean current
) {
    public Integer getLessonId() { return lessonId(); }
    public String getTitle() { return title(); }
    public Integer getOrderIndex() { return orderIndex(); }
    public boolean isCompleted() { return completed(); }
    public boolean isCurrent() { return current(); }
}
