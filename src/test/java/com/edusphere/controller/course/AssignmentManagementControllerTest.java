package com.edusphere.controller.course;

import com.edusphere.dto.assignment.AssignmentForm;
import com.edusphere.dto.assignment.AssignmentView;
import com.edusphere.dto.assignment.GradeForm;
import com.edusphere.entity.account.Users;
import com.edusphere.entity.course.Assignment;
import com.edusphere.entity.course.Lesson;
import com.edusphere.entity.course.Submission;
import com.edusphere.repository.course.LessonRepository;
import com.edusphere.security.CustomUserDetails;
import com.edusphere.service.course.AssignmentService;
import com.edusphere.service.course.CourseActionException;
import jakarta.servlet.http.HttpServletResponse;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.http.HttpStatus;
import org.springframework.ui.ConcurrentModel;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.servlet.mvc.support.RedirectAttributesModelMap;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.Collections;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

class AssignmentManagementControllerTest {

    private AssignmentService service;
    private LessonRepository lessonRepository;
    private AssignmentManagementController controller;
    private CustomUserDetails user;

    @BeforeEach
    void setUp() {
        service = mock(AssignmentService.class);
        lessonRepository = mock(LessonRepository.class);
        controller = new AssignmentManagementController(service, lessonRepository);

        Users u = new Users();
        u.setUserId(1);
        u.setEmail("instructor@edusphere.com");
        u.setStatus("ACTIVE");
        user = new CustomUserDetails(u);
    }

    @Test
    @DisplayName("GET /instructor/courses/{courseId}/assignments trả về view assignments/instructor-list")
    void list_returnsInstructorListView() {
        Model model = new ConcurrentModel();
        when(service.listForCourse(10, 1)).thenReturn(Collections.emptyList());

        String view = controller.list(10, user, model);

        assertEquals("assignments/instructor-list", view);
        assertEquals(10, model.getAttribute("courseId"));
        assertNotNull(model.getAttribute("assignments"));
    }

    @Test
    @DisplayName("GET /instructor/courses/{courseId}/assignments/new trả về view assignments/form với formAction đúng")
    void newForm_returnsFormView() {
        Model model = new ConcurrentModel();
        when(lessonRepository.findByCourse_CourseIdOrderByOrderIndexAsc(10)).thenReturn(Collections.emptyList());

        String view = controller.newForm(10, 5, user, model);

        assertEquals("assignments/form", view);
        assertEquals(10, model.getAttribute("courseId"));
        assertEquals("Tạo bài tập mới", model.getAttribute("pageTitle"));
        assertEquals("/instructor/courses/10/assignments", model.getAttribute("formAction"));
        AssignmentForm form = (AssignmentForm) model.getAttribute("assignmentForm");
        assertNotNull(form);
        assertEquals(5, form.getLessonId());
    }

    @Test
    @DisplayName("POST /instructor/courses/{courseId}/assignments thành công redirect về danh sách")
    void create_successRedirects() {
        AssignmentForm form = new AssignmentForm();
        form.setTitle("Bài tập mới");
        form.setDueDate("2026-11-15T23:59");
        BindingResult errors = mock(BindingResult.class);
        when(errors.hasErrors()).thenReturn(false);
        Model model = new ConcurrentModel();
        RedirectAttributesModelMap flash = new RedirectAttributesModelMap();

        when(service.create(10, 1, form)).thenReturn(101);

        String view = controller.create(10, form, errors, user, model, flash);

        assertEquals("redirect:/instructor/courses/10/assignments", view);
        assertTrue(flash.getFlashAttributes().containsKey("success"));
        verify(service).create(10, 1, form);
    }

    @Test
    @DisplayName("POST /instructor/courses/{courseId}/assignments có lỗi validation quay lại view form")
    void create_hasErrorsReturnsForm() {
        AssignmentForm form = new AssignmentForm();
        BindingResult errors = mock(BindingResult.class);
        when(errors.hasErrors()).thenReturn(true);
        Model model = new ConcurrentModel();
        RedirectAttributesModelMap flash = new RedirectAttributesModelMap();

        String view = controller.create(10, form, errors, user, model, flash);

        assertEquals("assignments/form", view);
        verify(service, never()).create(anyInt(), anyInt(), any());
    }

