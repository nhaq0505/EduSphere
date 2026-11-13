package com.edusphere.service.course;

import com.edusphere.dto.course.LessonForm;
import com.edusphere.dto.course.MaterialForm;
import com.edusphere.entity.course.Assignment;
import com.edusphere.entity.course.Course;
import com.edusphere.entity.course.CourseSection;
import com.edusphere.entity.course.Lesson;
import com.edusphere.entity.course.Material;
import com.edusphere.entity.course.PersonalTask;
import com.edusphere.entity.course.Quiz;
import com.edusphere.repository.account.UserRepository;
import com.edusphere.repository.course.AssignmentRepository;
import com.edusphere.repository.course.CourseRepository;
import com.edusphere.repository.course.CourseSectionRepository;
import com.edusphere.repository.course.EnrollmentRepository;
import com.edusphere.repository.course.LearningHistoryRepository;
import com.edusphere.repository.course.LessonCompletionRepository;
import com.edusphere.repository.course.LessonRepository;
import com.edusphere.repository.course.MaterialRepository;
import com.edusphere.repository.course.PersonalTaskRepository;
import com.edusphere.repository.course.QuizRepository;
import jakarta.persistence.EntityManager;
import java.net.URI;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Objects;
import java.util.Set;
import org.hibernate.Hibernate;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class LessonManagementService {
    private static final Set<String> EDITABLE_COURSES = Set.of("DRAFT", "REJECTED", "APPROVED", "PUBLISHED", "UPDATING");
    private static final Set<String> VALID_LESSON_TYPES = Set.of("ARTICLE", "VIDEO", "QUIZ", "ASSIGNMENT");

    private final CourseRepository courses;
    private final LessonRepository lessons;
    private final MaterialRepository materials;
    private final EnrollmentRepository enrollments;
    private final UserRepository users;
    private final EntityManager entityManager;
    private final CourseSectionRepository sections;
    private final QuizRepository quizzes;
    private final AssignmentRepository assignments;
    private final LessonCompletionRepository lessonCompletions;
    private final LearningHistoryRepository learningHistories;
    private final PersonalTaskRepository personalTasks;

    @Autowired(required = false)
    private CourseChangeLogService changeLogService;

    public void setChangeLogService(CourseChangeLogService changeLogService) {
        this.changeLogService = changeLogService;
    }

    public LessonManagementService(CourseRepository courses, LessonRepository lessons,
                                   MaterialRepository materials, EnrollmentRepository enrollments,
                                   UserRepository users,
                                   EntityManager entityManager) {
        this(courses, lessons, materials, enrollments, users, entityManager, null, null, null, null, null, null);
    }

    public LessonManagementService(CourseRepository courses, LessonRepository lessons,
                                   MaterialRepository materials, EnrollmentRepository enrollments,
                                   UserRepository users,
                                   EntityManager entityManager,
                                   CourseSectionRepository sections) {
        this(courses, lessons, materials, enrollments, users, entityManager, sections, null, null, null, null, null);
    }

    @Autowired
    public LessonManagementService(CourseRepository courses, LessonRepository lessons,
                                   MaterialRepository materials, EnrollmentRepository enrollments,
                                   UserRepository users,
                                   EntityManager entityManager,
                                   CourseSectionRepository sections,
                                   QuizRepository quizzes,
                                   AssignmentRepository assignments,
                                   LessonCompletionRepository lessonCompletions,
                                   LearningHistoryRepository learningHistories,
                                   PersonalTaskRepository personalTasks) {
        this.courses = courses;
        this.lessons = lessons;
        this.materials = materials;
        this.enrollments = enrollments;
        this.users = users;
        this.entityManager = entityManager;
        this.sections = sections;
        this.quizzes = quizzes;
        this.assignments = assignments;
        this.lessonCompletions = lessonCompletions;
        this.learningHistories = learningHistories;
        this.personalTasks = personalTasks;
    }

    @Transactional(readOnly = true)
    public Course ownedCourse(Integer courseId, Integer instructorId) {
        Course course = courses.findById(courseId).orElseThrow(() -> notFound("Không tìm thấy khóa học."));
        if (!course.getInstructor().getUserId().equals(instructorId)) throw notFound("Không tìm thấy khóa học của bạn.");
        return course;
    }

    @Transactional(readOnly = true)
    public List<Lesson> lessons(Integer courseId, Integer instructorId) {
        ownedCourse(courseId, instructorId);
        List<Lesson> result = lessons.findByCourse_CourseIdOrderByOrderIndexAsc(courseId);
        // Initialize lazy associations while session is still open
        result.forEach(l -> {
            Hibernate.initialize(l.getSection());
            Hibernate.initialize(l.getPrerequisiteLesson());
        });
        return result;
    }

    @Transactional(readOnly = true)
    public Course editableForDisplay(Integer courseId, Integer instructorId) {
        Course course = ownedCourse(courseId, instructorId);
        if (!EDITABLE_COURSES.contains(course.getStatus()))
            throw conflict("Không thể sửa bài học khi khóa đang chờ duyệt hoặc đã lưu trữ.");
        return course;
    }

    @Transactional(readOnly = true)
    public Lesson lesson(Integer courseId, Integer lessonId, Integer instructorId) {
        ownedCourse(courseId, instructorId);
        Lesson lesson = lessons.findByLessonIdAndCourse_CourseId(lessonId, courseId)
                .orElseThrow(() -> notFound("Không tìm thấy bài học."));
        // Initialize lazy associations while session is still open
        Hibernate.initialize(lesson.getSection());
        Hibernate.initialize(lesson.getPrerequisiteLesson());
        return lesson;
    }

    @Transactional(readOnly = true)
    public List<Material> materials(Integer courseId, Integer lessonId, Integer instructorId) {
        lesson(courseId, lessonId, instructorId);
        return materials.findByLesson_LessonIdOrderByOrderIndexAsc(lessonId);
    }

    @Transactional
    public Integer create(Integer courseId, Integer instructorId, LessonForm form) {
        Course course = editableCourse(courseId, instructorId);
        bumpCourseToDraftIfPublishedOrApproved(course);
        Lesson lesson = new Lesson();
        lesson.setCourse(course);
        applyLessonForm(lesson, form, courseId);
        List<Lesson> existing = lessons.findByCourse_CourseIdOrderByOrderIndexAsc(courseId);
        int maxOrder = existing.stream().mapToInt(Lesson::getOrderIndex).max().orElse(0);
        lesson.setOrderIndex(maxOrder + 1);
        lesson.setStatus("DRAFT");
        lesson.setCreatedAt(LocalDateTime.now());
        lesson = lessons.save(lesson);

        if (changeLogService != null) {
            changeLogService.recordLessonCreate(course, lesson);
        }

        // Lưu tài liệu đính kèm nếu có
        saveAttachedMaterial(course, lesson, instructorId, form);

        return lesson.getLessonId();
    }

    @Transactional
    public void edit(Integer courseId, Integer lessonId, Integer instructorId, LessonForm form) {
        Course course = editableCourse(courseId, instructorId);
        Lesson lesson = lessons.findByLessonIdAndCourse_CourseId(lessonId, courseId)
                .orElseThrow(() -> notFound("Không tìm thấy bài học."));
        var beforeLesson = changeLogService != null ? changeLogService.snapshotLesson(lesson) : null;
        var beforeVideo = changeLogService != null ? changeLogService.snapshotVideo(lesson) : null;

        List<Lesson> ordered = lessons.findByCourse_CourseIdOrderByOrderIndexAsc(courseId);
        int newOrder = form.getOrderIndex() == null ? lesson.getOrderIndex() : form.getOrderIndex();
        if (newOrder < 1 || newOrder > ordered.size()) throw conflict("Vị trí bài học không hợp lệ.");
        if (newOrder != lesson.getOrderIndex()) move(lesson, ordered, newOrder);

        applyLessonForm(lesson, form, courseId);
        bumpCourseToDraftIfPublishedOrApproved(course);
        if (!"PUBLISHED".equals(lesson.getStatus())) {
            lesson.setStatus("DRAFT");
        }
        lesson.setUpdatedAt(LocalDateTime.now());
        lessons.save(lesson);

        if (changeLogService != null) {
            changeLogService.recordLessonUpdate(
                    course, lesson,
                    beforeLesson, changeLogService.snapshotLesson(lesson),
                    beforeVideo, changeLogService.snapshotVideo(lesson));
        }

        // Lưu tài liệu đính kèm nếu có
        saveAttachedMaterial(course, lesson, instructorId, form);
    }

    @Transactional
    public void deleteLesson(Integer courseId, Integer lessonId, Integer instructorId) {
        Course course = editableCourse(courseId, instructorId);
        Lesson lesson = lessons.findByLessonIdAndCourse_CourseId(lessonId, courseId)
                .orElseThrow(() -> notFound("Không tìm thấy bài học."));
        var beforeLessonSnapshot = changeLogService != null ? changeLogService.snapshotLesson(lesson) : null;

        // Unlink prerequisiteLesson references
        List<Lesson> prereqDeps = lessons.findByPrerequisiteLesson_LessonId(lessonId);
        if (prereqDeps != null) {
            for (Lesson dep : prereqDeps) {
                dep.setPrerequisiteLesson(null);
                lessons.save(dep);
            }
        }
        List<Lesson> courseLessons = lessons.findByCourse_CourseIdOrderByOrderIndexAsc(courseId);
        if (courseLessons != null) {
            for (Lesson dep : courseLessons) {
                if (dep.getPrerequisiteLesson() != null
                        && Objects.equals(dep.getPrerequisiteLesson().getLessonId(), lessonId)) {
                    dep.setPrerequisiteLesson(null);
                    lessons.save(dep);
                }
            }
        }

        // Unlink Quiz references
        if (quizzes != null) {
            List<Quiz> linkedQuizzes = quizzes.findByLesson_LessonId(lessonId);
            if (linkedQuizzes != null) {
                for (Quiz q : linkedQuizzes) {
                    q.setLesson(null);
                    quizzes.save(q);
                }
            }
        }

        // Unlink Assignment references
        if (assignments != null) {
            List<Assignment> linkedAssignments = assignments.findByLesson_LessonId(lessonId);
            if (linkedAssignments != null) {
                for (Assignment a : linkedAssignments) {
                    a.setLesson(null);
                    assignments.save(a);
                }
            }
        }

        // Delete LessonCompletion, LearningHistory, and unlink PersonalTask references
        if (lessonCompletions != null) {
            lessonCompletions.deleteByLesson_LessonId(lessonId);
        }
        if (learningHistories != null) {
            learningHistories.deleteByLesson_LessonId(lessonId);
        }
        if (personalTasks != null) {
            List<PersonalTask> linkedTasks = personalTasks.findByRelatedLesson_LessonId(lessonId);
            if (linkedTasks != null) {
                for (PersonalTask t : linkedTasks) {
                    t.setRelatedLesson(null);
                    personalTasks.save(t);
                }
            }
        }

        // Delete associated materials
        materials.deleteByLesson_LessonId(lessonId);

        // Delete lesson
        lessons.delete(lesson);
        lessons.flush();

        // Re-index remaining lessons
        List<Lesson> remaining = lessons.findByCourse_CourseIdOrderByOrderIndexAsc(courseId);
        for (int i = 0; i < remaining.size(); i++) {
            remaining.get(i).setOrderIndex(10000 + (i + 1));
        }
        lessons.saveAllAndFlush(remaining);
        for (int i = 0; i < remaining.size(); i++) {
            remaining.get(i).setOrderIndex(i + 1);
        }
        lessons.saveAllAndFlush(remaining);

        bumpCourseToDraftIfPublishedOrApproved(course);
        if (changeLogService != null) {
            changeLogService.recordLessonDelete(course, lesson, beforeLessonSnapshot);
        }
    }

    @Transactional
    public void addMaterial(Integer courseId, Integer lessonId, Integer instructorId, MaterialForm form) {
        Course course = editableCourse(courseId, instructorId);
        Lesson lesson = lessons.findByLessonIdAndCourse_CourseId(lessonId, courseId)
                .orElseThrow(() -> notFound("Không tìm thấy bài học."));
        String url = trimmed(form.getFileUrl());
        if (url == null || url.length() > 2048 || !validHttpUrl(url))
            throw conflict("Đường dẫn tài liệu phải là URL http, https hợp lệ hoặc tệp tải lên từ hệ thống.");
        String type = form.getType();
        if (type == null || type.isBlank()) {
            type = "DOCUMENT";
        }
        if (!Set.of("DOCUMENT", "LINK", "VIDEO").contains(type))
            throw conflict("Loại tài liệu không hợp lệ.");
        // Tài liệu đính kèm là nội dung bổ sung — không cần bump course sang UPDATING/DRAFT
        // Học viên thấy tài liệu ngay lập tức mà không cần qua luồng duyệt lại
        lesson.setUpdatedAt(LocalDateTime.now());
        Material material = new Material();
        material.setLesson(lesson);
        material.setTitle(requiredTitle(form.getTitle()));
        material.setType(type);
        material.setFileUrl(url);
        List<Material> existing = materials.findByLesson_LessonIdOrderByOrderIndexAsc(lessonId);
        int maxOrder = existing.stream().mapToInt(Material::getOrderIndex).max().orElse(0);
        material.setOrderIndex(maxOrder + 1);
        material.setUploadedBy(users.getReferenceById(instructorId));
        Material saved = materials.save(material);
        if (changeLogService != null) {
            changeLogService.recordMaterialCreate(course, lesson, saved);
        }
    }

    @Transactional
    public void updateMaterial(Integer courseId, Integer lessonId, Integer materialId, Integer instructorId, MaterialForm form) {
        Course course = editableCourse(courseId, instructorId);
        Lesson lesson = lessons.findByLessonIdAndCourse_CourseId(lessonId, courseId)
                .orElseThrow(() -> notFound("Không tìm thấy bài học."));
        Material material = materials.findById(materialId)
                .orElseThrow(() -> notFound("Không tìm thấy tài liệu."));
        if (material.getLesson() == null || !material.getLesson().getLessonId().equals(lessonId)) {
            throw notFound("Không tìm thấy tài liệu.");
        }
        String url = trimmed(form.getFileUrl());
        if (url == null || url.length() > 2048 || !validHttpUrl(url))
            throw conflict("Đường dẫn tài liệu phải là URL http, https hợp lệ hoặc tệp tải lên từ hệ thống.");
        String type = form.getType();
        if (type == null || type.isBlank()) {
            type = "DOCUMENT";
        }
        if (!Set.of("DOCUMENT", "LINK", "VIDEO").contains(type))
            throw conflict("Loại tài liệu không hợp lệ.");

        var beforeMat = changeLogService != null ? changeLogService.snapshotMaterial(material) : null;
        material.setTitle(requiredTitle(form.getTitle()));
        material.setType(type);
        material.setFileUrl(url);
        Material saved = materials.save(material);
        lesson.setUpdatedAt(LocalDateTime.now());
        if (changeLogService != null) {
            changeLogService.recordMaterialUpdate(course, lesson, saved, beforeMat, changeLogService.snapshotMaterial(saved));
        }
    }

    @Transactional
    public void deleteMaterial(Integer courseId, Integer lessonId, Integer materialId, Integer instructorId) {
        Course course = ownedCourse(courseId, instructorId);
        Lesson lesson = lesson(courseId, lessonId, instructorId);
        Material material = materials.findById(materialId)
                .orElseThrow(() -> notFound("Không tìm thấy tài liệu."));
        if (material.getLesson() == null
                || !material.getLesson().getLessonId().equals(lessonId)
                || material.getLesson().getCourse() == null
                || !material.getLesson().getCourse().getCourseId().equals(courseId)) {
            throw notFound("Không tìm thấy tài liệu.");
        }
        var beforeMatSnapshot = changeLogService != null ? changeLogService.snapshotMaterial(material) : null;
        // Xóa tài liệu đính kèm — không cần bump course status
        materials.delete(material);
        materials.flush();

        // Re-index remaining materials
        List<Material> remaining = materials.findByLesson_LessonIdOrderByOrderIndexAsc(lessonId);
        for (int i = 0; i < remaining.size(); i++) {
            remaining.get(i).setOrderIndex(10000 + (i + 1));
        }
        materials.saveAllAndFlush(remaining);
        for (int i = 0; i < remaining.size(); i++) {
            remaining.get(i).setOrderIndex(i + 1);
        }
        materials.saveAllAndFlush(remaining);
        if (changeLogService != null) {
            changeLogService.recordMaterialDelete(course, lesson, beforeMatSnapshot);
        }
    }

    private void saveAttachedMaterial(Course course, Lesson lesson, Integer instructorId, LessonForm form) {
        String url = trimmed(form.getMaterialUrl());
        if (url == null || url.isBlank()) {
            return;
        }
        String title = trimmed(form.getMaterialTitle());
        if (title == null || title.isBlank()) {
            title = form.getMaterialOriginalName() != null && !form.getMaterialOriginalName().isBlank()
                    ? form.getMaterialOriginalName().trim()
                    : "Tài liệu bài học";
        }
        String type = form.getMaterialType();
        if (type == null || !Set.of("DOCUMENT", "LINK", "VIDEO").contains(type)) {
            type = "DOCUMENT";
        }
        Material material = new Material();
        material.setLesson(lesson);
        material.setTitle(title);
        material.setType(type);
        material.setFileUrl(url);
        if (form.getMaterialOriginalName() != null && !form.getMaterialOriginalName().isBlank()) {
            material.setOriginalFileName(form.getMaterialOriginalName().trim());
        }
        if (form.getMaterialSizeBytes() != null) {
            material.setSizeBytes(form.getMaterialSizeBytes());
        }
        int currentOrder = materials.findByLesson_LessonIdOrderByOrderIndexAsc(lesson.getLessonId()).size();
        material.setOrderIndex(currentOrder + 1);
        material.setUploadedBy(users.getReferenceById(instructorId));
        Material saved = materials.save(material);
        if (changeLogService != null) {
            changeLogService.recordMaterialCreate(course, lesson, saved);
        }
    }

    private void applyLessonForm(Lesson lesson, LessonForm form, Integer courseId) {
        lesson.setTitle(requiredTitle(form.getTitle()));
        lesson.setContent(trimmed(form.getContent()));

        // Section binding
        if (form.getSectionId() != null && sections != null) {
            CourseSection section = sections.findBySectionIdAndCourse_CourseId(form.getSectionId(), courseId).orElse(null);
            lesson.setSection(section);
        } else {
            lesson.setSection(null);
        }

        // Lesson Type & Video info
        String type = form.getLessonType() != null ? form.getLessonType().trim().toUpperCase() : "ARTICLE";
        if (!VALID_LESSON_TYPES.contains(type)) {
            type = "ARTICLE";
        }
        lesson.setLessonType(type);
        String videoUrl = trimmed(form.getVideoUrl());
        lesson.setVideoUrl(videoUrl);
        if (videoUrl != null && videoUrl.contains("player.mediadelivery.net/embed/")) {
            int lastSlash = videoUrl.lastIndexOf('/');
            if (lastSlash >= 0 && lastSlash < videoUrl.length() - 1) {
                String extractedGuid = videoUrl.substring(lastSlash + 1).trim();
                int qIdx = extractedGuid.indexOf('?');
                if (qIdx > 0) extractedGuid = extractedGuid.substring(0, qIdx);
                if (!extractedGuid.isEmpty() && !Objects.equals(lesson.getBunnyVideoId(), extractedGuid)) {
                    lesson.setBunnyVideoId(extractedGuid);
                    if (lesson.getVideoStatus() == null || "NONE".equalsIgnoreCase(lesson.getVideoStatus())) {
                        lesson.setVideoStatus("PROCESSING");
                    }
                }
            }
        } else if (videoUrl != null) {
            lesson.setBunnyVideoId(null);
            lesson.setVideoStatus("READY");
        } else {
            lesson.setBunnyVideoId(null);
            lesson.setVideoStatus("NONE");
        }
        lesson.setVideoDuration(form.getVideoDuration());
        boolean quizReqVideo = Boolean.TRUE.equals(form.getQuizRequiresVideo());
        boolean allowSeek = form.getAllowSeek() != null ? form.getAllowSeek() : !quizReqVideo;
        if (quizReqVideo && allowSeek) {
            allowSeek = false;
        }
        lesson.setAllowSeek(allowSeek);
        lesson.setQuizRequiresVideo(quizReqVideo);
        int minPct = form.getMinWatchPercent() != null ? form.getMinWatchPercent() : 0;
        lesson.setMinWatchPercent(Math.max(0, Math.min(100, minPct)));
    }

    private void bumpCourseToDraftIfPublishedOrApproved(Course course) {
        String status = course.getStatus();
        if ("PUBLISHED".equals(status)) {
            // Khóa học đang công bố → chuyển sang UPDATING để học viên vẫn học được bài cũ
            course.setVersionNo((course.getVersionNo() == null ? 1 : course.getVersionNo()) + 1);
            course.setStatus("UPDATING");
            course.setSubmittedAt(null);
            course.setUpdatedAt(LocalDateTime.now());
            // Giữ nguyên approvedAt và publishedAt để biết lần publish gần nhất
        } else if ("APPROVED".equals(status)) {
            // Đã duyệt nhưng chưa publish → reset về DRAFT bình thường
            course.setVersionNo((course.getVersionNo() == null ? 1 : course.getVersionNo()) + 1);
            course.setStatus("DRAFT");
            course.setApprovedAt(null);
            course.setPublishedAt(null);
            course.setSubmittedAt(null);
            course.setUpdatedAt(LocalDateTime.now());
        } else if ("UPDATING".equals(status)) {
            // Đang cập nhật → tăng version nhưng giữ trạng thái
            course.setVersionNo((course.getVersionNo() == null ? 1 : course.getVersionNo()) + 1);
            course.setSubmittedAt(null);
            course.setUpdatedAt(LocalDateTime.now());
        }
        // DRAFT, REJECTED → không thay đổi
    }

    private Course editableCourse(Integer courseId, Integer instructorId) {
        Course course = courses.findLockedById(courseId).orElseThrow(() -> notFound("Không tìm thấy khóa học."));
        if (!course.getInstructor().getUserId().equals(instructorId)) throw notFound("Không tìm thấy khóa học của bạn.");
        if (!EDITABLE_COURSES.contains(course.getStatus()))
            throw conflict("Không thể sửa bài học khi khóa đang chờ duyệt hoặc đã lưu trữ.");
        return course;
    }

    private void move(Lesson moving, List<Lesson> ordered, int destination) {
        int old = moving.getOrderIndex();
        moving.setOrderIndex(ordered.size() + 1);
        entityManager.flush();
        if (destination < old) {
            for (int i = old - 1; i >= destination; i--) {
                ordered.get(i - 1).setOrderIndex(i + 1);
                entityManager.flush();
            }
        } else {
            for (int i = old + 1; i <= destination; i++) {
                ordered.get(i - 1).setOrderIndex(i - 1);
                entityManager.flush();
            }
        }
        moving.setOrderIndex(destination);
        entityManager.flush();
    }

    private boolean validHttpUrl(String value) {
        if (value == null || value.isBlank()) return false;
        if (value.startsWith("/") && !value.contains("..")) return true;
        try {
            URI uri = URI.create(value);
            return Set.of("http", "https").contains(uri.getScheme() == null ? "" : uri.getScheme().toLowerCase())
                    && uri.getHost() != null && uri.getUserInfo() == null;
        } catch (IllegalArgumentException ex) {
            return false;
        }
    }

    private String requiredTitle(String title) {
        if (title == null || title.isBlank() || title.trim().length() > 255) throw conflict("Tên tối đa 255 ký tự và không được để trống.");
        return title.trim();
    }

    private String trimmed(String value) {
        return value == null || value.isBlank() ? null : value.trim();
    }

    private CourseActionException notFound(String message) { return new CourseActionException(HttpStatus.NOT_FOUND, message); }
    private CourseActionException conflict(String message) { return new CourseActionException(HttpStatus.CONFLICT, message); }
}
