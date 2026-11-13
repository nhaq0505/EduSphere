package com.edusphere.service.course;

import com.edusphere.dto.course.AdminLessonReviewView;
import com.edusphere.dto.course.CourseChangeLogView;
import com.edusphere.entity.account.Users;
import com.edusphere.entity.course.AnswerOption;
import com.edusphere.entity.course.Course;
import com.edusphere.entity.course.CourseChangeLog;
import com.edusphere.entity.course.CourseReview;
import com.edusphere.entity.course.CourseSection;
import com.edusphere.entity.course.Lesson;
import com.edusphere.entity.course.Material;
import com.edusphere.entity.course.Question;
import com.edusphere.entity.course.Quiz;
import com.edusphere.repository.course.AnswerOptionRepository;
import com.edusphere.repository.course.CourseChangeLogRepository;
import com.edusphere.repository.course.CourseRepository;
import com.edusphere.repository.course.CourseReviewRepository;
import com.edusphere.repository.course.CourseSectionRepository;
import com.edusphere.repository.course.LessonRepository;
import com.edusphere.repository.course.MaterialRepository;
import com.edusphere.repository.course.QuestionRepository;
import com.edusphere.repository.course.QuizRepository;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Set;

import org.hibernate.Hibernate;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class CourseChangeLogService {

    private static final DateTimeFormatter DISPLAY_DT_FMT = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm:ss");

    private static final Map<String, String> FIELD_LABELS = buildFieldLabels();

    private final CourseChangeLogRepository logRepository;
    private final CourseRepository courseRepository;
    private final CourseSectionRepository sectionRepository;
    private final LessonRepository lessonRepository;
    private final MaterialRepository materialRepository;
    private final QuizRepository quizRepository;
    private final QuestionRepository questionRepository;
    private final AnswerOptionRepository answerOptionRepository;
    private final FileUploadService fileUploadService;
    private final ObjectMapper objectMapper;

    @Autowired(required = false)
    private CourseReviewRepository courseReviewRepository;

    @Autowired
    public CourseChangeLogService(CourseChangeLogRepository logRepository,
                                  @Autowired(required = false) CourseRepository courseRepository,
                                  @Autowired(required = false) CourseSectionRepository sectionRepository,
                                  @Autowired(required = false) LessonRepository lessonRepository,
                                  @Autowired(required = false) MaterialRepository materialRepository,
                                  @Autowired(required = false) QuizRepository quizRepository,
                                  @Autowired(required = false) QuestionRepository questionRepository,
                                  @Autowired(required = false) AnswerOptionRepository answerOptionRepository,
                                  @Autowired(required = false) FileUploadService fileUploadService) {
        this.logRepository = logRepository;
        this.courseRepository = courseRepository;
        this.sectionRepository = sectionRepository;
        this.lessonRepository = lessonRepository;
        this.materialRepository = materialRepository;
        this.quizRepository = quizRepository;
        this.questionRepository = questionRepository;
        this.answerOptionRepository = answerOptionRepository;
        this.fileUploadService = fileUploadService;
        this.objectMapper = new ObjectMapper();
    }

    private static Map<String, String> buildFieldLabels() {
        Map<String, String> map = new LinkedHashMap<>();
        map.put("title", "Tiêu đề");
        map.put("description", "Lời giới thiệu / Mô tả môn học");
        map.put("categoryName", "Danh mục");
        map.put("level", "Cấp độ (Trình độ)");
        map.put("price", "Học phí (VNĐ)");
        map.put("credits", "Số tín chỉ");
        map.put("thumbnailUrl", "Ảnh bìa đại diện");
        map.put("promoVideoUrl", "Video giới thiệu");
        map.put("objectives", "Đầu ra (Mục tiêu khóa học)");
        map.put("requirements", "Đầu vào (Yêu cầu tiên quyết)");
        map.put("status", "Trạng thái");
        map.put("versionNo", "Phiên bản");
        map.put("changeNote", "Ghi chú cập nhật");
        map.put("orderIndex", "Thứ tự hiển thị");
        map.put("sectionOrder", "Thứ tự các chương");
        map.put("sectionTitle", "Thuộc chương");
        map.put("lessonType", "Thể loại bài học");
        map.put("content", "Nội dung văn bản bài học");
        map.put("videoUrl", "Đường dẫn Video");
        map.put("bunnyVideoId", "Mã Video (Bunny ID)");
        map.put("videoStatus", "Trạng thái xử lý Video");
        map.put("videoDuration", "Thời lượng Video (phút)");
        map.put("allowSeek", "Chế độ tua Video");
        map.put("quizRequiresVideo", "Khóa Quiz theo Video");
        map.put("minWatchPercent", "Ngưỡng % xem Video tối thiểu");
        map.put("isPreview", "Cho phép học thử (Preview)");
        map.put("unlockDaysAfterEnroll", "Mở khóa sau (ngày)");
        map.put("prerequisiteLesson", "Bài học tiên quyết");
        map.put("instructorNotes", "Ghi chú giảng viên");
        map.put("type", "Loại");
        map.put("fileUrl", "Đường dẫn tệp / tài liệu");
        map.put("originalFileName", "Tên file gốc");
        map.put("sizeBytes", "Dung lượng (bytes)");
        map.put("lessonTitle", "Thuộc bài học");
        map.put("timeLimitMinutes", "Thời gian làm bài (phút)");
        map.put("maxAttempts", "Số lần làm tối đa");
        map.put("passingScore", "Điểm đạt (%)");
        map.put("shuffleQuestions", "Xáo trộn câu hỏi");
        map.put("shuffleOptions", "Xáo trộn đáp án");
        map.put("rules", "Quy định làm bài");
        map.put("score", "Điểm số");
        map.put("correctAnswer", "Đáp án đúng");
        map.put("explanation", "Giải thích đáp án");
        map.put("imageUrl", "Hình ảnh minh họa");
        map.put("sampleEssayAnswer", "Đáp án mẫu tự luận");
        map.put("options", "Danh sách lựa chọn trả lời");
        return map;
    }

    // =========================================================================
    // 1. SNAPSHOT BUILDERS
    // =========================================================================

    public Map<String, Object> snapshotCourse(Course c) {
        Map<String, Object> map = new LinkedHashMap<>();
        if (c == null) return map;
        map.put("courseId", c.getCourseId());
        map.put("title", c.getTitle());
        map.put("description", c.getDescription());
        map.put("categoryName", c.getCategory() != null ? c.getCategory().getName() : "Chưa phân loại");
        map.put("level", formatCourseLevel(c.getLevel()));
        map.put("price", c.getPrice() != null ? c.getPrice().stripTrailingZeros().toPlainString() : "0");
        map.put("thumbnailUrl", c.getThumbnailUrl());
        map.put("objectives", c.getObjectives());
        map.put("requirements", c.getRequirements());
        return map;
    }

    public Map<String, Object> snapshotSection(CourseSection s) {
        Map<String, Object> map = new LinkedHashMap<>();
        if (s == null) return map;
        map.put("sectionId", s.getSectionId());
        map.put("title", s.getTitle());
        map.put("description", s.getDescription());
        map.put("orderIndex", s.getOrderIndex());
        return map;
    }

    public Map<String, Object> snapshotLesson(Lesson l) {
        Map<String, Object> map = new LinkedHashMap<>();
        if (l == null) return map;
        String rawType = l.getLessonType() != null ? l.getLessonType().toUpperCase() : "ARTICLE";
        map.put("lessonId", l.getLessonId());
        map.put("title", l.getTitle());
        map.put("lessonType", formatLessonTypeLabel(rawType));
        map.put("sectionTitle", l.getSection() != null ? l.getSection().getTitle() : "Mục chung");
        map.put("orderIndex", l.getOrderIndex());

        if ("VIDEO".equals(rawType)) {
            map.put("videoUrl", l.getVideoUrl());
            map.put("bunnyVideoId", l.getBunnyVideoId());
            map.put("videoDuration", l.getVideoDuration());
            map.put("allowSeek", Boolean.TRUE.equals(l.getAllowSeek()) ? "Cho phép tua" : "Bắt buộc xem tuần tự (Cấm tua)");
            map.put("quizRequiresVideo", Boolean.TRUE.equals(l.getQuizRequiresVideo()) ? "Có bắt buộc" : "Không bắt buộc");
            if (Boolean.TRUE.equals(l.getQuizRequiresVideo())) {
                map.put("minWatchPercent", l.getMinWatchPercent());
            }
            if (l.getContent() != null && !l.getContent().isBlank()) {
                map.put("content", l.getContent());
            }
        } else if ("QUIZ".equals(rawType)) {
            if (l.getContent() != null && !l.getContent().isBlank()) {
                map.put("content", l.getContent());
            }
        } else {
            // ARTICLE (Văn bản)
            map.put("content", l.getContent());
        }

        if (l.getInstructorNotes() != null && !l.getInstructorNotes().isBlank()) {
            map.put("instructorNotes", l.getInstructorNotes());
        }
        return map;
    }

    public Map<String, Object> snapshotVideo(Lesson l) {
        Map<String, Object> map = new LinkedHashMap<>();
        if (l == null) return map;
        map.put("lessonId", l.getLessonId());
        map.put("title", l.getTitle());
        map.put("videoUrl", l.getVideoUrl());
        map.put("bunnyVideoId", l.getBunnyVideoId());
        map.put("videoStatus", l.getVideoStatus());
        map.put("videoDuration", l.getVideoDuration());
        map.put("allowSeek", Boolean.TRUE.equals(l.getAllowSeek()) ? "Cho phép tua" : "Bắt buộc xem tuần tự (Cấm tua)");
        map.put("quizRequiresVideo", Boolean.TRUE.equals(l.getQuizRequiresVideo()) ? "Có bắt buộc" : "Không bắt buộc");
        map.put("minWatchPercent", l.getMinWatchPercent());
        return map;
    }

    public Map<String, Object> snapshotMaterial(Material m) {
        Map<String, Object> map = new LinkedHashMap<>();
        if (m == null) return map;
        map.put("materialId", m.getMaterialId());
        map.put("title", m.getTitle());
        map.put("type", m.getType());
        map.put("fileUrl", m.getFileUrl());
        map.put("originalFileName", m.getOriginalFileName());
        map.put("sizeBytes", m.getSizeBytes());
        map.put("orderIndex", m.getOrderIndex());
        map.put("lessonTitle", m.getLesson() != null ? m.getLesson().getTitle() : null);
        return map;
    }

    public Map<String, Object> snapshotQuiz(Quiz q) {
        Map<String, Object> map = new LinkedHashMap<>();
        if (q == null) return map;
        map.put("quizId", q.getQuizId());
        map.put("title", q.getTitle());
        map.put("description", q.getDescription());
        map.put("lessonTitle", q.getLesson() != null ? q.getLesson().getTitle() : "Toàn khóa học");
        map.put("timeLimitMinutes", q.getTimeLimitMinutes());
        map.put("maxAttempts", q.getMaxAttempts());
        map.put("passingScore", q.getPassingScore() != null ? q.getPassingScore().toPlainString() : null);
        map.put("shuffleQuestions", q.isShuffleQuestions() ? "Bật" : "Tắt");
        map.put("shuffleOptions", q.isShuffleOptions() ? "Bật" : "Tắt");
        map.put("rules", q.getRules());
        map.put("status", q.getStatus());
        return map;
    }

    public Map<String, Object> snapshotQuestion(Question q, List<AnswerOption> opts) {
        Map<String, Object> map = new LinkedHashMap<>();
        if (q == null) return map;
        map.put("questionId", q.getQuestionId());
        map.put("orderIndex", q.getOrderIndex());
        map.put("content", q.getContent());
        map.put("type", q.getType());
        map.put("score", q.getScore() != null ? q.getScore().toPlainString() : "1");
        map.put("correctAnswer", q.getCorrectAnswer());
        map.put("explanation", q.getExplanation());
        map.put("imageUrl", q.getImageUrl());
        map.put("videoUrl", q.getVideoUrl());
        map.put("sampleEssayAnswer", q.getSampleEssayAnswer());

        List<AnswerOption> list = opts != null ? opts : q.getOptions();
        if (list != null && !list.isEmpty()) {
            List<String> formattedOpts = new ArrayList<>();
            for (AnswerOption o : list) {
                String mark = o.isCorrect() ? "[✓ ĐÚNG] " : "[ ] ";
                formattedOpts.add(mark + o.getContent());
            }
            map.put("options", String.join("\n", formattedOpts));
        } else {
            map.put("options", null);
        }
        return map;
    }

    // =========================================================================
    // 2. RECORDING METHODS (CALLED FROM BUSINESS SERVICES)
    // =========================================================================

    @Transactional
    public void recordCourseCreate(Course course) {
        if (course == null || logRepository == null) return;
        Map<String, Object> after = snapshotCourse(course);
        saveLog(course, course.getInstructor(), "INSTRUCTOR",
                "COURSE", course.getCourseId(), course.getTitle(), null,
                "CREATE",
                "Giảng viên khởi tạo khóa học mới: " + course.getTitle(),
                "title,description,level,price,thumbnailUrl,objectives,requirements",
                null, after);
    }

    @Transactional
    public void recordCourseUpdate(Course course, Map<String, Object> before, Map<String, Object> after) {
        if (course == null || logRepository == null) return;
        List<String> changed = findChangedKeys(before, after,
                Set.of("courseId", "versionNo", "status", "credits", "promoVideoUrl", "changeNote"));
        if (changed.isEmpty()) return;

        List<String> labels = changed.stream().map(k -> FIELD_LABELS.getOrDefault(k, k)).toList();
        String summary = "Chỉnh sửa thông tin khóa học \"" + course.getTitle() + "\" (Phần đã sửa: " + String.join(", ", labels) + ")";
        saveLog(course, course.getInstructor(), "INSTRUCTOR",
                "COURSE", course.getCourseId(), course.getTitle(), null,
                "UPDATE",
                summary,
                String.join(",", changed),
                before, after);
    }

    @Transactional
    public void recordCourseStatusChange(Course course, Users actor, String actorRole,
                                         String oldStatus, String newStatus, String note) {
        if (course == null || logRepository == null) return;
        Map<String, Object> before = new LinkedHashMap<>();
        before.put("status", oldStatus);
        Map<String, Object> after = new LinkedHashMap<>();
        after.put("status", newStatus);
        if (note != null && !note.isBlank()) {
            after.put("changeNote", note);
        }
        String summary = "Thay đổi trạng thái khóa học \"" + course.getTitle() + "\": "
                + oldStatus + " -> " + newStatus
                + (note != null && !note.isBlank() ? " (Ghi chú: " + truncate(note, 120) + ")" : "");
        Users effectiveActor = actor != null ? actor : course.getInstructor();
        saveLog(course, effectiveActor, actorRole != null ? actorRole : "INSTRUCTOR",
                "COURSE", course.getCourseId(), course.getTitle(), null,
                "STATUS_CHANGE",
                summary,
                "status",
                before, after);
    }

    @Transactional
    public void recordSectionCreate(Course course, CourseSection section) {
        if (course == null || section == null || logRepository == null) return;
        Map<String, Object> after = snapshotSection(section);
        saveLog(course, course.getInstructor(), "INSTRUCTOR",
                "CHAPTER", section.getSectionId(), section.getTitle(), null,
                "CREATE",
                "Thêm chương học mới: Chương " + section.getOrderIndex() + " — " + section.getTitle(),
                "title,description,orderIndex",
                null, after);
    }

    @Transactional
    public void recordSectionUpdate(Course course, CourseSection section,
                                    Map<String, Object> before, Map<String, Object> after) {
        if (course == null || section == null || logRepository == null) return;
        List<String> changed = findChangedKeys(before, after, Set.of("sectionId"));
        if (changed.isEmpty()) return;
        List<String> labels = changed.stream().map(k -> FIELD_LABELS.getOrDefault(k, k)).toList();
        saveLog(course, course.getInstructor(), "INSTRUCTOR",
                "CHAPTER", section.getSectionId(), section.getTitle(), null,
                "UPDATE",
                "Chỉnh sửa chương học \"" + section.getTitle() + "\" (Phần đã sửa: " + String.join(", ", labels) + ")",
                String.join(",", changed),
                before, after);
    }

    @Transactional
    public void recordSectionReorder(Course course, String beforeOrder, String afterOrder) {
        if (course == null || logRepository == null || Objects.equals(beforeOrder, afterOrder)) return;
        Map<String, Object> before = Map.of("sectionOrder", beforeOrder != null ? beforeOrder : "");
        Map<String, Object> after = Map.of("sectionOrder", afterOrder != null ? afterOrder : "");
        saveLog(course, course.getInstructor(), "INSTRUCTOR",
                "CHAPTER", course.getCourseId(), course.getTitle(), null,
                "REORDER",
                "Thay đổi thứ tự các chương trong khóa học \"" + course.getTitle() + "\"",
                "sectionOrder",
                before, after);
    }

    @Transactional
    public void recordSectionDelete(Course course, Map<String, Object> beforeSnapshot) {
        if (course == null || beforeSnapshot == null || logRepository == null) return;
        Integer sectionId = (Integer) beforeSnapshot.get("sectionId");
        String title = String.valueOf(beforeSnapshot.getOrDefault("title", "Chương học"));
        saveLog(course, course.getInstructor(), "INSTRUCTOR",
                "CHAPTER", sectionId, title, null,
                "DELETE",
                "Xóa chương học \"" + title + "\"",
                "title,description,orderIndex",
                beforeSnapshot, null);
    }

    @Transactional
    public void recordLessonCreate(Course course, Lesson lesson) {
        if (course == null || lesson == null || logRepository == null) return;
        Map<String, Object> afterLesson = snapshotLesson(lesson);
        String typeLabel = formatLessonTypeLabel(lesson.getLessonType());
        saveLog(course, course.getInstructor(), "INSTRUCTOR",
                "LESSON", lesson.getLessonId(), lesson.getTitle(), lesson.getLessonId(),
                "CREATE",
                "Bài " + lesson.getOrderIndex() + " (Bài mới): " + lesson.getTitle() + " — Thể loại: " + typeLabel,
                "title,lessonType,content,orderIndex",
                null, afterLesson);

        // Nếu bài học mới tạo có đính kèm Video -> ghi nhận thêm log VIDEO để hệ thống lưu vết
        if (hasVideoInfo(lesson)) {
            Map<String, Object> afterVideo = snapshotVideo(lesson);
            saveLog(course, course.getInstructor(), "INSTRUCTOR",
                    "VIDEO", lesson.getLessonId(), lesson.getTitle(), lesson.getLessonId(),
                    "VIDEO_UPLOAD",
                    "Thêm video mới vào Bài " + lesson.getOrderIndex() + ": " + lesson.getTitle()
                            + (lesson.getBunnyVideoId() != null ? " (Bunny ID: " + lesson.getBunnyVideoId() + ")" : ""),
                    "videoUrl,bunnyVideoId,videoDuration,allowSeek",
                    null, afterVideo);
        }
    }

    @Transactional
    public void recordLessonUpdate(Course course, Lesson lesson,
                                   Map<String, Object> beforeLesson, Map<String, Object> afterLesson,
                                   Map<String, Object> beforeVideo, Map<String, Object> afterVideo) {
        if (course == null || lesson == null || logRepository == null) return;

        Set<String> ignoreLessonKeys = new LinkedHashSet<>(Set.of(
                "lessonId", "status", "videoStatus", "isPreview", "unlockDaysAfterEnroll", "prerequisiteLesson"));
        if (!"VIDEO".equalsIgnoreCase(lesson.getLessonType())) {
            ignoreLessonKeys.addAll(Set.of("videoUrl", "bunnyVideoId", "videoDuration", "allowSeek", "quizRequiresVideo", "minWatchPercent"));
        }

        List<String> allChanged = findChangedKeys(beforeLesson, afterLesson, ignoreLessonKeys);
        if (!allChanged.isEmpty()) {
            List<String> labels = allChanged.stream().map(k -> FIELD_LABELS.getOrDefault(k, k)).toList();
            String action = (allChanged.size() == 1 && allChanged.contains("orderIndex")) ? "REORDER" : "UPDATE";
            String summary = "REORDER".equals(action)
                    ? "Thay đổi vị trí Bài " + lesson.getOrderIndex() + ": " + lesson.getTitle() + " (" + beforeLesson.get("orderIndex") + " -> " + afterLesson.get("orderIndex") + ")"
                    : "Cập nhật bổ sung Bài " + lesson.getOrderIndex() + ": " + lesson.getTitle() + " (Phần đã sửa: " + String.join(", ", labels) + ")";
            saveLog(course, course.getInstructor(), "INSTRUCTOR",
                    "LESSON", lesson.getLessonId(), lesson.getTitle(), lesson.getLessonId(),
                    action,
                    summary,
                    String.join(",", allChanged),
                    beforeLesson, afterLesson);
        }

        // Kiểm tra thay đổi riêng về Video (chỉ khi bài học thuộc thể loại Video hoặc có thay đổi URL video thực sự)
        List<String> videoChanged = findChangedKeys(beforeVideo, afterVideo, Set.of("lessonId", "videoStatus"));
        if (!videoChanged.isEmpty() && ("VIDEO".equalsIgnoreCase(lesson.getLessonType()) || hasVideoInfo(lesson))) {
            String oldUrl = asString(beforeVideo.get("videoUrl"));
            String newUrl = asString(afterVideo.get("videoUrl"));
            String oldBunny = asString(beforeVideo.get("bunnyVideoId"));
            String newBunny = asString(afterVideo.get("bunnyVideoId"));

            if ((oldUrl == null || oldUrl.isBlank()) && (newUrl != null && !newUrl.isBlank())) {
                saveLog(course, course.getInstructor(), "INSTRUCTOR",
                        "VIDEO", lesson.getLessonId(), lesson.getTitle(), lesson.getLessonId(),
                        "VIDEO_UPLOAD",
                        "Thêm video vào Bài " + lesson.getOrderIndex() + ": " + lesson.getTitle()
                                + (newBunny != null ? " (Bunny ID: " + newBunny + ")" : ""),
                        String.join(",", videoChanged),
                        beforeVideo, afterVideo);
            } else if ((oldUrl != null && !oldUrl.isBlank()) && (newUrl == null || newUrl.isBlank())) {
                saveLog(course, course.getInstructor(), "INSTRUCTOR",
                        "VIDEO", lesson.getLessonId(), lesson.getTitle(), lesson.getLessonId(),
                        "VIDEO_REMOVE",
                        "Xóa video khỏi Bài " + lesson.getOrderIndex() + ": " + lesson.getTitle(),
                        String.join(",", videoChanged),
                        beforeVideo, afterVideo);
            } else if (!Objects.equals(oldUrl, newUrl) || !Objects.equals(oldBunny, newBunny)) {
                saveLog(course, course.getInstructor(), "INSTRUCTOR",
                        "VIDEO", lesson.getLessonId(), lesson.getTitle(), lesson.getLessonId(),
                        "VIDEO_REPLACE",
                        "Thay đổi video Bài " + lesson.getOrderIndex() + ": " + lesson.getTitle()
                                + (newBunny != null ? " (Bunny ID mới: " + newBunny + ")" : ""),
                        String.join(",", videoChanged),
                        beforeVideo, afterVideo);
            } else {
                List<String> vLabels = videoChanged.stream().map(k -> FIELD_LABELS.getOrDefault(k, k)).toList();
                saveLog(course, course.getInstructor(), "INSTRUCTOR",
                        "VIDEO", lesson.getLessonId(), lesson.getTitle(), lesson.getLessonId(),
                        "UPDATE",
                        "Cập nhật cấu hình video Bài " + lesson.getOrderIndex() + ": " + lesson.getTitle() + " (" + String.join(", ", vLabels) + ")",
                        String.join(",", videoChanged),
                        beforeVideo, afterVideo);
            }
        }
    }

    @Transactional
    public void recordVideoDirectUpload(Lesson lesson, Map<String, Object> beforeVideo,
                                        Map<String, Object> afterVideo, String originalFileName, long fileSize) {
        if (lesson == null || lesson.getCourse() == null || logRepository == null) return;
        Course course = lesson.getCourse();
        String oldUrl = beforeVideo != null ? asString(beforeVideo.get("videoUrl")) : null;
        String action = (oldUrl != null && !oldUrl.isBlank()) ? "VIDEO_REPLACE" : "VIDEO_UPLOAD";
        Map<String, Object> enrichedAfter = new LinkedHashMap<>(afterVideo);
        enrichedAfter.put("originalFileName", originalFileName);
        enrichedAfter.put("sizeBytes", fileSize);

        String summary = ("VIDEO_REPLACE".equals(action) ? "Thay thế video Bunny Stream cho bài học «" : "Tải video Bunny Stream lên bài học «")
                + lesson.getTitle() + "» (Bunny ID: " + lesson.getBunnyVideoId() + ", File: " + originalFileName + ")";
        saveLog(course, course.getInstructor(), "INSTRUCTOR",
                "VIDEO", lesson.getLessonId(), lesson.getTitle(), lesson.getLessonId(),
                action,
                summary,
                "videoUrl,bunnyVideoId,originalFileName,sizeBytes",
                beforeVideo, enrichedAfter);
    }

    @Transactional
    public void recordLessonDelete(Course course, Lesson lesson, Map<String, Object> beforeLessonSnapshot) {
        if (course == null || beforeLessonSnapshot == null || logRepository == null) return;
        Integer lessonId = (Integer) beforeLessonSnapshot.get("lessonId");
        String title = String.valueOf(beforeLessonSnapshot.getOrDefault("title", "Bài học"));
        saveLog(course, course.getInstructor(), "INSTRUCTOR",
                "LESSON", lessonId, title, lessonId,
                "DELETE",
                "Xóa bài học «" + title + "»",
                "title,lessonType,content,videoUrl",
                beforeLessonSnapshot, null);
    }

    @Transactional
    public void recordMaterialCreate(Course course, Lesson lesson, Material material) {
        if (course == null || material == null || logRepository == null) return;
        Map<String, Object> after = snapshotMaterial(material);
        Integer lessonId = lesson != null ? lesson.getLessonId() : (material.getLesson() != null ? material.getLesson().getLessonId() : null);
        String lessonTitle = lesson != null ? lesson.getTitle() : (material.getLesson() != null ? material.getLesson().getTitle() : "");
        saveLog(course, course.getInstructor(), "INSTRUCTOR",
                "DOCUMENT", material.getMaterialId(), material.getTitle(), lessonId,
                "CREATE",
                "Thêm tài liệu «" + material.getTitle() + "» [" + material.getType() + "] vào bài học «" + lessonTitle + "»",
                "title,type,fileUrl,originalFileName,sizeBytes",
                null, after);
    }

    @Transactional
    public void recordMaterialUpdate(Course course, Lesson lesson, Material material,
                                     Map<String, Object> before, Map<String, Object> after) {
        if (course == null || material == null || logRepository == null) return;
        List<String> changed = findChangedKeys(before, after, Set.of("materialId"));
        if (changed.isEmpty()) return;
        List<String> labels = changed.stream().map(k -> FIELD_LABELS.getOrDefault(k, k)).toList();
        Integer lessonId = lesson != null ? lesson.getLessonId() : (material.getLesson() != null ? material.getLesson().getLessonId() : null);
        String lessonTitle = lesson != null ? lesson.getTitle() : (material.getLesson() != null ? material.getLesson().getTitle() : "");
        saveLog(course, course.getInstructor(), "INSTRUCTOR",
                "DOCUMENT", material.getMaterialId(), material.getTitle(), lessonId,
                "UPDATE",
                "Cập nhật tài liệu «" + material.getTitle() + "» trong bài học «" + lessonTitle + "» (" + String.join(", ", labels) + ")",
                String.join(",", changed),
                before, after);
    }

    @Transactional
    public void recordMaterialDelete(Course course, Lesson lesson, Map<String, Object> beforeMaterialSnapshot) {
        if (course == null || beforeMaterialSnapshot == null || logRepository == null) return;
        Integer matId = (Integer) beforeMaterialSnapshot.get("materialId");
        String title = String.valueOf(beforeMaterialSnapshot.getOrDefault("title", "Tài liệu"));
        Integer lessonId = lesson != null ? lesson.getLessonId() : null;
        String lessonTitle = lesson != null ? lesson.getTitle() : String.valueOf(beforeMaterialSnapshot.getOrDefault("lessonTitle", ""));
        saveLog(course, course.getInstructor(), "INSTRUCTOR",
                "DOCUMENT", matId, title, lessonId,
                "DELETE",
                "Xóa tài liệu «" + title + "» khỏi bài học «" + lessonTitle + "»",
                "title,type,fileUrl",
                beforeMaterialSnapshot, null);
    }

    @Transactional
    public void recordQuizCreate(Course course, Quiz quiz) {
        if (course == null || quiz == null || logRepository == null) return;
        Map<String, Object> after = snapshotQuiz(quiz);
        Integer lessonId = quiz.getLesson() != null ? quiz.getLesson().getLessonId() : null;
        saveLog(course, course.getInstructor(), "INSTRUCTOR",
                "QUIZ", quiz.getQuizId(), quiz.getTitle(), lessonId,
                "CREATE",
                "Tạo bài Quiz mới: «" + quiz.getTitle() + "»",
                "title,description,timeLimitMinutes,maxAttempts,passingScore",
                null, after);
    }

    @Transactional
    public void recordQuizUpdate(Course course, Quiz quiz,
                                 Map<String, Object> before, Map<String, Object> after) {
        if (course == null || quiz == null || logRepository == null) return;
        List<String> changed = findChangedKeys(before, after, Set.of("quizId"));
        if (changed.isEmpty()) return;
        List<String> labels = changed.stream().map(k -> FIELD_LABELS.getOrDefault(k, k)).toList();
        Integer lessonId = quiz.getLesson() != null ? quiz.getLesson().getLessonId() : null;
        saveLog(course, course.getInstructor(), "INSTRUCTOR",
                "QUIZ", quiz.getQuizId(), quiz.getTitle(), lessonId,
                "UPDATE",
                "Cập nhật cài đặt Quiz «" + quiz.getTitle() + "» (" + String.join(", ", labels) + ")",
                String.join(",", changed),
                before, after);
    }

    @Transactional
    public void recordQuizStatusChange(Course course, Quiz quiz, String oldStatus, String newStatus) {
        if (course == null || quiz == null || logRepository == null) return;
        Integer lessonId = quiz.getLesson() != null ? quiz.getLesson().getLessonId() : null;
        saveLog(course, course.getInstructor(), "INSTRUCTOR",
                "QUIZ", quiz.getQuizId(), quiz.getTitle(), lessonId,
                "STATUS_CHANGE",
                "Thay đổi trạng thái Quiz \"" + quiz.getTitle() + "\": " + oldStatus + " -> " + newStatus,
                "status",
                Map.of("status", oldStatus),
                Map.of("status", newStatus));
    }

    @Transactional
    public void recordQuestionCreate(Course course, Quiz quiz, Question question, List<AnswerOption> opts) {
        if (course == null || quiz == null || question == null || logRepository == null) return;
        Map<String, Object> after = snapshotQuestion(question, opts);
        Integer lessonId = quiz.getLesson() != null ? quiz.getLesson().getLessonId() : null;
        saveLog(course, course.getInstructor(), "INSTRUCTOR",
                "QUESTION", question.getQuestionId(), truncate(question.getContent(), 120), lessonId,
                "CREATE",
                "Thêm câu hỏi #" + question.getOrderIndex() + " vào Quiz \"" + quiz.getTitle() + "\": " + truncate(question.getContent(), 80),
                "content,type,score,correctAnswer,options",
                null, after);
    }

    @Transactional
    public void recordQuestionUpdate(Course course, Quiz quiz, Question question,
                                     Map<String, Object> before, Map<String, Object> after) {
        if (course == null || quiz == null || question == null || logRepository == null) return;
        List<String> changed = findChangedKeys(before, after, Set.of("questionId"));
        if (changed.isEmpty()) return;
        List<String> labels = changed.stream().map(k -> FIELD_LABELS.getOrDefault(k, k)).toList();
        Integer lessonId = quiz.getLesson() != null ? quiz.getLesson().getLessonId() : null;
        saveLog(course, course.getInstructor(), "INSTRUCTOR",
                "QUESTION", question.getQuestionId(), truncate(question.getContent(), 120), lessonId,
                "UPDATE",
                "Chỉnh sửa câu hỏi #" + question.getOrderIndex() + " trong Quiz \"" + quiz.getTitle() + "\" (Phần đã sửa: " + String.join(", ", labels) + ")",
                String.join(",", changed),
                before, after);
    }

    @Transactional
    public void recordQuestionDelete(Course course, Quiz quiz, Map<String, Object> beforeQuestionSnapshot) {
        if (course == null || quiz == null || beforeQuestionSnapshot == null || logRepository == null) return;
        Integer qId = (Integer) beforeQuestionSnapshot.get("questionId");
        String content = String.valueOf(beforeQuestionSnapshot.getOrDefault("content", "Câu hỏi"));
        Integer lessonId = quiz.getLesson() != null ? quiz.getLesson().getLessonId() : null;
        saveLog(course, course.getInstructor(), "INSTRUCTOR",
                "QUESTION", qId, truncate(content, 120), lessonId,
                "DELETE",
                "Xóa câu hỏi khỏi Quiz \"" + quiz.getTitle() + "\": " + truncate(content, 80),
                "content,type,score,correctAnswer,options",
                beforeQuestionSnapshot, null);
    }

    @Transactional
    public void recordQuestionsImported(Course course, Quiz quiz, int count, String mode) {
        if (course == null || quiz == null || count <= 0 || logRepository == null) return;
        Integer lessonId = quiz.getLesson() != null ? quiz.getLesson().getLessonId() : null;
        Map<String, Object> after = new LinkedHashMap<>();
        after.put("quizTitle", quiz.getTitle());
        after.put("importedCount", count);
        after.put("mode", mode);
        saveLog(course, course.getInstructor(), "INSTRUCTOR",
                "QUESTION", quiz.getQuizId(), quiz.getTitle(), lessonId,
                "CREATE",
                "Nhập " + count + " câu hỏi từ Ngân hàng câu hỏi vào Quiz \"" + quiz.getTitle() + "\" (" + mode + ")",
                "options",
                null, after);
    }

    // =========================================================================
    // 3. QUERY & ADMIN INSPECTION METHODS
    // =========================================================================

    @Transactional(readOnly = true)
    public Page<CourseChangeLogView> searchLogs(Integer courseId, Integer teacherId,
                                                String entityType, String actionType,
                                                String keyword, LocalDateTime fromDate,
                                                LocalDateTime toDate, Pageable pageable) {
        Page<CourseChangeLog> rawPage = logRepository.searchLogs(
                courseId, teacherId,
                cleanParam(entityType), cleanParam(actionType),
                cleanParam(keyword), fromDate, toDate, Pageable.unpaged());
        List<CourseChangeLogView> filtered = filterAndEnrichLogsForAdmin(
                rawPage.getContent(), cleanParam(actionType), null);

        if (pageable == null || pageable.isUnpaged()) {
            return new PageImpl<>(filtered);
        }
        int start = Math.min((int) pageable.getOffset(), filtered.size());
        int end = Math.min(start + pageable.getPageSize(), filtered.size());
        return new PageImpl<>(filtered.subList(start, end), pageable, filtered.size());
    }

    @Transactional(readOnly = true)
    public CourseChangeLogView getLogDetail(Long logId) {
        CourseChangeLog log = logRepository.findById(logId)
                .orElseThrow(() -> new CourseActionException(HttpStatus.NOT_FOUND, "Không tìm thấy bản ghi lịch sử thay đổi #" + logId));
        return toView(log, true);
    }

    @Transactional(readOnly = true)
    public List<CourseChangeLogView> getCourseLogs(Integer courseId) {
        List<CourseChangeLog> raw = logRepository.findTop50ByCourseIdOrderByCreatedAtDesc(courseId);
        return filterAndEnrichLogsForAdmin(raw, null, null);
    }

    @Transactional(readOnly = true)
    public List<CourseChangeLogView> getLessonLogs(Integer courseId, Integer lessonId) {
        return logRepository.findByCourseIdAndParentLessonIdOrderByCreatedAtDesc(courseId, lessonId).stream()
                .filter(l -> !"STATUS_CHANGE".equals(l.getActionType()))
                .map(l -> toView(l, true))
                .toList();
    }

    /**
     * Tìm thời điểm khóa học được Admin phê duyệt lần đầu tiên.
     * Mọi log tạo mới trước thời điểm này thuộc về lần khởi tạo khóa học ban đầu (v1) và không hiển thị trong lịch sử cập nhật.
     */
    @Transactional(readOnly = true)
    public LocalDateTime findFirstApprovalTime(Integer courseId) {
        if (courseId == null) return null;
        LocalDateTime earliest = null;

        if (courseReviewRepository != null) {
            List<CourseReview> reviews = courseReviewRepository.findByCourse_CourseIdOrderByReviewedAtDesc(courseId);
            if (reviews != null) {
                for (CourseReview r : reviews) {
                    if ("APPROVED".equalsIgnoreCase(r.getDecision()) && r.getReviewedAt() != null) {
                        if (earliest == null || r.getReviewedAt().isBefore(earliest)) {
                            earliest = r.getReviewedAt();
                        }
                    }
                }
            }
        }

        if (logRepository != null) {
            List<CourseChangeLog> logs = logRepository.findByCourseIdOrderByCreatedAtDesc(courseId);
            for (CourseChangeLog l : logs) {
                if ("STATUS_CHANGE".equals(l.getActionType()) && l.getAfterData() != null
                        && (l.getAfterData().contains("\"APPROVED\"") || l.getAfterData().contains("\"PUBLISHED\""))
                        && l.getCreatedAt() != null) {
                    if (earliest == null || l.getCreatedAt().isBefore(earliest)) {
                        earliest = l.getCreatedAt();
                    }
                }
            }
        }

        if (earliest == null && courseRepository != null) {
            Course course = courseRepository.findById(courseId).orElse(null);
            if (course != null) {
                if (course.getApprovedAt() != null) {
                    earliest = course.getApprovedAt();
                } else if (course.getPublishedAt() != null) {
                    earliest = course.getPublishedAt();
                }
            }
        }

        return earliest;
    }

    /**
     * Tìm thời điểm khóa học được Admin phê duyệt (hoặc công bố) gần nhất trước đợt gửi duyệt hiện tại.
     * Nếu khóa học chưa từng được phê duyệt lần nào (lần đầu gửi duyệt), trả về null.
     */
    @Transactional(readOnly = true)
    public LocalDateTime findLastApprovalTime(Integer courseId) {
        if (courseId == null) return null;
        LocalDateTime latest = null;

        if (courseRepository != null) {
            Course course = courseRepository.findById(courseId).orElse(null);
            if (course != null) {
                if (course.getPublishedAt() != null) {
                    latest = course.getPublishedAt();
                }
                if (course.getApprovedAt() != null && (latest == null || course.getApprovedAt().isAfter(latest))) {
                    latest = course.getApprovedAt();
                }
            }
        }

        if (courseReviewRepository != null) {
            List<CourseReview> reviews = courseReviewRepository.findByCourse_CourseIdOrderByReviewedAtDesc(courseId);
            if (reviews != null) {
                for (CourseReview r : reviews) {
                    if ("APPROVED".equalsIgnoreCase(r.getDecision()) && r.getReviewedAt() != null) {
                        if (latest == null || r.getReviewedAt().isAfter(latest)) {
                            latest = r.getReviewedAt();
                        }
                        break;
                    }
                }
            }
        }

        if (logRepository != null) {
            List<CourseChangeLog> logs = logRepository.findByCourseIdOrderByCreatedAtDesc(courseId);
            for (CourseChangeLog l : logs) {
                if ("STATUS_CHANGE".equals(l.getActionType()) && l.getAfterData() != null
                        && (l.getAfterData().contains("\"APPROVED\"") || l.getAfterData().contains("\"PUBLISHED\""))
                        && l.getCreatedAt() != null) {
                    if (latest == null || l.getCreatedAt().isAfter(latest)) {
                        latest = l.getCreatedAt();
                    }
                    break;
                }
            }
        }

        return latest;
    }

    /**
     * Kiểm tra khóa học có phải là lần cập nhật/bổ sung sau khi đã được duyệt ít nhất 1 lần hay không.
     * - false: Giảng viên mới tạo khóa học và gửi duyệt lần đầu tiên.
     * - true: Khóa học đã từng được duyệt/công bố, giảng viên chỉnh sửa hoặc bổ sung nội dung lần 2 trở đi.
     */
    @Transactional(readOnly = true)
    public boolean isUpdateAfterApproval(Integer courseId) {
        if (courseId == null) return false;
        if (findLastApprovalTime(courseId) != null) {
            return true;
        }
        if (lessonRepository != null) {
            List<Lesson> lessons = lessonRepository.findByCourse_CourseIdOrderByOrderIndexAsc(courseId);
            boolean hasPublishedLesson = lessons.stream()
                    .anyMatch(l -> "PUBLISHED".equalsIgnoreCase(l.getStatus()));
            if (hasPublishedLesson) {
                return true;
            }
        }
        return false;
    }

    /**
     * Lấy danh sách các thay đổi của khóa học phát sinh sau lần phê duyệt gần nhất.
     * Dùng để hiển thị cho Admin biết chính xác giảng viên đã sửa/bổ sung những gì ở lần cập nhật thứ 2 trở đi.
     */
    @Transactional(readOnly = true)
    public List<CourseChangeLogView> getChangesSinceLastApproval(Integer courseId) {
        if (courseId == null || logRepository == null) return List.of();
        if (!isUpdateAfterApproval(courseId)) {
            return List.of();
        }
        LocalDateTime lastApproved = findLastApprovalTime(courseId);
        List<CourseChangeLog> allLogs = logRepository.findByCourseIdOrderByCreatedAtDesc(courseId);
        return filterAndEnrichLogsForAdmin(allLogs, null, lastApproved);
    }

    /**
     * Lọc và làm giàu danh sách lịch sử thay đổi cho Admin:
     * 1. Bỏ qua các khóa học mới gửi lần đầu (chưa từng duyệt) và các bản ghi khởi tạo trước lần duyệt đầu tiên.
     * 2. Bỏ qua các bản ghi đổi trạng thái tự động (DRAFT -> SUBMITTED, SUBMITTED -> APPROVED) để không gây rối mắt.
     * 3. Khi có bài học mới (Bài 2, Bài 3...), gom thông tin thể loại (Video / Văn bản / Quiz) và nội dung chi tiết
     *    vào đúng thẻ Bài học mới đó, ẩn các bản ghi phụ trùng lặp.
     * 4. Với các thao tác chỉnh sửa (Khóa học, Chương học, hoặc Bài học đã có), chỉ giữ lại bản ghi thực sự có trường thay đổi.
     */
    private List<CourseChangeLogView> filterAndEnrichLogsForAdmin(List<CourseChangeLog> rawLogs,
                                                                  String requestedActionType,
                                                                  LocalDateTime minTimestampOverride) {
        if (rawLogs == null || rawLogs.isEmpty()) return List.of();

        Map<Integer, Boolean> courseApprovedCache = new LinkedHashMap<>();
        Map<Integer, LocalDateTime> firstApprovalCache = new LinkedHashMap<>();

        List<CourseChangeLog> postApprovalLogs = new ArrayList<>();
        for (CourseChangeLog l : rawLogs) {
            Integer cId = l.getCourseId();
            if (cId == null) continue;

            boolean isApprovedAtLeastOnce = courseApprovedCache.computeIfAbsent(cId, this::isUpdateAfterApproval);
            if (!isApprovedAtLeastOnce) {
                continue;
            }

            if (!"STATUS_CHANGE".equalsIgnoreCase(requestedActionType) && "STATUS_CHANGE".equals(l.getActionType())) {
                continue;
            }

            if ("COURSE".equals(l.getEntityType()) && "CREATE".equals(l.getActionType())) {
                continue;
            }

            LocalDateTime cutoff = minTimestampOverride != null
                    ? minTimestampOverride
                    : firstApprovalCache.computeIfAbsent(cId, this::findFirstApprovalTime);

            if (cutoff != null && l.getCreatedAt() != null && !l.getCreatedAt().isAfter(cutoff)) {
                continue;
            }

            postApprovalLogs.add(l);
        }

        // Xác định danh sách ID của các bài học mới được tạo sau phê duyệt (Trường hợp 2: Bài 2, Bài 3...)
        Set<Integer> newlyCreatedLessonIds = new LinkedHashSet<>();
        for (CourseChangeLog l : postApprovalLogs) {
            if ("LESSON".equals(l.getEntityType()) && "CREATE".equals(l.getActionType()) && l.getEntityId() != null) {
                newlyCreatedLessonIds.add(l.getEntityId());
            }
        }

        List<CourseChangeLogView> result = new ArrayList<>();
        for (CourseChangeLog l : postApprovalLogs) {
            boolean isNewLessonCreateLog = "LESSON".equals(l.getEntityType()) && "CREATE".equals(l.getActionType());
            boolean isLessonDeleteLog = "LESSON".equals(l.getEntityType()) && "DELETE".equals(l.getActionType());

            if (!isNewLessonCreateLog && !isLessonDeleteLog) {
                Integer parentLessonId = l.getParentLessonId();
                if (parentLessonId != null && newlyCreatedLessonIds.contains(parentLessonId)) {
                    // Đã được gom vào chi tiết của thẻ Bài học mới (newLessonDetail) -> không hiện thẻ rời rạc
                    continue;
                }
            }

            CourseChangeLogView view = toView(l, true);

            // Nếu là thao tác chỉnh sửa nhưng không có trường nào thực sự thay đổi -> không hiển thị
            if ("UPDATE".equals(view.getActionType())
                    && (view.getFieldDiffs() == null || view.getFieldDiffs().isEmpty())) {
                continue;
            }

            result.add(view);
        }

        return result;
    }

    /**
     * Xây dựng dữ liệu chi tiết đầy đủ cho toàn bộ các bài học trong khóa học (phục vụ Admin xem nội dung & diff).
     */
    @Transactional(readOnly = true)
    public Map<Integer, AdminLessonReviewView> buildCourseLessonReviewMap(Integer courseId) {
        Map<Integer, AdminLessonReviewView> result = new LinkedHashMap<>();
        if (lessonRepository == null) return result;

        boolean isUpdateSubmission = isUpdateAfterApproval(courseId);
        LocalDateTime lastApprovedOrPublished = findLastApprovalTime(courseId);

        List<Lesson> lessons = lessonRepository.findByCourse_CourseIdOrderByOrderIndexAsc(courseId);
        List<CourseChangeLog> allCourseLogs = (isUpdateSubmission && logRepository != null)
                ? logRepository.findByCourseIdOrderByCreatedAtDesc(courseId)
                : List.of();

        for (Lesson lesson : lessons) {
            AdminLessonReviewView view = buildSingleLessonReviewView(
                    lesson, isUpdateSubmission, lastApprovedOrPublished, allCourseLogs);
            result.put(lesson.getLessonId(), view);
        }
        return result;
    }

    @Transactional(readOnly = true)
    public AdminLessonReviewView getAdminLessonDetail(Integer courseId, Integer lessonId) {
        if (lessonRepository == null) {
            throw new CourseActionException(HttpStatus.NOT_FOUND, "Không tìm thấy bài học.");
        }
        Lesson lesson = lessonRepository.findByLessonIdAndCourse_CourseId(lessonId, courseId)
                .orElseThrow(() -> new CourseActionException(HttpStatus.NOT_FOUND, "Không tìm thấy bài học #" + lessonId));
        boolean isUpdateSubmission = isUpdateAfterApproval(courseId);
        LocalDateTime lastApprovedOrPublished = findLastApprovalTime(courseId);
        List<CourseChangeLog> lessonLogs = (isUpdateSubmission && logRepository != null)
                ? logRepository.findByCourseIdAndParentLessonIdOrderByCreatedAtDesc(courseId, lessonId)
                : List.of();
        return buildSingleLessonReviewView(lesson, isUpdateSubmission, lastApprovedOrPublished, lessonLogs);
    }

    private AdminLessonReviewView buildSingleLessonReviewView(Lesson lesson,
                                                              boolean isUpdateSubmission,
                                                              LocalDateTime lastApprovedOrPublished,
                                                              List<CourseChangeLog> candidateLogs) {
        Hibernate.initialize(lesson.getSection());
        Hibernate.initialize(lesson.getPrerequisiteLesson());

        AdminLessonReviewView v = new AdminLessonReviewView();
        v.setLessonId(lesson.getLessonId());
        v.setCourseId(lesson.getCourse() != null ? lesson.getCourse().getCourseId() : null);
        v.setSectionId(lesson.getSection() != null ? lesson.getSection().getSectionId() : null);
        v.setSectionTitle(lesson.getSection() != null ? lesson.getSection().getTitle() : "Bài học chưa phân mục");
        v.setTitle(lesson.getTitle());
        v.setLessonType(lesson.getLessonType() != null ? lesson.getLessonType() : "ARTICLE");
        v.setStatus(lesson.getStatus());
        v.setOrderIndex(lesson.getOrderIndex());
        v.setContent(lesson.getContent());
        v.setVideoUrl(lesson.getVideoUrl());
        v.setBunnyVideoId(lesson.getBunnyVideoId());
        v.setVideoStatus(lesson.getVideoStatus());
        v.setVideoDuration(lesson.getVideoDuration());
        v.setAllowSeek(lesson.getAllowSeek());
        v.setQuizRequiresVideo(lesson.getQuizRequiresVideo());
        v.setMinWatchPercent(lesson.getMinWatchPercent());
        v.setIsPreview(lesson.getIsPreview());
        v.setUnlockDaysAfterEnroll(lesson.getUnlockDaysAfterEnroll());
        v.setPrerequisiteLessonId(lesson.getPrerequisiteLesson() != null ? lesson.getPrerequisiteLesson().getLessonId() : null);
        v.setPrerequisiteLessonTitle(lesson.getPrerequisiteLesson() != null ? lesson.getPrerequisiteLesson().getTitle() : null);
        v.setInstructorNotes(lesson.getInstructorNotes());
        v.setCreatedAt(lesson.getCreatedAt());
        v.setUpdatedAt(lesson.getUpdatedAt());

        if (lesson.getVideoUrl() != null && !lesson.getVideoUrl().isBlank()) {
            v.setVideoExists(checkResourceExists(lesson.getVideoUrl()));
        }

        // Tài liệu đính kèm của bài học
        if (materialRepository != null) {
            List<Material> mats = materialRepository.findByLesson_LessonIdOrderByOrderIndexAsc(lesson.getLessonId());
            List<AdminLessonReviewView.MaterialItem> matItems = new ArrayList<>();
            for (Material m : mats) {
                boolean exists = checkResourceExists(m.getFileUrl());
                matItems.add(new AdminLessonReviewView.MaterialItem(
                        m.getMaterialId(), m.getTitle(), m.getType(), m.getFileUrl(),
                        m.getOriginalFileName(), m.getSizeBytes(), m.getUploadedAt(), exists));
            }
            v.setMaterials(matItems);
        }

        // Các bài Quiz gắn với bài học này
        if (quizRepository != null) {
            List<Quiz> linkedQuizzes = quizRepository.findByLesson_LessonId(lesson.getLessonId());
            List<AdminLessonReviewView.QuizItem> quizItems = new ArrayList<>();
            if (linkedQuizzes != null) {
                for (Quiz q : linkedQuizzes) {
                    AdminLessonReviewView.QuizItem qi = new AdminLessonReviewView.QuizItem();
                    qi.setQuizId(q.getQuizId());
                    qi.setTitle(q.getTitle());
                    qi.setDescription(q.getDescription());
                    qi.setTimeLimitMinutes(q.getTimeLimitMinutes());
                    qi.setMaxAttempts(q.getMaxAttempts());
                    qi.setPassingScore(q.getPassingScore());
                    qi.setStatus(q.getStatus());
                    qi.setShuffleQuestions(q.isShuffleQuestions());
                    qi.setShuffleOptions(q.isShuffleOptions());

                    if (questionRepository != null) {
                        List<Question> qs = questionRepository.findByQuiz_QuizIdOrderByOrderIndexAsc(q.getQuizId());
                        List<AdminLessonReviewView.QuestionItem> qItems = new ArrayList<>();
                        for (Question question : qs) {
                            Hibernate.initialize(question.getOptions());
                            AdminLessonReviewView.QuestionItem qItem = new AdminLessonReviewView.QuestionItem();
                            qItem.setQuestionId(question.getQuestionId());
                            qItem.setOrderIndex(question.getOrderIndex());
                            qItem.setContent(question.getContent());
                            qItem.setType(question.getType());
                            qItem.setScore(question.getScore());
                            qItem.setCorrectAnswer(question.getCorrectAnswer());
                            qItem.setExplanation(question.getExplanation());
                            qItem.setImageUrl(question.getImageUrl());
                            qItem.setVideoUrl(question.getVideoUrl());
                            qItem.setSampleEssayAnswer(question.getSampleEssayAnswer());

                            List<AdminLessonReviewView.OptionItem> optItems = new ArrayList<>();
                            if (question.getOptions() != null) {
                                for (AnswerOption opt : question.getOptions()) {
                                    optItems.add(new AdminLessonReviewView.OptionItem(
                                            opt.getOptionId(), opt.getOrderIndex(), opt.getContent(), opt.isCorrect()));
                                }
                            }
                            qItem.setOptions(optItems);
                            qItems.add(qItem);
                        }
                        qi.setQuestions(qItems);
                    }
                    quizItems.add(qi);
                }
            }
            v.setQuizzes(quizItems);
        }

        if (!isUpdateSubmission) {
            // Khóa học gửi lên lần đầu tiên -> không đánh dấu trạng thái thay đổi
            v.setChangeLogs(List.of());
            v.setNewlyCreated(false);
            v.setRecentlyUpdated(false);
            v.setChangeState("INITIAL");
            return v;
        }

        // Lọc lịch sử thay đổi thuộc về bài học này kể từ sau lần duyệt trước
        List<CourseChangeLogView> lessonLogViews = candidateLogs.stream()
                .filter(l -> Objects.equals(l.getParentLessonId(), lesson.getLessonId())
                        || (("LESSON".equals(l.getEntityType()) || "VIDEO".equals(l.getEntityType()))
                            && Objects.equals(l.getEntityId(), lesson.getLessonId())))
                .filter(l -> lastApprovedOrPublished == null
                        || (l.getCreatedAt() != null && !l.getCreatedAt().isBefore(lastApprovedOrPublished)))
                .limit(15)
                .map(l -> toView(l, true))
                .toList();

        boolean createdAfterApproval;
        if (lastApprovedOrPublished != null) {
            createdAfterApproval = (lesson.getCreatedAt() != null && !lesson.getCreatedAt().isBefore(lastApprovedOrPublished))
                    || lessonLogViews.stream().anyMatch(l -> "LESSON".equals(l.getEntityType()) && "CREATE".equals(l.getActionType()));
        } else {
            createdAfterApproval = "DRAFT".equalsIgnoreCase(lesson.getStatus());
        }

        boolean updatedAfterApproval = !createdAfterApproval && (!lessonLogViews.isEmpty()
                || (lastApprovedOrPublished != null
                    && lesson.getUpdatedAt() != null
                    && lesson.getUpdatedAt().isAfter(lastApprovedOrPublished)));

        if (createdAfterApproval) {
            // Bài học mới bổ sung ở lần cập nhật thứ 2+: chỉ giữ lại các log chỉnh sửa (nếu có), bỏ qua log CREATE ban đầu để tránh bảng (Trống) dư thừa
            List<CourseChangeLogView> nonCreateLogs = lessonLogViews.stream()
                    .filter(l -> !"CREATE".equals(l.getActionType()) && !"VIDEO_UPLOAD".equals(l.getActionType()))
                    .toList();
            v.setChangeLogs(nonCreateLogs);
            v.setNewlyCreated(true);
            v.setChangeState("NEW");
            v.setLatestChangeSummary("Bài học mới được giảng viên bổ sung trong đợt cập nhật này");
        } else if (updatedAfterApproval) {
            v.setChangeLogs(lessonLogViews);
            v.setRecentlyUpdated(true);
            v.setChangeState("UPDATED");
            v.setLatestChangeSummary(!lessonLogViews.isEmpty() ? lessonLogViews.get(0).getSummary() : "Bài học đã được giảng viên chỉnh sửa nội dung");
        } else {
            v.setChangeLogs(List.of());
            v.setChangeState("PUBLISHED");
        }

        return v;
    }

    // =========================================================================
    // 4. INTERNAL CONVERSION & HELPERS
    // =========================================================================

    private CourseChangeLogView toView(CourseChangeLog log, boolean includeDeepDetails) {
        CourseChangeLogView v = new CourseChangeLogView();
        v.setLogId(log.getLogId());
        v.setCourseId(log.getCourseId());
        v.setCourseTitle(log.getCourseTitle());
        v.setActorId(log.getActorId());
        v.setActorName(log.getActorName());
        v.setActorEmail(log.getActorEmail());
        v.setActorRole(log.getActorRole());
        v.setEntityType(log.getEntityType());
        v.setEntityTypeLabel(formatEntityTypeLabel(log.getEntityType()));
        v.setEntityId(log.getEntityId());
        v.setEntityTitle(log.getEntityTitle());
        v.setParentLessonId(log.getParentLessonId());
        v.setActionType(log.getActionType());
        v.setActionTypeLabel(formatActionTypeLabel(log.getActionType()));
        String cleanSummary = log.getSummary() != null
                ? log.getSummary().replace("→", "->").replace("«", "\"").replace("»", "\"")
                : "";
        v.setSummary(cleanSummary);
        v.setChangedFields(log.getChangedFields());
        v.setBeforeData(log.getBeforeData());
        v.setAfterData(log.getAfterData());
        v.setCreatedAt(log.getCreatedAt());
        v.setFormattedCreatedAt(log.getCreatedAt() != null ? log.getCreatedAt().format(DISPLAY_DT_FMT) : "");

        Map<String, Object> beforeMap = parseJsonMap(log.getBeforeData());
        Map<String, Object> afterMap = parseJsonMap(log.getAfterData());
        v.setBeforeMap(beforeMap);
        v.setAfterMap(afterMap);

        if ("LESSON".equals(log.getEntityType()) && "CREATE".equals(log.getActionType())) {
            AdminLessonReviewView newLesson = buildNewLessonDetail(log, afterMap);
            v.setNewLessonDetail(newLesson);
            v.setLessonTypeLabel(formatLessonTypeLabel(newLesson.getLessonType()));
            v.setFieldDiffs(List.of());
            String niceSummary = "Bài " + (newLesson.getOrderIndex() != null ? newLesson.getOrderIndex() : "mới")
                    + " (Bài học mới): " + newLesson.getTitle()
                    + " — Thể loại: " + v.getLessonTypeLabel();
            v.setSummary(niceSummary);
        } else {
            v.setFieldDiffs(buildFieldDiffs(beforeMap, afterMap));
            if (afterMap.get("lessonType") != null) {
                v.setLessonTypeLabel(formatLessonTypeLabel(asString(afterMap.get("lessonType"))));
            }
        }

        // Trích xuất thông tin Video / File / Lesson content từ snapshot để hiển thị kể cả khi đã xóa
        String afterVideoUrl = asString(afterMap.get("videoUrl"));
        String beforeVideoUrl = asString(beforeMap.get("videoUrl"));
        v.setVideoUrl(afterVideoUrl);
        v.setBunnyVideoId(asString(afterMap.get("bunnyVideoId")));
        v.setOldVideoUrl(beforeVideoUrl);
        v.setOldBunnyVideoId(asString(beforeMap.get("bunnyVideoId")));
        v.setVideoResourceExists(afterVideoUrl != null && checkResourceExists(afterVideoUrl));
        v.setOldVideoResourceExists(beforeVideoUrl != null && checkResourceExists(beforeVideoUrl));

        String afterFileUrl = asString(afterMap.get("fileUrl"));
        String beforeFileUrl = asString(beforeMap.get("fileUrl"));
        v.setFileUrl(afterFileUrl);
        v.setFileName(asString(afterMap.getOrDefault("originalFileName", afterMap.get("title"))));
        v.setFileType(asString(afterMap.get("type")));
        if (afterMap.get("sizeBytes") instanceof Number num) {
            v.setFileSize(num.longValue());
        }
        v.setFileResourceExists(afterFileUrl != null && checkResourceExists(afterFileUrl));

        v.setOldFileUrl(beforeFileUrl);
        v.setOldFileName(asString(beforeMap.getOrDefault("originalFileName", beforeMap.get("title"))));
        v.setOldFileResourceExists(beforeFileUrl != null && checkResourceExists(beforeFileUrl));

        v.setLessonContent(asString(afterMap.get("content")));
        v.setOldLessonContent(asString(beforeMap.get("content")));

        if (includeDeepDetails) {
            populateLiveResourceStatus(log, v);
        }

        return v;
    }

    private void populateLiveResourceStatus(CourseChangeLog log, CourseChangeLogView v) {
        if ("DELETE".equals(log.getActionType()) || "VIDEO_REMOVE".equals(log.getActionType())) {
            v.setResourceExists(false);
            v.setResourceStatusMessage("Đối tượng này đã bị xóa khỏi khóa học. Đang hiển thị bản chụp dữ liệu (snapshot) trước khi xóa.");
            return;
        }

        String type = log.getEntityType();
        Integer entityId = log.getEntityId();
        if ("LESSON".equals(type) || "VIDEO".equals(type)) {
            if (lessonRepository != null && entityId != null) {
                Lesson lesson = lessonRepository.findById(entityId).orElse(null);
                if (lesson == null) {
                    v.setResourceExists(false);
                    v.setResourceStatusMessage("Bài học này đã bị xóa khỏi hệ thống. Đang hiển thị nội dung lưu trong lịch sử.");
                } else {
                    if (v.getVideoUrl() == null && lesson.getVideoUrl() != null) {
                        v.setVideoUrl(lesson.getVideoUrl());
                        v.setBunnyVideoId(lesson.getBunnyVideoId());
                        v.setVideoResourceExists(checkResourceExists(lesson.getVideoUrl()));
                    }
                    if (v.getLessonContent() == null && lesson.getContent() != null) {
                        v.setLessonContent(lesson.getContent());
                    }
                    if ("VIDEO".equals(type) && (lesson.getVideoUrl() == null || lesson.getVideoUrl().isBlank())) {
                        v.setResourceExists(false);
                        v.setResourceStatusMessage("Video của bài học này hiện đã bị gỡ bỏ. Đang hiển thị thông tin lịch sử.");
                    }
                }
            }
        } else if ("DOCUMENT".equals(type)) {
            if (materialRepository != null && entityId != null) {
                Material mat = materialRepository.findById(entityId).orElse(null);
                if (mat == null) {
                    v.setResourceExists(false);
                    v.setResourceStatusMessage("Tài liệu đính kèm này đã bị xóa khỏi bài học. Đang hiển thị thông tin lưu trong lịch sử.");
                } else if (!checkResourceExists(mat.getFileUrl())) {
                    v.setResourceExists(false);
                    v.setFileResourceExists(false);
                    v.setResourceStatusMessage("File vật lý trên máy chủ không còn tồn tại. Đang hiển thị thông tin lưu trong lịch sử.");
                }
            }
        } else if ("CHAPTER".equals(type)) {
            if (sectionRepository != null && entityId != null && sectionRepository.findById(entityId).isEmpty()) {
                v.setResourceExists(false);
                v.setResourceStatusMessage("Chương học này đã bị xóa. Đang hiển thị thông tin lưu trong lịch sử.");
            }
        } else if ("QUIZ".equals(type) || "QUESTION".equals(type)) {
            Integer quizId = "QUIZ".equals(type) ? entityId : null;
            if ("QUESTION".equals(type) && questionRepository != null && entityId != null) {
                Question q = questionRepository.findById(entityId).orElse(null);
                if (q != null && q.getQuiz() != null) {
                    quizId = q.getQuiz().getQuizId();
                } else {
                    v.setResourceExists(false);
                    v.setResourceStatusMessage("Câu hỏi này đã bị xóa khỏi Quiz. Đang hiển thị dữ liệu lịch sử.");
                }
            }
            if (quizId != null && quizRepository != null) {
                Quiz quiz = quizRepository.findById(quizId).orElse(null);
                if (quiz == null) {
                    v.setResourceExists(false);
                    v.setResourceStatusMessage("Bài Quiz này không còn tồn tại.");
                } else if (questionRepository != null) {
                    List<Question> qs = questionRepository.findByQuiz_QuizIdOrderByOrderIndexAsc(quizId);
                    List<Map<String, Object>> qMaps = new ArrayList<>();
                    for (Question q : qs) {
                        Hibernate.initialize(q.getOptions());
                        qMaps.add(snapshotQuestion(q, q.getOptions()));
                    }
                    v.setQuizQuestions(qMaps);
                }
            }
        }
    }

    private AdminLessonReviewView buildNewLessonDetail(CourseChangeLog log, Map<String, Object> afterMap) {
        if (lessonRepository != null && log.getEntityId() != null) {
            Lesson lesson = lessonRepository.findById(log.getEntityId()).orElse(null);
            if (lesson != null) {
                return buildSingleLessonReviewView(lesson, true, null, List.of());
            }
        }
        // Fallback từ snapshot nếu bài học đã bị xóa khỏi DB sau đó
        AdminLessonReviewView v = new AdminLessonReviewView();
        v.setLessonId(log.getEntityId());
        v.setCourseId(log.getCourseId());
        v.setTitle(asString(afterMap.getOrDefault("title", log.getEntityTitle())));
        String rawType = asString(afterMap.getOrDefault("lessonType", "ARTICLE"));
        if ("Video".equalsIgnoreCase(rawType)) rawType = "VIDEO";
        else if ("Quiz".equalsIgnoreCase(rawType)) rawType = "QUIZ";
        else if ("Văn bản".equalsIgnoreCase(rawType)) rawType = "ARTICLE";
        v.setLessonType(rawType != null ? rawType.toUpperCase() : "ARTICLE");
        v.setSectionTitle(asString(afterMap.getOrDefault("sectionTitle", "Chưa phân chương")));
        if (afterMap.get("orderIndex") instanceof Number num) {
            v.setOrderIndex(num.intValue());
        }
        v.setContent(asString(afterMap.get("content")));
        v.setVideoUrl(asString(afterMap.get("videoUrl")));
        v.setBunnyVideoId(asString(afterMap.get("bunnyVideoId")));
        if (afterMap.get("videoDuration") instanceof Number dur) {
            v.setVideoDuration(dur.intValue());
        }
        v.setNewlyCreated(true);
        v.setChangeState("NEW");
        return v;
    }

    private List<CourseChangeLogView.FieldDiffItem> buildFieldDiffs(Map<String, Object> before, Map<String, Object> after) {
        Set<String> allKeys = new LinkedHashSet<>();
        if (before != null) allKeys.addAll(before.keySet());
        if (after != null) allKeys.addAll(after.keySet());
        allKeys.removeAll(Set.of(
                "courseId", "sectionId", "lessonId", "materialId", "quizId", "questionId",
                "status", "versionNo", "videoStatus", "credits", "promoVideoUrl", "changeNote",
                "isPreview", "unlockDaysAfterEnroll", "prerequisiteLesson"
        ));

        // Nếu bài học không phải thể loại Video, loại bỏ các trường cấu hình Video khỏi bảng so sánh
        String lessonType = after != null ? asString(after.get("lessonType")) : (before != null ? asString(before.get("lessonType")) : null);
        if (lessonType != null && !"VIDEO".equalsIgnoreCase(lessonType) && !"Video".equalsIgnoreCase(lessonType)) {
            allKeys.removeAll(Set.of("videoUrl", "bunnyVideoId", "videoDuration", "allowSeek", "quizRequiresVideo", "minWatchPercent"));
        }

        boolean hasBefore = before != null && !before.isEmpty();
        boolean hasAfter = after != null && !after.isEmpty();

        List<CourseChangeLogView.FieldDiffItem> diffs = new ArrayList<>();
        for (String key : allKeys) {
            String bVal = formatValue(before != null ? before.get(key) : null);
            String aVal = formatValue(after != null ? after.get(key) : null);
            if (bVal.isEmpty() && aVal.isEmpty()) continue;
            boolean isChanged = !Objects.equals(bVal, aVal);
            // Khi cập nhật (có cả before và after), chỉ hiển thị "Phần đã chỉnh sửa", ẩn các phần giữ nguyên để đỡ rối mắt
            if (hasBefore && hasAfter && !isChanged) {
                continue;
            }
            String label = FIELD_LABELS.getOrDefault(key, key);
            diffs.add(new CourseChangeLogView.FieldDiffItem(key, label, bVal, aVal, isChanged));
        }
        return diffs;
    }

    private void saveLog(Course course, Users actor, String actorRole,
                         String entityType, Integer entityId, String entityTitle, Integer parentLessonId,
                         String actionType, String summary, String changedFields,
                         Map<String, Object> before, Map<String, Object> after) {
        CourseChangeLog log = new CourseChangeLog();
        log.setCourseId(course.getCourseId());
        log.setCourseTitle(course.getTitle());
        if (actor != null) {
            log.setActorId(actor.getUserId());
            log.setActorName(actor.getFullName());
            log.setActorEmail(actor.getEmail());
        } else {
            log.setActorId(0);
            log.setActorName("Hệ thống");
        }
        log.setActorRole(actorRole != null ? actorRole : "INSTRUCTOR");
        log.setEntityType(entityType);
        log.setEntityId(entityId);
        log.setEntityTitle(truncate(entityTitle, 500));
        log.setParentLessonId(parentLessonId);
        log.setActionType(actionType);
        log.setSummary(truncate(summary, 1000));
        log.setChangedFields(truncate(changedFields, 500));
        log.setBeforeData(toJson(before));
        log.setAfterData(toJson(after));
        log.setCreatedAt(LocalDateTime.now());
        logRepository.save(log);
    }

    private List<String> findChangedKeys(Map<String, Object> before, Map<String, Object> after, Set<String> ignoreKeys) {
        Set<String> keys = new LinkedHashSet<>();
        if (before != null) keys.addAll(before.keySet());
        if (after != null) keys.addAll(after.keySet());
        if (ignoreKeys != null) keys.removeAll(ignoreKeys);

        List<String> changed = new ArrayList<>();
        for (String k : keys) {
            String v1 = formatValue(before != null ? before.get(k) : null);
            String v2 = formatValue(after != null ? after.get(k) : null);
            if (!Objects.equals(v1, v2)) {
                changed.add(k);
            }
        }
        return changed;
    }

    private boolean hasVideoInfo(Lesson lesson) {
        return (lesson.getVideoUrl() != null && !lesson.getVideoUrl().isBlank())
                || (lesson.getBunnyVideoId() != null && !lesson.getBunnyVideoId().isBlank());
    }

    private boolean checkResourceExists(String url) {
        if (url == null || url.isBlank()) return false;
        if (fileUploadService != null) {
            return fileUploadService.resourceExists(url);
        }
        return true;
    }

    private String toJson(Map<String, Object> map) {
        if (map == null || map.isEmpty()) return null;
        try {
            return objectMapper.writeValueAsString(map);
        } catch (Exception e) {
            return null;
        }
    }

    private Map<String, Object> parseJsonMap(String json) {
        if (json == null || json.isBlank()) return new LinkedHashMap<>();
        try {
            return objectMapper.readValue(json, new TypeReference<LinkedHashMap<String, Object>>() {});
        } catch (Exception e) {
            return new LinkedHashMap<>();
        }
    }

    private String formatValue(Object val) {
        if (val == null) return "";
        return String.valueOf(val).trim();
    }

    private String asString(Object val) {
        if (val == null) return null;
        String s = String.valueOf(val).trim();
        return s.isEmpty() ? null : s;
    }

    private String cleanParam(String val) {
        return val == null || val.isBlank() ? null : val.trim();
    }

    private String truncate(String s, int max) {
        if (s == null) return null;
        return s.length() <= max ? s : s.substring(0, max - 1) + "…";
    }

    public static String formatEntityTypeLabel(String type) {
        if (type == null) return "Khác";
        return switch (type.toUpperCase()) {
            case "COURSE" -> "Khóa học";
            case "CHAPTER" -> "Chương học";
            case "LESSON" -> "Bài học";
            case "VIDEO" -> "Video";
            case "DOCUMENT" -> "Tài liệu";
            case "QUIZ" -> "Bài Quiz";
            case "QUESTION" -> "Câu hỏi Quiz";
            default -> type;
        };
    }

    public static String formatActionTypeLabel(String action) {
        if (action == null) return "Thay đổi";
        return switch (action.toUpperCase()) {
            case "CREATE" -> "Tạo mới";
            case "UPDATE" -> "Cập nhật";
            case "DELETE" -> "Xóa";
            case "REORDER" -> "Đổi thứ tự";
            case "STATUS_CHANGE" -> "Đổi trạng thái";
            case "VIDEO_UPLOAD" -> "Tải video mới";
            case "VIDEO_REPLACE" -> "Thay thế video";
            case "VIDEO_REMOVE" -> "Gỡ video";
            default -> action;
        };
    }

    public static String formatCourseLevel(String level) {
        if (level == null || level.isBlank()) return "";
        return switch (level.toUpperCase()) {
            case "BEGINNER" -> "Cơ bản";
            case "INTERMEDIATE" -> "Trung cấp";
            case "ADVANCED" -> "Nâng cao";
            default -> level;
        };
    }

    public static String formatLessonTypeLabel(String type) {
        if (type == null || type.isBlank()) return "Văn bản";
        return switch (type.toUpperCase()) {
            case "VIDEO" -> "Video";
            case "QUIZ" -> "Quiz";
            case "ARTICLE", "TEXT", "VĂN BẢN" -> "Văn bản";
            default -> type;
        };
    }
}
