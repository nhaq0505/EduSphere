package com.edusphere.dto.course;

import com.edusphere.dto.assignment.AssignmentView;
import com.edusphere.dto.quiz.QuizView;
import java.util.ArrayList;
import java.util.Collections;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * DTO truyền dữ liệu trang học bài xuống study.jsp.
 * Dùng class thường thay vì record để tránh vấn đề constructor canonical.
 */
public final class StudyCourseView {

    private final Integer courseId;
    private final String  courseTitle;
    private final String  instructorName;
    private final List<LessonItemView> lessons;
    private final LessonItemView currentLesson;
    private final String  lessonContent;
    private final List<MaterialView> materials;
    private final Integer prevLessonId;
    private final Integer nextLessonId;
    private final int     completedCount;
    private final int     totalCount;
    private final int     progressPercent;
    private final String  currentLessonType;
    private final String  currentVideoUrl;
    private final Integer currentVideoDuration;
    private final boolean currentAllowSeek;
    private final boolean previewMode;
    private final List<AssignmentView> currentLessonAssignments;
    private final boolean currentLessonCompleted;
    private final List<QuizView> currentLessonQuizzes;
    private final String  currentVideoStatus;
    private final int     currentWatchPercent;
    private final int     currentLastPosition;
    private final boolean currentQuizRequiresVideo;
    private final int     currentMinWatchPercent;
    private final boolean currentQuizUnlocked;
    private final String  currentWatchedSegments;
    private final List<StudySectionView> sections;

    // ── Constructor đầy đủ nhất có sections ──────────────────────

    public StudyCourseView(
            Integer courseId, String courseTitle, String instructorName,
            List<LessonItemView> lessons, LessonItemView currentLesson,
            String lessonContent, List<MaterialView> materials,
            Integer prevLessonId, Integer nextLessonId,
            int completedCount, int totalCount, int progressPercent,
            String currentLessonType, String currentVideoUrl,
            Integer currentVideoDuration, boolean currentAllowSeek, boolean previewMode,
            List<AssignmentView> currentLessonAssignments, boolean currentLessonCompleted,
            List<QuizView> currentLessonQuizzes, String currentVideoStatus,
            int currentWatchPercent, int currentLastPosition,
            boolean currentQuizRequiresVideo, int currentMinWatchPercent,
            boolean currentQuizUnlocked, String currentWatchedSegments,
            List<StudySectionView> sections) {
        this.courseId                  = courseId;
        this.courseTitle               = courseTitle;
        this.instructorName            = instructorName;
        this.lessons                   = lessons != null ? lessons : Collections.emptyList();
        this.currentLesson             = currentLesson;
        this.lessonContent             = lessonContent;
        this.materials                 = materials != null ? materials : Collections.emptyList();
        this.prevLessonId              = prevLessonId;
        this.nextLessonId              = nextLessonId;
        this.completedCount            = completedCount;
        this.totalCount                = totalCount;
        this.progressPercent           = progressPercent;
        this.currentLessonType         = currentLessonType;
        this.currentVideoUrl           = currentVideoUrl;
        this.currentVideoDuration      = currentVideoDuration;
        this.currentAllowSeek          = currentAllowSeek;
        this.previewMode               = previewMode;
        this.currentLessonAssignments  = currentLessonAssignments != null ? currentLessonAssignments : Collections.emptyList();
        this.currentLessonCompleted    = currentLessonCompleted;
        this.currentLessonQuizzes      = currentLessonQuizzes != null ? currentLessonQuizzes : Collections.emptyList();
        this.currentVideoStatus        = currentVideoStatus;
        this.currentWatchPercent       = currentWatchPercent;
        this.currentLastPosition       = currentLastPosition;
        this.currentQuizRequiresVideo  = currentQuizRequiresVideo;
        this.currentMinWatchPercent    = currentMinWatchPercent;
        this.currentQuizUnlocked       = currentQuizUnlocked;
        this.currentWatchedSegments    = currentWatchedSegments != null ? currentWatchedSegments : "[]";
        this.sections                  = sections != null ? sections : buildSections(this.lessons, courseTitle);
    }

    // ── Constructor 26 tham số (dùng trong LearningService) ──────

