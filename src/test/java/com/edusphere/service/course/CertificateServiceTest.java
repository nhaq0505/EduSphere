package com.edusphere.service.course;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

import com.edusphere.dto.course.CertificateView;
import com.edusphere.entity.account.Users;
import com.edusphere.entity.course.Category;
import com.edusphere.entity.course.Certificate;
import com.edusphere.entity.course.Course;
import com.edusphere.entity.course.Enrollment;
import com.edusphere.entity.course.Lesson;
import com.edusphere.repository.account.UserRepository;
import com.edusphere.repository.course.CertificateRepository;
import com.edusphere.repository.course.CourseCommentRepository;
import com.edusphere.repository.course.CourseRepository;
import com.edusphere.repository.course.EnrollmentRepository;
import com.edusphere.repository.course.LessonCompletionRepository;
import com.edusphere.repository.course.LessonRepository;
import com.edusphere.repository.course.QuizAttemptRepository;
import com.edusphere.repository.course.QuizRepository;

import java.awt.image.BufferedImage;
import java.io.ByteArrayInputStream;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import javax.imageio.ImageIO;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.http.HttpStatus;

/**
 * Unit tests kiểm thử toàn diện cho CertificateService và CertificateView.
 * Đảm bảo tính năng cấp phát chứng chỉ, tra cứu mã xác thực, xuất ảnh PNG chất lượng cao
 * và tính toán bảng điểm tín chỉ học thuật hoạt động chính xác.
 */
class CertificateServiceTest {

  private CertificateRepository certificateRepository;
  private EnrollmentRepository enrollmentRepository;
  private CourseRepository courseRepository;
  private LessonRepository lessonRepository;
  private LessonCompletionRepository completionRepository;
  private QuizRepository quizRepository;
  private QuizAttemptRepository quizAttemptRepository;
  private UserRepository userRepository;
  private LearningProgressService learningProgressService;
  private CourseCommentRepository commentRepository;

  private CertificateService service;

  @BeforeEach
  void setUp() {
    certificateRepository = mock(CertificateRepository.class);
    enrollmentRepository = mock(EnrollmentRepository.class);
    courseRepository = mock(CourseRepository.class);
    lessonRepository = mock(LessonRepository.class);
    completionRepository = mock(LessonCompletionRepository.class);
    quizRepository = mock(QuizRepository.class);
    quizAttemptRepository = mock(QuizAttemptRepository.class);
    userRepository = mock(UserRepository.class);
    learningProgressService = mock(LearningProgressService.class);
    commentRepository = mock(CourseCommentRepository.class);

    service = new CertificateService(
        certificateRepository,
        enrollmentRepository,
        courseRepository,
        lessonRepository,
        completionRepository,
        quizRepository,
        quizAttemptRepository,
        userRepository,
        learningProgressService,
        commentRepository);
  }

  @Test
  void renderCertificatePng_producesValidHighResPngImage() throws Exception {
    CertificateView cert = CertificateView.builder()
        .certificateId(101)
        .verificationCode("EDU2026CERT01")
        .issuedAt(LocalDateTime.of(2026, 11, 14, 10, 30))
        .creditsEarned(3)
        .gradePercent(95)
        .totalHours(24)
        .status("VALID")
        .studentId(10)
        .studentName("Nguyễn Văn Minh")
        .studentEmail("minh@edusphere.vn")
        .courseId(5)
        .courseTitle("Lập trình Java Web với Spring Boot & Microservices")
        .categoryName("Công nghệ phần mềm")
        .levelLabel("Trung cấp")
        .instructorName("TS. Trần Quốc Tuấn")
        .instructorTitle("Giảng viên Hướng dẫn & Chuyên gia Đào tạo")
        .lessonCount(12)
        .enrolledCount(150)
        .averageRating(4.9)
        .ratingCount(45)
        .objectivesList(List.of("Nắm vững Spring Boot", "Xây dựng RESTful API"))
        .skillsList(List.of("Java", "Spring Boot", "SQL"))
        .build();

    byte[] pngBytes = service.renderCertificatePng(cert, "https://edusphere.vn");

    assertNotNull(pngBytes);
    assertTrue(pngBytes.length > 10_000, "PNG image bytes should not be empty");

    BufferedImage img = ImageIO.read(new ByteArrayInputStream(pngBytes));
    assertNotNull(img);
    assertEquals(1800, img.getWidth());
    assertEquals(1260, img.getHeight());
  }

