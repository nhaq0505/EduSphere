package com.edusphere.service;

import com.edusphere.entity.Course;
import com.edusphere.entity.Enrollment;
import com.edusphere.entity.Users;
import com.edusphere.repository.CategoryRepository;
import com.edusphere.repository.CourseRepository;
import com.edusphere.repository.CourseReviewRepository;
import com.edusphere.repository.EnrollmentRepository;
import com.edusphere.repository.UserRepository;
import java.math.BigDecimal;
import java.util.Optional;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;
import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

class CourseEnrollmentTest {
    @Test
    void paidPublishedCourseCanBeEnrolledWithoutPayment() {
        CourseRepository courses = mock(CourseRepository.class);
        EnrollmentRepository enrollments = mock(EnrollmentRepository.class);
        UserRepository users = mock(UserRepository.class);
        Course course = new Course();
        course.setCourseId(42);
        course.setStatus("PUBLISHED");
        course.setPrice(new BigDecimal("199000"));
        when(courses.findLockedById(42)).thenReturn(Optional.of(course));
        Users student = new Users();
        student.setUserId(7);
        when(users.findById(7)).thenReturn(Optional.of(student));
        when(enrollments.findByStudent_UserIdAndCourse_CourseId(7, 42)).thenReturn(Optional.empty());
        CourseManagementService service = new CourseManagementService(courses,
                mock(CourseReviewRepository.class), enrollments, mock(CategoryRepository.class), users);

        service.enroll(42, 7);

        ArgumentCaptor<Enrollment> saved = ArgumentCaptor.forClass(Enrollment.class);
        verify(enrollments).save(saved.capture());
        assertEquals(42, saved.getValue().getCourse().getCourseId());
        assertEquals(7, saved.getValue().getStudent().getUserId());
        assertNull(saved.getValue().getPaymentId());
    }

    @Test
    void unpublishedCourseCannotBeEnrolled() {
        CourseRepository courses = mock(CourseRepository.class);
        EnrollmentRepository enrollments = mock(EnrollmentRepository.class);
        Course draft = new Course();
        draft.setStatus("DRAFT");
        when(courses.findLockedById(42)).thenReturn(Optional.of(draft));
        CourseManagementService service = new CourseManagementService(courses,
                mock(CourseReviewRepository.class), enrollments,
                mock(CategoryRepository.class), mock(UserRepository.class));

        assertThrows(CourseActionException.class, () -> service.enroll(42, 7));
        verifyNoInteractions(enrollments);
    }
}