    public StudyCourseView(
            Integer courseId, String courseTitle, String instructorName,
            List<LessonItemView> lessons, LessonItemView currentLesson,
            String lessonContent, List<MaterialView> materials,
            Integer prevLessonId, Integer nextLessonId,
            int completedCount, int totalCount, int progressPercent,
            String currentLessonType, String currentVideoUrl,
            Integer currentVideoDuration, boolean currentAllowSeek, boolean previewMode,
            List<AssignmentView> currentLessonAssignments, boolean currentLessonCompleted,
            List<QuizView> currentLessonQuizzes, String currentVideoStatus,
            int currentWatchPercent, int currentLastPosition,
            boolean currentQuizRequiresVideo, int currentMinWatchPercent,
            boolean currentQuizUnlocked, String currentWatchedSegments) {
        this(courseId, courseTitle, instructorName, lessons, currentLesson, lessonContent, materials,
                prevLessonId, nextLessonId, completedCount, totalCount, progressPercent,
                currentLessonType, currentVideoUrl, currentVideoDuration, currentAllowSeek, previewMode,
                currentLessonAssignments, currentLessonCompleted, currentLessonQuizzes,
                currentVideoStatus, currentWatchPercent, currentLastPosition,
                currentQuizRequiresVideo, currentMinWatchPercent,
                currentQuizUnlocked, currentWatchedSegments, null);
    }

    // ── Compat: 24-arg không có quizUnlocked & watchedSegments ──

    public StudyCourseView(
            Integer courseId, String courseTitle, String instructorName,
            List<LessonItemView> lessons, LessonItemView currentLesson,
            String lessonContent, List<MaterialView> materials,
            Integer prevLessonId, Integer nextLessonId,
            int completedCount, int totalCount, int progressPercent,
            String currentLessonType, String currentVideoUrl,
            Integer currentVideoDuration, boolean currentAllowSeek, boolean previewMode,
            List<AssignmentView> currentLessonAssignments, boolean currentLessonCompleted,
            List<QuizView> currentLessonQuizzes, String currentVideoStatus,
            int currentWatchPercent, int currentLastPosition,
            boolean currentQuizRequiresVideo, int currentMinWatchPercent) {
        this(courseId, courseTitle, instructorName, lessons, currentLesson, lessonContent, materials,
                prevLessonId, nextLessonId, completedCount, totalCount, progressPercent,
                currentLessonType, currentVideoUrl, currentVideoDuration, currentAllowSeek, previewMode,
                currentLessonAssignments, currentLessonCompleted, currentLessonQuizzes,
                currentVideoStatus, currentWatchPercent, currentLastPosition,
                currentQuizRequiresVideo, currentMinWatchPercent,
                currentWatchPercent >= 80, "[]");
    }

    // ── Compat: 20-arg (quiz + videoStatus, không có watchProgress) ──

    public StudyCourseView(
            Integer courseId, String courseTitle, String instructorName,
            List<LessonItemView> lessons, LessonItemView currentLesson,
            String lessonContent, List<MaterialView> materials,
            Integer prevLessonId, Integer nextLessonId,
            int completedCount, int totalCount, int progressPercent,
            String currentLessonType, String currentVideoUrl,
            Integer currentVideoDuration, boolean currentAllowSeek, boolean previewMode,
            List<AssignmentView> currentLessonAssignments, boolean currentLessonCompleted,
            List<QuizView> currentLessonQuizzes, String currentVideoStatus) {
        this(courseId, courseTitle, instructorName, lessons, currentLesson, lessonContent, materials,
                prevLessonId, nextLessonId, completedCount, totalCount, progressPercent,
                currentLessonType, currentVideoUrl, currentVideoDuration, currentAllowSeek, previewMode,
                currentLessonAssignments, currentLessonCompleted, currentLessonQuizzes,
                currentVideoStatus, -1, 0, false, 0);
    }

    // ── Compat: 20-arg không có videoStatus ──

    public StudyCourseView(
            Integer courseId, String courseTitle, String instructorName,
            List<LessonItemView> lessons, LessonItemView currentLesson,
            String lessonContent, List<MaterialView> materials,
            Integer prevLessonId, Integer nextLessonId,
            int completedCount, int totalCount, int progressPercent,
            String currentLessonType, String currentVideoUrl,
            Integer currentVideoDuration, boolean currentAllowSeek, boolean previewMode,
            List<AssignmentView> currentLessonAssignments, boolean currentLessonCompleted,
            List<QuizView> currentLessonQuizzes) {
        this(courseId, courseTitle, instructorName, lessons, currentLesson, lessonContent, materials,
                prevLessonId, nextLessonId, completedCount, totalCount, progressPercent,
                currentLessonType, currentVideoUrl, currentVideoDuration, currentAllowSeek, previewMode,
                currentLessonAssignments, currentLessonCompleted, currentLessonQuizzes,
                null, -1, 0, false, 0);
    }

