package com.edusphere.dto.course;

import java.util.List;

public record StudyCourseView(
        Integer courseId,
        String courseTitle,
        String instructorName,
        List<LessonItemView> lessons,
        LessonItemView currentLesson,
        String lessonContent,
        List<MaterialView> materials,
        Integer prevLessonId,
        Integer nextLessonId,
        int completedCount,
        int totalCount,
        int progressPercent
) {
    public Integer getCourseId() { return courseId(); }
    public String getCourseTitle() { return courseTitle(); }
    public String getInstructorName() { return instructorName(); }
    public List<LessonItemView> getLessons() { return lessons(); }
    public LessonItemView getCurrentLesson() { return currentLesson(); }
    public String getLessonContent() { return lessonContent(); }
    public List<MaterialView> getMaterials() { return materials(); }
    public Integer getPrevLessonId() { return prevLessonId(); }
    public Integer getNextLessonId() { return nextLessonId(); }
    public int getCompletedCount() { return completedCount(); }
    public int getTotalCount() { return totalCount(); }
    public int getProgressPercent() { return progressPercent(); }
}
