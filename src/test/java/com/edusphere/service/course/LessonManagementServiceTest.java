package com.edusphere.service.course;

import com.edusphere.dto.course.LessonForm;
import com.edusphere.dto.course.MaterialForm;
import com.edusphere.entity.account.Users;
import com.edusphere.entity.course.Course;
import com.edusphere.entity.course.Enrollment;
import com.edusphere.entity.course.Lesson;
import com.edusphere.repository.account.UserRepository;
import com.edusphere.repository.course.CourseRepository;
import com.edusphere.repository.course.EnrollmentRepository;
import com.edusphere.repository.course.LessonRepository;
import com.edusphere.repository.course.MaterialRepository;
import jakarta.persistence.EntityManager;
import java.util.Optional;
import java.util.List;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

class LessonManagementServiceTest {
    private CourseRepository courses;
    private LessonRepository lessons;
    private MaterialRepository materials;
    private EnrollmentRepository enrollments;
    private LessonManagementService service;
    private Course course;

    @BeforeEach
    void setUp() {
        courses = mock(CourseRepository.class);
        lessons = mock(LessonRepository.class);
        materials = mock(MaterialRepository.class);
        enrollments = mock(EnrollmentRepository.class);
        service = new LessonManagementService(courses, lessons, materials, enrollments,
                mock(UserRepository.class), mock(EntityManager.class));
        Users owner = new Users();
        owner.setUserId(3);
        course = new Course();
        course.setCourseId(12);
        course.setInstructor(owner);
        course.setStatus("PUBLISHED");
        when(courses.findLockedById(12)).thenReturn(Optional.of(course));
    }

    @Test
    void newLessonInPublishedCourseRevertsCourseToDraftAndIncrementsVersion() {
        course.setVersionNo(1);
        course.setApprovedAt(java.time.LocalDateTime.now().minusDays(1));
        course.setPublishedAt(java.time.LocalDateTime.now().minusHours(5));

        LessonForm form = new LessonForm();
        form.setTitle("  Bài đầu tiên  ");
        when(lessons.countByCourse_CourseId(12)).thenReturn(0L);
        when(lessons.save(any(Lesson.class))).thenAnswer(call -> {
            Lesson saved = call.getArgument(0);
            saved.setLessonId(31);
            return saved;
        });

        assertEquals(31, service.create(12, 3, form));

        var captor = org.mockito.ArgumentCaptor.forClass(Lesson.class);
        verify(lessons).save(captor.capture());
        assertEquals("Bài đầu tiên", captor.getValue().getTitle());
        assertEquals("DRAFT", captor.getValue().getStatus());
        assertEquals(1, captor.getValue().getOrderIndex());

        // Verify course bumped to UPDATING v2
        assertEquals("UPDATING", course.getStatus());
        assertEquals(2, course.getVersionNo());
        assertNotNull(course.getApprovedAt());
        assertNotNull(course.getPublishedAt());
    }

    @Test
    void editLessonInPublishedCourseRevertsCourseToDraftAndIncrementsVersion() {
        course.setVersionNo(1);
        course.setApprovedAt(java.time.LocalDateTime.now().minusDays(1));
        course.setPublishedAt(java.time.LocalDateTime.now().minusHours(5));

        Lesson lesson = new Lesson();
        lesson.setLessonId(31);
        lesson.setCourse(course);
        lesson.setTitle("Tiêu đề cũ");
        lesson.setContent("Nội dung cũ");
        lesson.setOrderIndex(1);
        lesson.setStatus("PUBLISHED");

        when(lessons.findByLessonIdAndCourse_CourseId(31, 12)).thenReturn(Optional.of(lesson));
        when(lessons.findByCourse_CourseIdOrderByOrderIndexAsc(12)).thenReturn(List.of(lesson));

        LessonForm form = new LessonForm();
        form.setTitle("Tiêu đề mới");
        form.setContent("Nội dung mới");
        form.setOrderIndex(1);

        service.edit(12, 31, 3, form);

        assertEquals("Tiêu đề mới", lesson.getTitle());
        assertEquals("Nội dung mới", lesson.getContent());
        assertEquals("PUBLISHED", lesson.getStatus());

        assertEquals("UPDATING", course.getStatus());
        assertEquals(2, course.getVersionNo());
        assertNotNull(course.getApprovedAt());
        assertNotNull(course.getPublishedAt());
    }

    @Test
    void newLessonInDraftCourseKeepsDraftWithoutVersionBump() {
        course.setStatus("DRAFT");
        course.setVersionNo(1);

        LessonForm form = new LessonForm();
        form.setTitle("Bài nháp");
        when(lessons.countByCourse_CourseId(12)).thenReturn(0L);
        when(lessons.save(any(Lesson.class))).thenAnswer(call -> {
            Lesson saved = call.getArgument(0);
            saved.setLessonId(32);
            return saved;
        });

        assertEquals(32, service.create(12, 3, form));

        assertEquals("DRAFT", course.getStatus());
        assertEquals(1, course.getVersionNo());
    }

    @Test
    void otherInstructorCannotAddLesson() {
        LessonForm form = new LessonForm();
        form.setTitle("Bài thử");
        assertThrows(CourseActionException.class, () -> service.create(12, 9, form));
        verifyNoInteractions(lessons);
    }

    @Test
    void materialUrlMustBeHttpOrHttps() {
        Lesson lesson = new Lesson();
        lesson.setCourse(course);
        when(lessons.findByLessonIdAndCourse_CourseId(31, 12)).thenReturn(Optional.of(lesson));
        MaterialForm form = new MaterialForm();
        form.setTitle("Liên kết");
        form.setType("LINK");
        form.setFileUrl("javascript:alert(1)");

        assertThrows(CourseActionException.class, () -> service.addMaterial(12, 31, 3, form));
        verifyNoInteractions(materials);
    }
}