    // ── Compat: 19-arg không có quiz ──

    public StudyCourseView(
            Integer courseId, String courseTitle, String instructorName,
            List<LessonItemView> lessons, LessonItemView currentLesson,
            String lessonContent, List<MaterialView> materials,
            Integer prevLessonId, Integer nextLessonId,
            int completedCount, int totalCount, int progressPercent,
            String currentLessonType, String currentVideoUrl,
            Integer currentVideoDuration, boolean currentAllowSeek, boolean previewMode,
            List<AssignmentView> currentLessonAssignments, boolean currentLessonCompleted) {
        this(courseId, courseTitle, instructorName, lessons, currentLesson, lessonContent, materials,
                prevLessonId, nextLessonId, completedCount, totalCount, progressPercent,
                currentLessonType, currentVideoUrl, currentVideoDuration, currentAllowSeek, previewMode,
                currentLessonAssignments, currentLessonCompleted, Collections.emptyList(),
                null, -1, 0, false, 0);
    }

    // ── Compat: 17-arg không có assignments ──

    public StudyCourseView(
            Integer courseId, String courseTitle, String instructorName,
            List<LessonItemView> lessons, LessonItemView currentLesson,
            String lessonContent, List<MaterialView> materials,
            Integer prevLessonId, Integer nextLessonId,
            int completedCount, int totalCount, int progressPercent,
            String currentLessonType, String currentVideoUrl,
            Integer currentVideoDuration, boolean currentAllowSeek, boolean previewMode) {
        this(courseId, courseTitle, instructorName, lessons, currentLesson, lessonContent, materials,
                prevLessonId, nextLessonId, completedCount, totalCount, progressPercent,
                currentLessonType, currentVideoUrl, currentVideoDuration, currentAllowSeek, previewMode,
                Collections.emptyList(), false, Collections.emptyList(), null, -1, 0, false, 0);
    }

    // ── Compat: 12-arg tối giản ──

    public StudyCourseView(
            Integer courseId, String courseTitle, String instructorName,
            List<LessonItemView> lessons, LessonItemView currentLesson,
            String lessonContent, List<MaterialView> materials,
            Integer prevLessonId, Integer nextLessonId,
            int completedCount, int totalCount, int progressPercent) {
        this(courseId, courseTitle, instructorName, lessons, currentLesson, lessonContent, materials,
                prevLessonId, nextLessonId, completedCount, totalCount, progressPercent,
                "ARTICLE", null, null, true, false,
                Collections.emptyList(), false, Collections.emptyList(), null, -1, 0, false, 0);
    }

    // ── record-style accessor methods (để code gọi .courseId() vẫn hoạt động) ──

    public Integer courseId()                        { return courseId; }
    public String  courseTitle()                     { return courseTitle; }
    public String  instructorName()                  { return instructorName; }
    public List<LessonItemView> lessons()            { return lessons; }
    public LessonItemView currentLesson()            { return currentLesson; }
    public String  lessonContent()                   { return lessonContent; }
    public List<MaterialView> materials()            { return materials; }
    public Integer prevLessonId()                    { return prevLessonId; }
    public Integer nextLessonId()                    { return nextLessonId; }
    public int     completedCount()                  { return completedCount; }
    public int     totalCount()                      { return totalCount; }
    public int     progressPercent()                 { return progressPercent; }
    public String  currentLessonType()               { return currentLessonType; }
    public String  currentVideoUrl()                 { return currentVideoUrl; }
    public Integer currentVideoDuration()            { return currentVideoDuration; }
    public boolean currentAllowSeek()                { return currentAllowSeek; }
    public boolean previewMode()                     { return previewMode; }
    public List<AssignmentView> currentLessonAssignments() { return currentLessonAssignments; }
    public boolean currentLessonCompleted()          { return currentLessonCompleted; }
    public List<QuizView> currentLessonQuizzes()     { return currentLessonQuizzes; }
    public String  currentVideoStatus()              { return currentVideoStatus; }
    public int     currentWatchPercent()             { return currentWatchPercent; }
    public int     currentLastPosition()             { return currentLastPosition; }
    public boolean currentQuizRequiresVideo()        { return currentQuizRequiresVideo; }
    public int     currentMinWatchPercent()          { return currentMinWatchPercent; }
    public boolean currentQuizUnlocked()             { return currentQuizUnlocked; }
    public String  currentWatchedSegments()          { return currentWatchedSegments; }
    public List<StudySectionView> sections()         { return sections; }

