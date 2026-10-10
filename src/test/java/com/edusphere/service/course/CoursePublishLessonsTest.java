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
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

class CoursePublishLessonsTest {
    @Test
    void publishingApprovedCoursePublishesDraftLessons() {
        CourseRepository courses = mock(CourseRepository.class);
        LessonRepository lessons = mock(LessonRepository.class);
        Users instructor = new Users();
        instructor.setUserId(3);
        Course course = new Course();
        course.setCourseId(12);
        course.setInstructor(instructor);
        course.setStatus("APPROVED");
        course.setApprovedAt(LocalDateTime.now());
        Lesson lesson = new Lesson();
        lesson.setStatus("DRAFT");
        when(courses.findLockedById(12)).thenReturn(Optional.of(course));
        when(lessons.findByCourse_CourseIdAndStatusOrderByOrderIndexAsc(12, "DRAFT"))
                .thenReturn(List.of(lesson));
        CourseManagementService service = new CourseManagementService(courses,
                mock(CourseReviewRepository.class), mock(EnrollmentRepository.class),
                mock(CategoryRepository.class), mock(UserRepository.class), lessons);

        service.publish(12, 3);

        assertEquals("PUBLISHED", course.getStatus());
        assertEquals("PUBLISHED", lesson.getStatus());
    }
}
