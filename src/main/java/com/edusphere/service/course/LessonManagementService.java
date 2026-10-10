package com.edusphere.service.course;

import com.edusphere.dto.course.LessonForm;
import com.edusphere.dto.course.MaterialForm;
import com.edusphere.entity.course.Course;
import com.edusphere.entity.course.Lesson;
import com.edusphere.entity.course.Material;
import com.edusphere.repository.account.UserRepository;
import com.edusphere.repository.course.CourseRepository;
import com.edusphere.repository.course.EnrollmentRepository;
import com.edusphere.repository.course.LessonRepository;
import com.edusphere.repository.course.MaterialRepository;
import jakarta.persistence.EntityManager;
import java.net.URI;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Set;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class LessonManagementService {
    private static final Set<String> EDITABLE_COURSES = Set.of("DRAFT", "REJECTED", "APPROVED", "PUBLISHED");
    private final CourseRepository courses;
    private final LessonRepository lessons;
    private final MaterialRepository materials;
    private final EnrollmentRepository enrollments;
    private final UserRepository users;
    private final EntityManager entityManager;

    public LessonManagementService(CourseRepository courses, LessonRepository lessons,
                                   MaterialRepository materials, EnrollmentRepository enrollments,
                                   UserRepository users,
                                   EntityManager entityManager) {
        this.courses = courses;
        this.lessons = lessons;
        this.materials = materials;
        this.enrollments = enrollments;
        this.users = users;
        this.entityManager = entityManager;
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
        return lessons.findByCourse_CourseIdOrderByOrderIndexAsc(courseId);
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
        return lessons.findByLessonIdAndCourse_CourseId(lessonId, courseId)
                .orElseThrow(() -> notFound("Không tìm thấy bài học."));
    }

    @Transactional(readOnly = true)
    public List<Material> materials(Integer courseId, Integer lessonId, Integer instructorId) {
        lesson(courseId, lessonId, instructorId);
        return materials.findByLesson_LessonIdOrderByOrderIndexAsc(lessonId);
    }

    @Transactional
    public Integer create(Integer courseId, Integer instructorId, LessonForm form) {
        Course course = editableCourse(courseId, instructorId);
        Lesson lesson = new Lesson();
        lesson.setCourse(course);
        lesson.setTitle(requiredTitle(form.getTitle()));
        lesson.setContent(trimmed(form.getContent()));
        lesson.setOrderIndex(Math.toIntExact(lessons.countByCourse_CourseId(courseId) + 1));
        lesson.setStatus("PUBLISHED".equals(course.getStatus()) ? "PUBLISHED" : "DRAFT");
        lesson.setCreatedAt(LocalDateTime.now());
        Integer lessonId = lessons.save(lesson).getLessonId();
        if ("PUBLISHED".equals(lesson.getStatus())) {
            enrollments.findByCourse_CourseIdAndStatus(courseId, "COMPLETED").forEach(enrollment -> {
                enrollment.setStatus("ACTIVE");
                enrollment.setCompletedAt(null);
            });
        }
        return lessonId;
    }

    @Transactional
    public void edit(Integer courseId, Integer lessonId, Integer instructorId, LessonForm form) {
        Course course = editableCourse(courseId, instructorId);
        Lesson lesson = lessons.findByLessonIdAndCourse_CourseId(lessonId, courseId)
                .orElseThrow(() -> notFound("Không tìm thấy bài học."));
        List<Lesson> ordered = lessons.findByCourse_CourseIdOrderByOrderIndexAsc(courseId);
        int newOrder = form.getOrderIndex() == null ? lesson.getOrderIndex() : form.getOrderIndex();
        if (newOrder < 1 || newOrder > ordered.size()) throw conflict("Vị trí bài học không hợp lệ.");
        if (newOrder != lesson.getOrderIndex()) move(lesson, ordered, newOrder);
        lesson.setTitle(requiredTitle(form.getTitle()));
        lesson.setContent(trimmed(form.getContent()));
        lesson.setStatus("PUBLISHED".equals(course.getStatus()) ? "PUBLISHED" : "DRAFT");
        lesson.setUpdatedAt(LocalDateTime.now());
    }

    @Transactional
    public void addMaterial(Integer courseId, Integer lessonId, Integer instructorId, MaterialForm form) {
        editableCourse(courseId, instructorId);
        Lesson lesson = lessons.findByLessonIdAndCourse_CourseId(lessonId, courseId)
                .orElseThrow(() -> notFound("Không tìm thấy bài học."));
        String url = trimmed(form.getFileUrl());
        if (url == null || url.length() > 2048 || !validHttpUrl(url))
            throw conflict("Đường dẫn tài liệu phải là URL http hoặc https hợp lệ.");
        String type = form.getType();
        if (type == null || !Set.of("DOCUMENT", "LINK", "VIDEO").contains(type))
            throw conflict("Loại tài liệu không hợp lệ.");
        Material material = new Material();
        material.setLesson(lesson);
        material.setTitle(requiredTitle(form.getTitle()));
        material.setType(type);
        material.setFileUrl(url);
        material.setOrderIndex(materials.findByLesson_LessonIdOrderByOrderIndexAsc(lessonId).size() + 1);
        material.setUploadedBy(users.getReferenceById(instructorId));
        materials.save(material);
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