    // ── JavaBean getters cho JSP EL (${study.courseId} v.v.) ──────

    public Integer getCourseId()                     { return courseId; }
    public String  getCourseTitle()                  { return courseTitle; }
    public String  getInstructorName()               { return instructorName; }
    public List<LessonItemView> getLessons()         { return lessons; }
    public LessonItemView getCurrentLesson()         { return currentLesson; }
    public String  getLessonContent()                { return lessonContent; }
    public List<MaterialView> getMaterials()         { return materials; }
    public Integer getPrevLessonId()                 { return prevLessonId; }
    public Integer getNextLessonId()                 { return nextLessonId; }
    public int     getCompletedCount()               { return completedCount; }
    public int     getTotalCount()                   { return totalCount; }
    public int     getProgressPercent()              { return progressPercent; }
    public String  getCurrentLessonType()            { return currentLessonType; }
    public String  getCurrentVideoUrl()              { return currentVideoUrl; }
    public Integer getCurrentVideoDuration()         { return currentVideoDuration; }
    public boolean isCurrentAllowSeek()              { return currentAllowSeek; }
    public boolean isPreviewMode()                   { return previewMode; }
    public List<AssignmentView> getCurrentLessonAssignments() { return currentLessonAssignments; }
    public boolean isCurrentLessonCompleted()        { return currentLessonCompleted; }
    public List<QuizView> getCurrentLessonQuizzes()  { return currentLessonQuizzes; }
    public String  getCurrentVideoStatus()           { return currentVideoStatus; }
    public int     getCurrentWatchPercent()          { return currentWatchPercent; }
    public int     getCurrentLastPosition()          { return currentLastPosition; }
    public boolean isCurrentQuizRequiresVideo()      { return currentQuizRequiresVideo; }
    public int     getCurrentMinWatchPercent()       { return currentMinWatchPercent; }
    public boolean isCurrentQuizUnlocked()           { return currentQuizUnlocked; }
    public boolean getCurrentQuizUnlocked()          { return currentQuizUnlocked; }
    public String  getCurrentWatchedSegments()       { return currentWatchedSegments; }
    public List<StudySectionView> getSections()      { return sections; }

    // ── Pre-grouping logic (tính toán sẵn ở backend, JSP không cần làm logic phức tạp) ──

    public static List<StudySectionView> buildSections(List<LessonItemView> lessonList, String defaultCourseTitle) {
        if (lessonList == null || lessonList.isEmpty()) {
            return Collections.emptyList();
        }
        Map<String, List<LessonItemView>> grouped = new LinkedHashMap<>();
        Map<String, Integer> idMap = new LinkedHashMap<>();

        for (LessonItemView item : lessonList) {
            String title = (item.getSectionTitle() != null && !item.getSectionTitle().isBlank())
                    ? item.getSectionTitle()
                    : "Chương 1: " + (defaultCourseTitle != null ? defaultCourseTitle : "Nội dung khóa học");
            grouped.computeIfAbsent(title, k -> new ArrayList<>()).add(item);
            if (item.getSectionId() != null) {
                idMap.putIfAbsent(title, item.getSectionId());
            }
        }

        List<StudySectionView> result = new ArrayList<>();
        for (Map.Entry<String, List<LessonItemView>> entry : grouped.entrySet()) {
            String title = entry.getKey();
            List<LessonItemView> items = entry.getValue();
            boolean active = items.stream().anyMatch(LessonItemView::isCurrent);
            Integer sId = idMap.get(title);
            result.add(new StudySectionView(sId, title, active, items));
        }
        return result;
    }

    // ── Utility ──────────────────────────────────────────────────

    public boolean isBunnyVideo() {
        return currentVideoUrl != null && currentVideoUrl.contains("player.mediadelivery.net");
    }

    public boolean isDirectVideo() {
        if (currentVideoUrl == null) return false;
        String url = currentVideoUrl.toLowerCase();
        return !url.contains("youtube.com") && !url.contains("youtu.be")
                && !url.contains("vimeo.com") && !url.contains("player.mediadelivery.net");
    }
}
