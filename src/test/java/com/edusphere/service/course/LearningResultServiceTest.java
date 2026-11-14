package com.edusphere.service.course;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertNull;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.edusphere.dto.result.ResultRow;
import com.edusphere.dto.result.StudentResultsView;
import com.edusphere.entity.account.Users;
import com.edusphere.entity.course.Assignment;
import com.edusphere.entity.course.Course;
import com.edusphere.entity.course.Enrollment;
import com.edusphere.entity.course.Grade;
import com.edusphere.entity.course.Quiz;
import com.edusphere.entity.course.QuizAttempt;
import com.edusphere.entity.course.Submission;
import com.edusphere.repository.course.CourseRepository;
import com.edusphere.repository.course.EnrollmentRepository;
import com.edusphere.repository.course.GradeRepository;
import com.edusphere.repository.course.QuizAttemptRepository;
import com.edusphere.repository.course.SubmissionRepository;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.Optional;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.http.HttpStatus;

/**
 * Unit tests kiểm thử UC32 (Publish Learning Results) và UC33 (View Learning Results).
 */
class LearningResultServiceTest {

  private CourseRepository courses;
  private EnrollmentRepository enrollments;
  private SubmissionRepository submissions;
  private GradeRepository grades;
  private QuizAttemptRepository attempts;
  private AssignmentService assignmentService;
  private QuizService quizService;
  private LearningResultService service;

  @BeforeEach
  void setUp() {
    courses = mock(CourseRepository.class);
    enrollments = mock(EnrollmentRepository.class);
    submissions = mock(SubmissionRepository.class);
    grades = mock(GradeRepository.class);
    attempts = mock(QuizAttemptRepository.class);
    assignmentService = mock(AssignmentService.class);
    quizService = mock(QuizService.class);

    service = new LearningResultService(
        courses,
        enrollments,
        submissions,
        grades,
        attempts,
        assignmentService,
        quizService);
  }

  @Test
  void instructorOverview_returnsSortedRowsAndPublishesReadyOnes() {
    Users instructor = new Users();
    instructor.setUserId(10);

    Course course = new Course();
    course.setCourseId(100);
    course.setTitle("Spring Security Chuyên Sâu");
    course.setInstructor(instructor);

    Users student = new Users();
    student.setUserId(25);
    student.setFullName("Trần Minh Quân");

    Assignment assignment = new Assignment();
    assignment.setAssignmentId(50);
    assignment.setTitle("Bài tập JWT Filter");
    assignment.setMaxScore(BigDecimal.valueOf(10));

    Submission sub = new Submission();
    sub.setSubmissionId(500);
    sub.setAssignment(assignment);
    sub.setCourse(course);
    sub.setStudent(student);
    sub.setAttemptNumber(1);
    sub.setSubmittedAt(LocalDateTime.of(2026, 11, 10, 9, 0));

    Grade grade = new Grade();
    grade.setSubmission(sub);
    grade.setScore(BigDecimal.valueOf(8.5));
    grade.setMaxScore(BigDecimal.valueOf(10));
    grade.setFeedback("Code sạch, xử lý ngoại lệ tốt.");
    grade.setResultStatus("DRAFT");

    Quiz quiz = new Quiz();
    quiz.setQuizId(60);
    quiz.setTitle("Quiz OAuth2 & OpenID");

    QuizAttempt attempt = new QuizAttempt();
    attempt.setAttemptId(600);
    attempt.setQuiz(quiz);
    attempt.setCourse(course);
    attempt.setStudent(student);
    attempt.setAttemptNumber(1);
    attempt.setScore(BigDecimal.valueOf(18));
    attempt.setMaxScore(BigDecimal.valueOf(20));
    attempt.setStatus("SCORED");
    attempt.setResultStatus("HIDDEN");
    attempt.setSubmittedAt(LocalDateTime.of(2026, 11, 11, 14, 30));

    when(courses.findById(100)).thenReturn(Optional.of(course));
    when(submissions.findByCourse_CourseIdOrderBySubmittedAtDesc(100))
        .thenReturn(List.of(sub));
    when(grades.findBySubmission_SubmissionId(500))
        .thenReturn(Optional.of(grade));
    when(attempts.findByCourse_CourseIdAndStatusInOrderBySubmittedAtDesc(
        100, List.of("SUBMITTED", "SCORED")))
        .thenReturn(List.of(attempt));

    List<ResultRow> overview = service.instructorOverview(100, 10);
    assertEquals(2, overview.size());
    assertEquals("QUIZ", overview.get(0).getKind());
    assertEquals("READY", overview.get(0).getState());
    assertEquals("ASSIGNMENT", overview.get(1).getKind());
    assertEquals("READY", overview.get(1).getState());

    int publishedCount = service.publishAllReady(100, 10);
    assertEquals(2, publishedCount);
    verify(quizService).publishAttemptResult(100, 60, 600, 10);
    verify(assignmentService).publishGrade(100, 50, 500, 10);

    Map<String, Object> stats = service.buildInstructorGradebookStats(overview);
    assertEquals(2, stats.get("totalCount"));
    assertEquals(2, stats.get("readyCount"));
    assertEquals(new BigDecimal("87.5"), stats.get("averagePercent"));

    String csv = service.exportInstructorResultsCsv(course, overview);
    assertTrue(csv.contains("Quiz OAuth2 & OpenID"));
    assertTrue(csv.contains("Bài tập JWT Filter"));
  }

