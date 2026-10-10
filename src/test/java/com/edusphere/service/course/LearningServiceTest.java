package com.edusphere.service.course;

import com.edusphere.entity.account.Users;
import com.edusphere.entity.course.Course;
import com.edusphere.entity.course.Enrollment;
import com.edusphere.entity.course.Lesson;
import com.edusphere.repository.account.UserRepository;
import com.edusphere.repository.course.EnrollmentRepository;
import com.edusphere.repository.course.LessonCompletionRepository;
import com.edusphere.repository.course.LessonRepository;
import com.edusphere.repository.course.MaterialRepository;
import java.util.List;
import java.util.Optional;
import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

class LearningServiceTest {
    @Test
    void onlyEnrolledStudentCanOpenLesson() {
        EnrollmentRepository enrollments = mock(EnrollmentRepository.class);
        when(enrollments.findByStudent_UserIdAndCourse_CourseId(7, 12)).thenReturn(Optional.empty());
        LearningService service = new LearningService(mock(LessonRepository.class),
                enrollments, mock(LessonCompletionRepository.class), mock(MaterialRepository.class),
                mock(UserRepository.class));
        assertThrows(CourseActionException.class, () -> service.getStudyContext(12, null, 7));
    }

    @Test
    void publishedLessonAppearsInStudyContext() {
        EnrollmentRepository enrollments = mock(EnrollmentRepository.class);
        LessonRepository lessons = mock(LessonRepository.class);
        LessonCompletionRepository completions = mock(LessonCompletionRepository.class);
        MaterialRepository materials = mock(MaterialRepository.class);
        Users instructor = new Users();
        instructor.setFullName("Giảng viên");
        Course course = new Course();
        course.setCourseId(12);
        course.setTitle("Java");
        course.setInstructor(instructor);
        Enrollment enrollment = new Enrollment();
        enrollment.setCourse(course);
        enrollment.setStatus("ACTIVE");
        when(enrollments.findByStudent_UserIdAndCourse_CourseId(7, 12)).thenReturn(Optional.of(enrollment));
        Lesson lesson = new Lesson();
        lesson.setLessonId(31);
        lesson.setTitle("Bài đầu");
        lesson.setOrderIndex(1);
        lesson.setContent("Nội dung học");
        when(lessons.findByCourse_CourseIdAndStatusOrderByOrderIndexAsc(12, "PUBLISHED"))
                .thenReturn(List.of(lesson));
        when(completions.findByStudent_UserIdAndCourse_CourseId(7, 12)).thenReturn(List.of());
        when(materials.findByLesson_LessonIdOrderByOrderIndexAsc(31)).thenReturn(List.of());
        LearningService service = new LearningService(lessons,
                enrollments, completions, materials, mock(UserRepository.class));

        var context = service.getStudyContext(12, null, 7);

        assertEquals("Nội dung học", context.lessonContent());
        assertEquals(31, context.currentLesson().lessonId());
        assertEquals(1, context.totalCount());
    }
}