  @Test
  void certificateView_formattingAndAcademicHelpers_workCorrectly() {
    CertificateView highGradeCert = CertificateView.builder()
        .certificateId(202)
        .verificationCode("EDU2026HONORS")
        .issuedAt(LocalDateTime.of(2026, 10, 20, 14, 0))
        .creditsEarned(4)
        .gradePercent(96)
        .totalHours(36)
        .status("VALID")
        .studentName("Lê Hoàng Nam")
        .courseTitle("Kiến trúc Hệ thống Phân tán")
        .build();

    assertEquals("20/10/2026", highGradeCert.getFormattedIssuedDateVi());
    assertEquals("2026-10-20", highGradeCert.getFormattedIssuedDateIso());
    assertEquals("October 20, 2026", highGradeCert.getFormattedIssuedDateEn());
    assertEquals("Oct 20, 2026", highGradeCert.getFormattedIssuedDateShortEn());
    assertTrue(highGradeCert.isValidStatus());
    assertTrue(highGradeCert.isWithDistinction());
    assertEquals("A+", highGradeCert.getLetterGradeEquivalent());
    assertEquals("Xuất sắc (With High Distinction)", highGradeCert.getHonorsDistinctionLabel());
    assertEquals("LN", highGradeCert.getStudentInitials());

    CertificateView revokedCert = CertificateView.builder()
        .status("REVOKED")
        .gradePercent(70)
        .studentName("Minh")
        .build();
    assertFalse(revokedCert.isValidStatus());
    assertFalse(revokedCert.isWithDistinction());
    assertEquals("C+", revokedCert.getLetterGradeEquivalent());
    assertEquals("Hoàn thành (Pass)", revokedCert.getHonorsDistinctionLabel());
    assertEquals("MI", revokedCert.getStudentInitials());
  }

  @Test
  void issueCertificateIfEligible_createsNewCertificateWhenCourseCompleted() {
    Users student = new Users();
    student.setUserId(15);
    student.setFullName("Phạm Thu Hà");

    Users instructor = new Users();
    instructor.setUserId(2);
    instructor.setFullName("PGS.TS. Nguyễn Hữu Đạt");

    Category category = new Category();
    category.setName("Khoa học dữ liệu");

    Course course = new Course();
    course.setCourseId(88);
    course.setTitle("Phân tích Dữ liệu với Python & SQL");
    course.setInstructor(instructor);
    course.setCategory(category);
    course.setLevel("ADVANCED");

    Enrollment enrollment = new Enrollment();
    enrollment.setStudent(student);
    enrollment.setCourse(course);
    enrollment.setStatus("COMPLETED");

    Lesson l1 = new Lesson();
    l1.setLessonId(1);
    l1.setStatus("PUBLISHED");

    Lesson l2 = new Lesson();
    l2.setLessonId(2);
    l2.setStatus("PUBLISHED");

    when(enrollmentRepository.findByStudent_UserIdAndCourse_CourseId(15, 88))
        .thenReturn(Optional.of(enrollment));
    when(lessonRepository.findByCourse_CourseIdAndStatusOrderByOrderIndexAsc(88, "PUBLISHED"))
        .thenReturn(List.of(l1, l2));
    when(completionRepository.countByStudent_UserIdAndCourse_CourseId(15, 88))
        .thenReturn(2L);
    when(certificateRepository.findByStudent_UserIdAndCourse_CourseId(15, 88))
        .thenReturn(Optional.empty());
    when(courseRepository.findById(88)).thenReturn(Optional.of(course));
    when(userRepository.findById(15)).thenReturn(Optional.of(student));
    when(quizRepository.findByCourse_CourseIdOrderByCreatedAtDesc(88))
        .thenReturn(List.of());

    when(certificateRepository.save(any(Certificate.class))).thenAnswer(inv -> {
      Certificate saved = inv.getArgument(0);
      saved.setCertificateId(501);
      return saved;
    });

    Optional<Certificate> issued = service.issueCertificateIfEligible(15, 88);
    assertTrue(issued.isPresent());
    assertEquals(501, issued.get().getCertificateId());
    assertEquals("VALID", issued.get().getStatus());
    assertNotNull(issued.get().getVerificationCode());
  }

  @Test
  void getCertificateByVerificationCode_throwsNotFoundForUnknownCode() {
    when(certificateRepository.findByVerificationCode("UNKNOWN999"))
        .thenReturn(Optional.empty());

    CourseActionException ex = assertThrows(
        CourseActionException.class,
        () -> service.getCertificateByVerificationCode("UNKNOWN999"));
    assertEquals(HttpStatus.NOT_FOUND, ex.getStatus());
  }

  @Test
  void buildAcademicCreditTranscript_aggregatesCreditsAndHoursCorrectly() {
    when(enrollmentRepository.findByStudent_UserIdOrderByEnrolledAtDesc(99))
        .thenReturn(List.of());
    when(certificateRepository.findByStudent_UserIdAndStatusOrderByIssuedAtDesc(99, "VALID"))
        .thenReturn(List.of());

    Map<String, Object> transcript = service.buildAcademicCreditTranscript(99);
    assertNotNull(transcript);
    assertEquals(99, transcript.get("studentId"));
    assertEquals(0, transcript.get("totalCertificates"));
    assertEquals(0, transcript.get("totalCreditsEarned"));
    assertEquals("Đang tích lũy tín chỉ", transcript.get("academicStanding"));
  }
}