  @Test
  void studentResults_hidesUnpublishedScoresAndComputesAverageForPublishedOnly() {
    Users student = new Users();
    student.setUserId(30);
    student.setFullName("Nguyễn Hải Yến");

    Course course = new Course();
    course.setCourseId(200);
    course.setTitle("Cơ sở dữ liệu nâng cao");

    Enrollment enrollment = new Enrollment();
    enrollment.setStudent(student);
    enrollment.setCourse(course);
    enrollment.setStatus("ACTIVE");

    Assignment a1 = new Assignment();
    a1.setAssignmentId(71);
    a1.setTitle("Thiết kế ERD");
    a1.setMaxScore(BigDecimal.valueOf(100));

    Submission s1 = new Submission();
    s1.setSubmissionId(710);
    s1.setAssignment(a1);
    s1.setStudent(student);
    s1.setAttemptNumber(1);
    s1.setSubmittedAt(LocalDateTime.of(2026, 11, 5, 10, 0));

    Grade g1 = new Grade();
    g1.setScore(BigDecimal.valueOf(90));
    g1.setMaxScore(BigDecimal.valueOf(100));
    g1.setFeedback("Chuẩn 3NF chính xác");
    g1.setResultStatus("PUBLISHED");
    g1.setPublishedAt(LocalDateTime.of(2026, 11, 6, 12, 0));

    Quiz q1 = new Quiz();
    q1.setQuizId(81);
    q1.setTitle("Quiz Indexing & B-Tree");

    QuizAttempt qa1 = new QuizAttempt();
    qa1.setAttemptId(810);
    qa1.setQuiz(q1);
    qa1.setStudent(student);
    qa1.setAttemptNumber(1);
    qa1.setScore(BigDecimal.valueOf(8));
    qa1.setMaxScore(BigDecimal.valueOf(10));
    qa1.setStatus("SCORED");
    qa1.setResultStatus("HIDDEN");
    qa1.setSubmittedAt(LocalDateTime.of(2026, 11, 7, 15, 0));

    when(enrollments.findByStudent_UserIdAndCourse_CourseId(30, 200))
        .thenReturn(Optional.of(enrollment));
    when(submissions.findByCourse_CourseIdAndStudent_UserIdOrderBySubmittedAtDesc(200, 30))
        .thenReturn(List.of(s1));
    when(grades.findBySubmission_SubmissionId(710))
        .thenReturn(Optional.of(g1));
    when(attempts.findByCourse_CourseIdAndStudent_UserIdAndStatusInOrderBySubmittedAtDesc(
        200, 30, List.of("SUBMITTED", "SCORED")))
        .thenReturn(List.of(qa1));

    StudentResultsView view = service.studentResults(200, 30);
    assertNotNull(view);
    assertEquals("Cơ sở dữ liệu nâng cao", view.getCourseTitle());
    assertEquals(1L, view.getPublishedCount());
    assertEquals(new BigDecimal("90.0"), view.getAveragePercent());
    assertEquals(new BigDecimal("9.00"), view.getAverageScale10());
    assertEquals("Xuất sắc", view.getAcademicStandingLabel());

    ResultRow unpubQuiz = view.getRows().get(0);
    assertEquals("READY", unpubQuiz.getState());
    assertNull(unpubQuiz.getScore(), "Unpublished quiz score must be hidden from student");

    ResultRow pubAssign = view.getRows().get(1);
    assertEquals("PUBLISHED", pubAssign.getState());
    assertEquals(BigDecimal.valueOf(90), pubAssign.getScore());
    assertEquals("A+", pubAssign.getLetterGrade());
    assertTrue(pubAssign.isPassed());
  }

  @Test
  void studentResults_throwsForbiddenWhenNotEnrolled() {
    when(enrollments.findByStudent_UserIdAndCourse_CourseId(99, 200))
        .thenReturn(Optional.empty());

    CourseActionException ex = assertThrows(
        CourseActionException.class,
        () -> service.studentResults(200, 99));
    assertEquals(HttpStatus.FORBIDDEN, ex.getStatus());
    assertFalse(ex.getMessage().isBlank());
  }
}
