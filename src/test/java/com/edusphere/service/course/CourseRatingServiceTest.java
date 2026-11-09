package com.edusphere.service.course;

import com.edusphere.dto.course.CourseRatingSummaryView;
import com.edusphere.entity.account.Users;
import com.edusphere.entity.course.Course;
import com.edusphere.entity.course.CourseRating;
import com.edusphere.entity.course.Enrollment;
import com.edusphere.repository.account.UserRepository;
import com.edusphere.repository.course.CourseRatingRepository;
import com.edusphere.repository.course.CourseRepository;
import com.edusphere.repository.course.EnrollmentRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class CourseRatingServiceTest {

    @Mock
    private CourseRatingRepository courseRatingRepository;

    @Mock
    private CourseRepository courseRepository;

    @Mock
    private EnrollmentRepository enrollmentRepository;

    @Mock
    private UserRepository usersRepository;

    private CourseRatingService courseRatingService;

    @BeforeEach
    void setUp() {
        courseRatingService = new CourseRatingService(
                courseRatingRepository, courseRepository, enrollmentRepository, usersRepository);
    }

    @Test
    void submitOrUpdateRating_createsNewRatingWhenStudentEnrolled() {
        Users instructor = new Users(10);
        instructor.setFullName("Giảng viên A");
        Course course = new Course();
        course.setCourseId(100);
        course.setInstructor(instructor);

        Users student = new Users(20);
        student.setFullName("Học viên B");

        Enrollment enrollment = new Enrollment();
        enrollment.setStatus("ACTIVE");

        when(courseRepository.findById(100)).thenReturn(Optional.of(course));
        when(enrollmentRepository.findByStudent_UserIdAndCourse_CourseId(20, 100))
                .thenReturn(Optional.of(enrollment));
        when(usersRepository.findById(20)).thenReturn(Optional.of(student));
        when(courseRatingRepository.findByCourse_CourseIdAndStudent_UserId(100, 20))
                .thenReturn(Optional.empty());

        courseRatingService.submitOrUpdateRating(100, 20, 5, "Khóa học rất dễ hiểu!");

        verify(courseRatingRepository).save(argThat(r ->
                r.getRating() == 5 && "Khóa học rất dễ hiểu!".equals(r.getComment())
        ));
    }

    @Test
    void submitOrUpdateRating_rejectsNonEnrolledUser() {
        Users instructor = new Users(10);
        Course course = new Course();
        course.setCourseId(100);
        course.setInstructor(instructor);

        when(courseRepository.findById(100)).thenReturn(Optional.of(course));
        when(enrollmentRepository.findByStudent_UserIdAndCourse_CourseId(30, 100))
                .thenReturn(Optional.empty());

        assertThrows(CourseActionException.class,
                () -> courseRatingService.submitOrUpdateRating(100, 30, 4, "Test"));
    }

    @Test
    void getRatingSummary_computesAverageAndDistributionCorrectly() {
        Users instructor = new Users(10);
        Course course = new Course();
        course.setCourseId(100);
        course.setInstructor(instructor);

        Users s1 = new Users(20);
        s1.setFullName("An");
        CourseRating r1 = new CourseRating();
        r1.setRatingId(1);
        r1.setCourse(course);
        r1.setStudent(s1);
        r1.setRating(5);
        r1.setComment("Rất tốt");
        r1.setCreatedAt(LocalDateTime.now());

        Users s2 = new Users(21);
        s2.setFullName("Bình");
        CourseRating r2 = new CourseRating();
        r2.setRatingId(2);
        r2.setCourse(course);
        r2.setStudent(s2);
        r2.setRating(4);
        r2.setComment("Khá hay");
        r2.setCreatedAt(LocalDateTime.now());

        Enrollment enrollment = new Enrollment();
        enrollment.setStatus("ACTIVE");

        when(courseRepository.findById(100)).thenReturn(Optional.of(course));
        when(courseRatingRepository.findByCourseIdWithStudentOrderByCreatedAtDesc(100))
                .thenReturn(List.of(r1, r2));
        when(enrollmentRepository.findByStudent_UserIdAndCourse_CourseId(20, 100))
                .thenReturn(Optional.of(enrollment));

        CourseRatingSummaryView summary = courseRatingService.getRatingSummary(100, 20, false);

        assertEquals(4.5, summary.getAverageRating());
        assertEquals(2L, summary.getTotalRatings());
        assertTrue(summary.isCanRate());
        assertNotNull(summary.getMyRating());
        assertEquals(5, summary.getMyRating().getRating());
    }
}
