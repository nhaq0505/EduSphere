package com.edusphere.service.course;

import com.edusphere.entity.account.Users;
import com.edusphere.entity.course.Course;
import com.edusphere.entity.course.Lesson;
import com.edusphere.repository.account.UserRepository;
import com.edusphere.repository.course.CategoryRepository;
import com.edusphere.repository.course.CourseRepository;
import com.edusphere.repository.course.CourseReviewRepository;
import com.edusphere.repository.course.EnrollmentRepository;
import com.edusphere.repository.course.LessonRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.time.LocalDateTime;
import java.util.Collections;
import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

class CourseWorkflowTest {

    private CourseRepository courses;
    private LessonRepository lessons;
    private CourseManagementService service;
    private Users instructor;
    private Course course;

    @BeforeEach
    void setUp() {
        courses = mock(CourseRepository.class);
        lessons = mock(LessonRepository.class);
        service = new CourseManagementService(
                courses,
                mock(CourseReviewRepository.class),
                mock(EnrollmentRepository.class),
                mock(CategoryRepository.class),
                mock(UserRepository.class),
                lessons
        );

        instructor = new Users();
        instructor.setUserId(10);

        course = new Course();
        course.setCourseId(100);
        course.setInstructor(instructor);
        course.setStatus("DRAFT");
        course.setDescription("Mô tả chi tiết khóa học EduSphere");

        when(courses.findLockedById(100)).thenReturn(Optional.of(course));
        when(courses.findById(100)).thenReturn(Optional.of(course));
    }

    @Test
    void submitFailsWhenNoLessons() {
        when(lessons.findByCourse_CourseIdOrderByOrderIndexAsc(100)).thenReturn(Collections.emptyList());

        CourseActionException ex = assertThrows(CourseActionException.class, () -> service.submit(100, 10));
        assertTrue(ex.getMessage().contains("ít nhất một bài học"));
        assertEquals("DRAFT", course.getStatus());
    }

    @Test
    void submitFailsWhenLessonHasNoContent() {
        Lesson lesson = new Lesson();
        lesson.setLessonId(1);
        lesson.setTitle("Bài 1");
        lesson.setContent("   "); // empty content

        when(lessons.findByCourse_CourseIdOrderByOrderIndexAsc(100)).thenReturn(List.of(lesson));

        CourseActionException ex = assertThrows(CourseActionException.class, () -> service.submit(100, 10));
        assertTrue(ex.getMessage().contains("nội dung hoàn chỉnh"));
        assertEquals("DRAFT", course.getStatus());
    }

    @Test
    void submitSucceedsWhenComplete() {
        Lesson lesson = new Lesson();
        lesson.setLessonId(1);
        lesson.setTitle("Bài 1: Giới thiệu");
        lesson.setContent("Nội dung bài học đầy đủ và chi tiết.");

        when(lessons.findByCourse_CourseIdOrderByOrderIndexAsc(100)).thenReturn(List.of(lesson));

        service.submit(100, 10);

        assertEquals("SUBMITTED", course.getStatus());
        assertNotNull(course.getSubmittedAt());
    }

    @Test
    void hidePublishedCourseSetsStatusToApproved() {
        course.setStatus("PUBLISHED");
        course.setApprovedAt(LocalDateTime.now().minusDays(1));
        course.setPublishedAt(LocalDateTime.now().minusHours(2));

        service.hide(100, 10);

        assertEquals("APPROVED", course.getStatus());
        assertNotNull(course.getPublishedAt()); // preserves previous published date
    }

    @Test
    void hideFailsWhenCourseNotPublished() {
        course.setStatus("DRAFT");

        CourseActionException ex = assertThrows(CourseActionException.class, () -> service.hide(100, 10));
        assertTrue(ex.getMessage().contains("Chỉ có thể ẩn khóa học đang được công bố"));
    }

    @Test
    void republishHiddenCourseSucceeds() {
        course.setStatus("APPROVED");
        course.setApprovedAt(LocalDateTime.now().minusDays(1));
        course.setPublishedAt(LocalDateTime.now().minusHours(2));

        when(lessons.findByCourse_CourseIdAndStatusOrderByOrderIndexAsc(100, "DRAFT"))
                .thenReturn(Collections.emptyList());

        service.publish(100, 10);

        assertEquals("PUBLISHED", course.getStatus());
    }

    @Test
    void editingPublishedCourseCreatesDraftNewVersion() {
        course.setStatus("PUBLISHED");
        course.setVersionNo(1);
        course.setApprovedAt(LocalDateTime.now().minusDays(2));
        course.setPublishedAt(LocalDateTime.now().minusDays(1));

        com.edusphere.dto.course.CourseForm form = new com.edusphere.dto.course.CourseForm();
        form.setTitle("Java Nâng Cao v2");
        form.setDescription("Mô tả mới");
        form.setLevel("ADVANCED");
        form.setPrice(java.math.BigDecimal.valueOf(200000));

        service.edit(100, 10, form);

        assertEquals("UPDATING", course.getStatus());
        assertEquals(2, course.getVersionNo());
        assertEquals("Java Nâng Cao v2", course.getTitle());
        assertNotNull(course.getApprovedAt());
        assertNotNull(course.getPublishedAt());
        assertNull(course.getSubmittedAt());
    }

    @Test
    void editingApprovedCourseCreatesDraftNewVersion() {
        course.setStatus("APPROVED");
        course.setVersionNo(1);
        course.setApprovedAt(LocalDateTime.now().minusDays(1));

        com.edusphere.dto.course.CourseForm form = new com.edusphere.dto.course.CourseForm();
        form.setTitle("Java Cơ Bản Sửa Đổi");
        form.setDescription("Mô tả đã sửa");
        form.setLevel("BEGINNER");
        form.setPrice(java.math.BigDecimal.ZERO);

        service.edit(100, 10, form);

        assertEquals("UPDATING", course.getStatus());
        assertEquals(2, course.getVersionNo());
        assertEquals("Java Cơ Bản Sửa Đổi", course.getTitle());
    }

    @Test
    void editingSubmittedCourseFails() {
        course.setStatus("SUBMITTED");

        com.edusphere.dto.course.CourseForm form = new com.edusphere.dto.course.CourseForm();
        form.setTitle("Tên mới");

        CourseActionException ex = assertThrows(CourseActionException.class, () -> service.edit(100, 10, form));
        assertTrue(ex.getMessage().contains("chờ duyệt"));
        assertEquals("SUBMITTED", course.getStatus());
    }
}
