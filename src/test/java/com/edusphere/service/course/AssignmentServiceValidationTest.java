package com.edusphere.service.course;

import com.edusphere.dto.assignment.AssignmentForm;
import com.edusphere.dto.assignment.SubmissionForm;
import com.edusphere.dto.planning.PersonalTaskView;
import com.edusphere.entity.account.Users;
import com.edusphere.entity.course.Assignment;
import com.edusphere.entity.course.Course;
import com.edusphere.entity.course.Enrollment;
import com.edusphere.entity.course.Submission;
import com.edusphere.repository.account.UserRepository;
import com.edusphere.repository.course.AssignmentRepository;
import com.edusphere.repository.course.CourseRepository;
import com.edusphere.repository.course.EnrollmentRepository;
import com.edusphere.repository.course.GradeRepository;
import com.edusphere.repository.course.LessonRepository;
import com.edusphere.repository.course.SubmissionRepository;
import jakarta.validation.Validation;
import jakarta.validation.Validator;
import jakarta.validation.ValidatorFactory;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

class AssignmentServiceValidationTest {

    private AssignmentRepository assignments;
    private SubmissionRepository submissions;
    private GradeRepository grades;
    private CourseRepository courses;
    private LessonRepository lessons;
    private EnrollmentRepository enrollments;
    private UserRepository users;

    private AssignmentService service;
    private Users instructor;
    private Course course;
    private Validator validator;

    @BeforeEach
    void setUp() {
        assignments = mock(AssignmentRepository.class);
        submissions = mock(SubmissionRepository.class);
        grades = mock(GradeRepository.class);
        courses = mock(CourseRepository.class);
        lessons = mock(LessonRepository.class);
        enrollments = mock(EnrollmentRepository.class);
        users = mock(UserRepository.class);

        service = new AssignmentService(assignments, submissions, grades, courses, lessons, enrollments, users);

        instructor = new Users();
        instructor.setUserId(1);

        course = new Course();
        course.setCourseId(10);
        course.setInstructor(instructor);

        when(courses.findById(10)).thenReturn(Optional.of(course));
        when(users.findById(1)).thenReturn(Optional.of(instructor));

        ValidatorFactory factory = Validation.buildDefaultValidatorFactory();
        validator = factory.getValidator();
    }

    @Test
    @DisplayName("Tạo bài tập thất bại khi hạn nộp trống")
    void createAssignment_throwsWhenDueDateMissing() {
        AssignmentForm form = new AssignmentForm();
        form.setTitle("Bài tập 1");
        form.setDueDate("");

        CourseActionException ex = assertThrows(CourseActionException.class,
                () -> service.create(10, 1, form));
        assertTrue(ex.getMessage().contains("Hạn nộp bài không được để trống"));
    }

    @Test
    @DisplayName("Tạo bài tập thất bại khi unlockAt > dueDate (vi phạm CK_assignments_dates)")
    void createAssignment_throwsWhenUnlockAfterDue() {
        AssignmentForm form = new AssignmentForm();
        form.setTitle("Bài tập 1");
        form.setDueDate("2026-11-10T10:00");
        form.setUnlockAt("2026-11-10T11:00"); // unlock sau due date

        CourseActionException ex = assertThrows(CourseActionException.class,
                () -> service.create(10, 1, form));
        assertTrue(ex.getMessage().contains("Thời điểm mở khóa (unlockAt) phải trước hoặc cùng hạn nộp"));
    }

    @Test
    @DisplayName("Tạo bài tập thất bại khi lockAt < dueDate (vi phạm CK_assignments_dates)")
    void createAssignment_throwsWhenLockBeforeDue() {
        AssignmentForm form = new AssignmentForm();
        form.setTitle("Bài tập 1");
        form.setDueDate("2026-11-10T10:00");
        form.setLockAt("2026-11-10T09:00"); // lock trước due date

        CourseActionException ex = assertThrows(CourseActionException.class,
                () -> service.create(10, 1, form));
        assertTrue(ex.getMessage().contains("Thời điểm khóa (lockAt) phải sau hoặc cùng hạn nộp"));
    }