    @Test
    @DisplayName("GET /instructor/courses/{courseId}/assignments/{id}/edit trả về form chỉnh sửa")
    void editForm_populatesExistingAssignment() {
        Assignment a = new Assignment();
        a.setAssignmentId(55);
        a.setTitle("Bài tập lập trình");
        a.setMaxScore(BigDecimal.valueOf(100));
        a.setDueDate(LocalDateTime.of(2026, 11, 20, 23, 59));
        Lesson l = new Lesson();
        l.setLessonId(7);
        a.setLesson(l);

        when(service.getAssignmentForInstructor(10, 55, 1)).thenReturn(a);
        when(lessonRepository.findByCourse_CourseIdOrderByOrderIndexAsc(10)).thenReturn(Collections.emptyList());

        Model model = new ConcurrentModel();
        String view = controller.editForm(10, 55, user, model);

        assertEquals("assignments/form", view);
        assertEquals(10, model.getAttribute("courseId"));
        assertEquals(55, model.getAttribute("assignmentId"));
        assertEquals("/instructor/courses/10/assignments/55", model.getAttribute("formAction"));
        AssignmentForm form = (AssignmentForm) model.getAttribute("assignmentForm");
        assertNotNull(form);
        assertEquals("Bài tập lập trình", form.getTitle());
        assertEquals("2026-11-20T23:59", form.getDueDate());
        assertEquals(7, form.getLessonId());
    }

    @Test
    @DisplayName("POST /instructor/courses/{courseId}/assignments/{id} cập nhật thành công")
    void update_successRedirects() {
        AssignmentForm form = new AssignmentForm();
        form.setTitle("Cập nhật bài tập");
        BindingResult errors = mock(BindingResult.class);
        when(errors.hasErrors()).thenReturn(false);
        Model model = new ConcurrentModel();
        RedirectAttributesModelMap flash = new RedirectAttributesModelMap();

        String view = controller.update(10, 55, form, errors, user, model, flash);

        assertEquals("redirect:/instructor/courses/10/assignments", view);
        verify(service).update(10, 55, 1, form);
    }

    @Test
    @DisplayName("POST publish và archive bài tập")
    void publishAndArchive_success() {
        RedirectAttributesModelMap flash = new RedirectAttributesModelMap();

        String publishView = controller.publish(10, 55, user, flash);
        assertEquals("redirect:/instructor/courses/10/assignments", publishView);
        verify(service).publish(10, 55, 1);

        String archiveView = controller.archive(10, 55, user, flash);
        assertEquals("redirect:/instructor/courses/10/assignments", archiveView);
        verify(service).archive(10, 55, 1);
    }

    @Test
    @DisplayName("GET submissions trả về view assignments/submissions")
    void submissions_returnsSubmissionsView() {
        Assignment a = new Assignment();
        a.setAssignmentId(55);
        when(service.getAssignmentForInstructor(10, 55, 1)).thenReturn(a);
        when(service.listSubmissions(10, 55, 1)).thenReturn(Collections.emptyList());

        Model model = new ConcurrentModel();
        String view = controller.submissions(10, 55, user, model);

        assertEquals("assignments/submissions", view);
        assertEquals(a, model.getAttribute("assignment"));
        assertEquals(10, model.getAttribute("courseId"));
        assertEquals(55, model.getAttribute("assignmentId"));
    }

    @Test
    @DisplayName("GET và POST grade form")
    void gradeFlow_success() {
        Assignment a = new Assignment();
        a.setAssignmentId(55);
        Submission sub = new Submission();
        sub.setSubmissionId(77);

        when(service.getAssignmentForInstructor(10, 55, 1)).thenReturn(a);
        when(service.getSubmission(10, 55, 77, 1)).thenReturn(sub);

        Model model = new ConcurrentModel();
        String gradeFormView = controller.gradeForm(10, 55, 77, user, model);
        assertEquals("assignments/grade-form", gradeFormView);

        GradeForm form = new GradeForm();
        form.setScore(BigDecimal.valueOf(9.5));
        form.setFeedback("Làm rất tốt!");
        BindingResult errors = mock(BindingResult.class);
        RedirectAttributesModelMap flash = new RedirectAttributesModelMap();

        String gradePostView = controller.grade(10, 55, 77, form, errors, user, flash);
        assertEquals("redirect:/instructor/courses/10/assignments/55/submissions/77/grade", gradePostView);
        verify(service).gradeSubmission(10, 55, 77, 1, form);

        String publishGradeView = controller.publishGrade(10, 55, 77, user, flash);
        assertEquals("redirect:/instructor/courses/10/assignments/55/submissions/77/grade", publishGradeView);
        verify(service).publishGrade(10, 55, 77, 1);
    }

    @Test
    @DisplayName("ExceptionHandler xử lý CourseActionException")
    void handleError_setsStatusAndErrorMessage() {
        HttpServletResponse response = mock(HttpServletResponse.class);
        Model model = new ConcurrentModel();
        CourseActionException ex = new CourseActionException(HttpStatus.BAD_REQUEST, "Thời điểm mở khóa không hợp lệ.");

        String view = controller.handleError(ex, response, model);

        assertEquals("courses/action-error", view);
        verify(response).setStatus(400);
        assertEquals("Thời điểm mở khóa không hợp lệ.", model.getAttribute("errorMessage"));
    }
}
