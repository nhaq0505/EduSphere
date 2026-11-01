package com.edusphere.dto.course;

import com.edusphere.dto.assignment.AssignmentView;
import com.edusphere.dto.quiz.QuizView;
import java.util.Collections;
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
        int progressPercent,
        String currentLessonType,
        String currentVideoUrl,
        Integer currentVideoDuration,
        boolean currentAllowSeek,
        boolean previewMode,
        List<AssignmentView> currentLessonAssignments,
        boolean currentLessonCompleted,
        /** Quiz gắn với lesson hiện tại */
        List<QuizView> currentLessonQuizzes
) {
    /** Constructor không có quiz (tương thích ngược) */
    public StudyCourseView(
            Integer courseId, String courseTitle, String instructorName,
            List<LessonItemView> lessons, LessonItemView currentLesson,
            String lessonContent, List<MaterialView> materials,
            Integer prevLessonId, Integer nextLessonId,
            int completedCount, int totalCount, int progressPercent,
            String currentLessonType, String currentVideoUrl,
            Integer currentVideoDuration, boolean currentAllowSeek, boolean previewMode,
            List<AssignmentView> currentLessonAssignments,
            boolean currentLessonCompleted
    ) {
        this(courseId, courseTitle, instructorName, lessons, currentLesson, lessonContent, materials,
                prevLessonId, nextLessonId, completedCount, totalCount, progressPercent,
                currentLessonType, currentVideoUrl, currentVideoDuration, currentAllowSeek, previewMode,
                currentLessonAssignments, currentLessonCompleted, Collections.emptyList());
    }

    /** Constructor 17-arg (tương thích ngược ngắn không có assignments) */
    public StudyCourseView(
            Integer courseId, String courseTitle, String instructorName,
            List<LessonItemView> lessons, LessonItemView currentLesson,
            String lessonContent, List<MaterialView> materials,
            Integer prevLessonId, Integer nextLessonId,
            int completedCount, int totalCount, int progressPercent,
            String currentLessonType, String currentVideoUrl,
            Integer currentVideoDuration, boolean currentAllowSeek, boolean previewMode
    ) {
        this(courseId, courseTitle, instructorName, lessons, currentLesson, lessonContent, materials,
                prevLessonId, nextLessonId, completedCount, totalCount, progressPercent,
                currentLessonType, currentVideoUrl, currentVideoDuration, currentAllowSeek, previewMode,
                Collections.emptyList(), false, Collections.emptyList());
    }

    /** Constructor 12-arg */
    public StudyCourseView(
            Integer courseId, String courseTitle, String instructorName,
            List<LessonItemView> lessons, LessonItemView currentLesson,
            String lessonContent, List<MaterialView> materials,
            Integer prevLessonId, Integer nextLessonId,
            int completedCount, int totalCount, int progressPercent
    ) {
        this(courseId, courseTitle, instructorName, lessons, currentLesson, lessonContent, materials,
                prevLessonId, nextLessonId, completedCount, totalCount, progressPercent,
                "ARTICLE", null, null, true, false);
    }

    // ── JavaBean getters for JSP EL ──

    public Integer getCourseId()                     { return this.courseId(); }
    public String  getCourseTitle()                  { return this.courseTitle(); }
    public String  getInstructorName()               { return this.instructorName(); }
    public List<LessonItemView> getLessons()         { return this.lessons(); }
    public LessonItemView getCurrentLesson()         { return this.currentLesson(); }
    public String  getLessonContent()                { return this.lessonContent(); }
    public List<MaterialView> getMaterials()         { return this.materials(); }
    public Integer getPrevLessonId()                 { return this.prevLessonId(); }
    public Integer getNextLessonId()                 { return this.nextLessonId(); }
    public int     getCompletedCount()               { return this.completedCount(); }
    public int     getTotalCount()                   { return this.totalCount(); }
    public int     getProgressPercent()              { return this.progressPercent(); }
    public String  getCurrentLessonType()            { return this.currentLessonType(); }
    public String  getCurrentVideoUrl()              { return this.currentVideoUrl(); }
    public Integer getCurrentVideoDuration()         { return this.currentVideoDuration(); }
    public boolean isCurrentAllowSeek()              { return this.currentAllowSeek(); }
    public boolean isPreviewMode()                   { return this.previewMode(); }
    public List<AssignmentView> getCurrentLessonAssignments() { return this.currentLessonAssignments(); }
    public boolean isCurrentLessonCompleted()        { return this.currentLessonCompleted(); }
    public List<QuizView> getCurrentLessonQuizzes()  { return this.currentLessonQuizzes(); }

    public String getEmbedVideoUrl() {
        if (currentVideoUrl == null || currentVideoUrl.isBlank()) return null;
        String url = currentVideoUrl.trim();
        if (url.contains("youtube.com/watch?v=")) {
            String v = url.substring(url.indexOf("watch?v=") + 8);
            int amp = v.indexOf('&');
            if (amp != -1) v = v.substring(0, amp);
            return "https://www.youtube.com/embed/" + v;
        }
        if (url.contains("youtu.be/")) {
            String v = url.substring(url.indexOf("youtu.be/") + 9);
            int q = v.indexOf('?');
            if (q != -1) v = v.substring(0, q);
            return "https://www.youtube.com/embed/" + v;
        }
        return url;
    }

    public boolean isDirectVideo() {
        if (currentVideoUrl == null) return false;
        String url = currentVideoUrl.toLowerCase();
        return !url.contains("youtube.com") && !url.contains("youtu.be") && !url.contains("vimeo.com");
    }
}