    @Test
    @DisplayName("Chuẩn hóa allowResubmit và maxAttempts tuân thủ CK_assignments_attempts")
    void createAssignment_enforcesAttemptsConstraints() {
        // Trường hợp 1: allowResubmit = false -> maxAttempts ép về 1
        AssignmentForm form1 = new AssignmentForm();
        form1.setTitle("Bài tập 1");
        form1.setDueDate("2026-11-10T10:00");
        form1.setAllowResubmit(false);
        form1.setMaxAttempts(5); // nhập 5 nhưng không cho nộp lại

        when(assignments.save(any(Assignment.class))).thenAnswer(inv -> {
            Assignment a = inv.getArgument(0);
            a.setAssignmentId(101);
            return a;
        });

        service.create(10, 1, form1);

        ArgumentCaptor<Assignment> captor = ArgumentCaptor.forClass(Assignment.class);
        verify(assignments).save(captor.capture());
        Assignment saved1 = captor.getValue();
        assertFalse(saved1.isAllowResubmit());
        assertEquals(1, saved1.getMaxAttempts());

        // Trường hợp 2: allowResubmit = true và maxAttempts < 2 -> ép về tối thiểu 2
        reset(assignments);
        AssignmentForm form2 = new AssignmentForm();
        form2.setTitle("Bài tập 2");
        form2.setDueDate("2026-11-10T10:00");
        form2.setAllowResubmit(true);
        form2.setMaxAttempts(1);

        when(assignments.save(any(Assignment.class))).thenAnswer(inv -> {
            Assignment a = inv.getArgument(0);
            a.setAssignmentId(102);
            return a;
        });

        service.create(10, 1, form2);

        verify(assignments).save(captor.capture());
        Assignment saved2 = captor.getValue();
        assertTrue(saved2.isAllowResubmit());
        assertEquals(2, saved2.getMaxAttempts());
    }

    @Test
    @DisplayName("Nộp bài bị từ chối khi chưa đến thời gian mở khóa (unlockAt)")
    void submit_rejectsWhenBeforeUnlockAt() {
        Users student = new Users();
        student.setUserId(2);

        Enrollment enrollment = new Enrollment();
        enrollment.setStatus("ACTIVE");
        when(enrollments.findByStudent_UserIdAndCourse_CourseId(2, 10)).thenReturn(Optional.of(enrollment));

        Assignment assignment = new Assignment();
        assignment.setAssignmentId(50);
        assignment.setCourse(course);
        assignment.setStatus("PUBLISHED");
        assignment.setDueDate(LocalDateTime.now().plusDays(2));
        assignment.setUnlockAt(LocalDateTime.now().plusHours(5)); // Chưa mở khóa
        assignment.setMaxAttempts(1);

        when(assignments.findByAssignmentIdAndCourse_CourseId(50, 10)).thenReturn(Optional.of(assignment));

        SubmissionForm form = new SubmissionForm();
        form.setAnswerText("Bài làm nộp sớm");

        CourseActionException ex = assertThrows(CourseActionException.class,
                () -> service.submit(10, 50, 2, form));
        assertTrue(ex.getMessage().contains("Bài tập chưa đến thời gian mở khóa"));
    }

    @Test
    @DisplayName("Bean Validation kiểm tra các ràng buộc trên AssignmentForm")
    void assignmentForm_beanValidation() {
        AssignmentForm invalidForm = new AssignmentForm();
        invalidForm.setTitle("");
        invalidForm.setDueDate("");
        invalidForm.setMaxScore(BigDecimal.ZERO); // phải > 0
        invalidForm.setAllowResubmit(true);
        invalidForm.setMaxAttempts(1); // allowResubmit = true nhưng attempts = 1

        var violations = validator.validate(invalidForm);
        assertFalse(violations.isEmpty());
        assertTrue(violations.stream().anyMatch(v -> v.getPropertyPath().toString().equals("title")));
        assertTrue(violations.stream().anyMatch(v -> v.getPropertyPath().toString().equals("dueDate")));
        assertTrue(violations.stream().anyMatch(v -> v.getPropertyPath().toString().equals("maxScore")));
        assertTrue(violations.stream().anyMatch(v -> v.getMessage().contains("số lần nộp tối đa phải từ 2 trở lên")));
    }

    @Test
    @DisplayName("PersonalTaskView định dạng thời gian HH:mm chính xác")
    void personalTaskView_formattedTimes() {
        LocalDateTime start = LocalDateTime.of(2026, 11, 5, 8, 30, 0);
        LocalDateTime end = LocalDateTime.of(2026, 11, 5, 10, 15, 0);

        PersonalTaskView view = PersonalTaskView.builder()
                .taskId(1)
                .title("Làm bài tập")
                .plannedStartAt(start)
                .plannedEndAt(end)
                .status("TODO")
                .build();

        assertEquals("08:30", view.getFormattedStartTime());
        assertEquals("10:15", view.getFormattedEndTime());
        assertEquals("2026-11-05T08:30", view.getFormattedStartIso());
    }
}
