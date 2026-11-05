package com.edusphere.adversarial;

import com.edusphere.controller.account.PasswordController;
import com.edusphere.dto.account.ForgotPasswordRequest;
import com.edusphere.dto.assignment.AssignmentForm;
import com.edusphere.dto.assignment.SubmissionForm;
import com.edusphere.dto.course.MaterialForm;
import com.edusphere.entity.account.PasswordResetTokens;
import com.edusphere.entity.account.Users;
import com.edusphere.entity.course.*;
import com.edusphere.repository.account.PasswordResetTokenRepository;
import com.edusphere.repository.account.UserRepository;
import com.edusphere.repository.course.*;
import com.edusphere.service.account.EmailService;
import com.edusphere.service.account.PasswordResetService;
import com.edusphere.service.account.ProfileService;
import com.edusphere.service.course.AssignmentService;
import com.edusphere.service.course.CourseActionException;
import com.edusphere.service.course.FileUploadService;
import com.edusphere.service.course.LessonManagementService;
import com.edusphere.service.course.QuizService;
import jakarta.persistence.EntityManager;
import jakarta.validation.ConstraintViolation;
import jakarta.validation.Validation;
import jakarta.validation.Validator;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.io.TempDir;
import org.mockito.ArgumentCaptor;
import org.springframework.http.HttpStatus;
import org.springframework.mock.web.MockHttpSession;
import org.springframework.mock.web.MockMultipartFile;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.test.util.ReflectionTestUtils;
import org.springframework.ui.ExtendedModelMap;
import org.springframework.validation.BeanPropertyBindingResult;
import org.springframework.web.servlet.mvc.support.RedirectAttributesModelMap;

import java.math.BigDecimal;
import java.nio.file.Path;
import java.time.LocalDateTime;
import java.util.*;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

/**
 * Empirical Adversarial Test Suite for EduSphere Hardening & Remediation.
 * Stress-tests security edge cases, quiz logic, DB order index uniqueness,
 * and assignment validation.
 */
public class AdversarialVerificationTest {

    // =========================================================================
    // MISSION 1: ADVERSARIAL TEST 1 (SECURITY)
    // =========================================================================
    @Nested
    @DisplayName("Adversarial Test 1: Security Edge Cases & File Upload Whitelist")
    class SecurityAdversarialTests {

        private UserRepository userRepo;
        private PasswordResetTokenRepository tokenRepo;
        private PasswordEncoder passwordEncoder;
        private EmailService emailService;
        private PasswordResetService resetService;
        private ProfileService profileService;
        private PasswordController passwordController;

        private FileUploadService fileUploadService;

        @TempDir
        Path tempDir;

        private Users victimUser;
        private Users attackerUser;

        @BeforeEach
        void setUp() {
            userRepo = mock(UserRepository.class);
            tokenRepo = mock(PasswordResetTokenRepository.class);
            passwordEncoder = mock(PasswordEncoder.class);
            emailService = mock(EmailService.class);
            profileService = mock(ProfileService.class);

            resetService = new PasswordResetService(userRepo, tokenRepo, passwordEncoder, emailService);
            passwordController = new PasswordController(resetService, profileService);

            fileUploadService = new FileUploadService();
            ReflectionTestUtils.setField(fileUploadService, "baseUploadDir", tempDir.toAbsolutePath().toString());

            victimUser = new Users();
            victimUser.setUserId(101);
            victimUser.setEmail("victim@edusphere.com");
            victimUser.setFullName("Victim Account");
            victimUser.setStatus("ACTIVE");

            attackerUser = new Users();
            attackerUser.setUserId(102);
            attackerUser.setEmail("attacker@edusphere.com");
            attackerUser.setFullName("Attacker Account");
            attackerUser.setStatus("ACTIVE");
        }

        @Test
        @DisplayName("Security: Tampering email after OTP verification must redirect to forgot-password")
        void testTamperingEmailAfterOtpVerificationRedirects() {
            MockHttpSession session = new MockHttpSession();

            // Attacker legitimately verified OTP for attacker@edusphere.com
            session.setAttribute("resetPasswordEmail", "attacker@edusphere.com");
            session.setAttribute("resetOtpVerified", true);
            session.setAttribute("resetOtpVerifiedEmail", "attacker@edusphere.com");

            // Attacker modifies session email attribute to target victim
            session.setAttribute("resetPasswordEmail", "victim@edusphere.com");

            // Attempt GET /reset-password
            String getResult = passwordController.showResetPasswordPage(session);
            assertEquals("redirect:/forgot-password", getResult, "Tampered session email must be rejected on GET");

            // Attempt POST /reset-password
            ExtendedModelMap model = new ExtendedModelMap();
            RedirectAttributesModelMap ra = new RedirectAttributesModelMap();
            String postResult = passwordController.processResetPassword("NewSecureP@ss123", "NewSecureP@ss123", session, model, ra);
            assertEquals("redirect:/forgot-password", postResult, "Tampered session email must be rejected on POST");

            // Verify resetPassword was never invoked on service
            verify(passwordEncoder, never()).encode(any());
        }

        @Test
        @DisplayName("Security: Calling reset password without OTP verification must redirect to forgot-password")
        void testCallingResetWithoutOtpRedirects() {
            MockHttpSession session = new MockHttpSession();
            ExtendedModelMap model = new ExtendedModelMap();
            RedirectAttributesModelMap ra = new RedirectAttributesModelMap();

            // Case A: Completely empty session
            assertEquals("redirect:/forgot-password", passwordController.showResetPasswordPage(session));
            assertEquals("redirect:/forgot-password", passwordController.processResetPassword("NewSecureP@ss123", "NewSecureP@ss123", session, model, ra));

            // Case B: Session has email but resetOtpVerified is false or null
            session.setAttribute("resetPasswordEmail", "victim@edusphere.com");
            assertEquals("redirect:/forgot-password", passwordController.showResetPasswordPage(session));
            assertEquals("redirect:/forgot-password", passwordController.processResetPassword("NewSecureP@ss123", "NewSecureP@ss123", session, model, ra));

            // Case C: resetOtpVerified is true but verifiedEmail is missing
            session.setAttribute("resetOtpVerified", true);
            assertEquals("redirect:/forgot-password", passwordController.showResetPasswordPage(session));
            assertEquals("redirect:/forgot-password", passwordController.processResetPassword("NewSecureP@ss123", "NewSecureP@ss123", session, model, ra));
        }

        @Test
        @DisplayName("Security: OTP verification with expired token must be rejected with exception")
        void testExpiredOtpVerificationRejected() {
            when(userRepo.findByEmail("victim@edusphere.com")).thenReturn(Optional.of(victimUser));

            // Token created 20 minutes ago (expired)
            PasswordResetTokens expiredToken = new PasswordResetTokens();
            expiredToken.setToken("654321");
            expiredToken.setUserId(victimUser);
            expiredToken.setExpiresAt(new Date(System.currentTimeMillis() - 1000 * 60 * 10)); // 10 mins expired

            when(tokenRepo.findByToken("654321")).thenReturn(Optional.of(expiredToken));

            IllegalArgumentException ex = assertThrows(IllegalArgumentException.class,
                    () -> resetService.verifyResetOtp("victim@edusphere.com", "654321"));
            assertTrue(ex.getMessage().contains("Mã OTP đã hết hạn"), "Expected expired OTP message but got: " + ex.getMessage());

            // Also test controller handling
            MockHttpSession session = new MockHttpSession();
            session.setAttribute("resetPasswordEmail", "victim@edusphere.com");
            ExtendedModelMap model = new ExtendedModelMap();

            String view = passwordController.processResetOtp("654321", session, model);
            assertEquals("auth/forgot-password-otp", view);
            assertNull(session.getAttribute("resetOtpVerified"));
            assertNull(session.getAttribute("resetOtpVerifiedEmail"));
            assertTrue(model.containsAttribute("errorMessage"));
        }

        @Test
        @DisplayName("Security: Re-requesting or resending OTP must invalidate previous verified session state")
        void testResendOtpClearsVerifiedSessionState() {
            MockHttpSession session = new MockHttpSession();
            session.setAttribute("resetPasswordEmail", "victim@edusphere.com");
            session.setAttribute("resetOtpVerified", true);
            session.setAttribute("resetOtpVerifiedEmail", "victim@edusphere.com");

            when(userRepo.findByEmail("victim@edusphere.com")).thenReturn(Optional.of(victimUser));
            when(tokenRepo.findByToken(any())).thenReturn(Optional.empty());

            // Resend OTP
            RedirectAttributesModelMap ra = new RedirectAttributesModelMap();
            passwordController.resendResetOtp(session, ra);

            assertNull(session.getAttribute("resetOtpVerified"), "resetOtpVerified must be cleared on resend");
            assertNull(session.getAttribute("resetOtpVerifiedEmail"), "resetOtpVerifiedEmail must be cleared on resend");

            // Forgot-password submission also clears
            session.setAttribute("resetOtpVerified", true);
            session.setAttribute("resetOtpVerifiedEmail", "victim@edusphere.com");
            ForgotPasswordRequest req = new ForgotPasswordRequest();
            req.setEmail("victim@edusphere.com");
            BeanPropertyBindingResult bindingResult = new BeanPropertyBindingResult(req, "forgotPasswordRequest");

            passwordController.processForgot(req, bindingResult, session);
            assertNull(session.getAttribute("resetOtpVerified"), "resetOtpVerified must be cleared on new forgot request");
            assertNull(session.getAttribute("resetOtpVerifiedEmail"), "resetOtpVerifiedEmail must be cleared on new forgot request");
        }

        @Test
        @DisplayName("Security: File upload in category 'general' must reject dangerous extensions (.jsp, .svg, .html, .js, .exe)")
        void testFileUploadRejectsDangerousExtensionsInGeneralCategory() {
            List<String> dangerousFiles = List.of(
                    "exploit.jsp", "payload.JSP", "shell.jspx",
                    "vector.svg", "image.SVG",
                    "page.html", "index.htm", "script.js",
                    "malware.exe", "backdoor.php", "script.sh"
            );

            for (String filename : dangerousFiles) {
                MockMultipartFile file = new MockMultipartFile(
                        "file", filename, "application/octet-stream", "evil-content".getBytes());

                CourseActionException ex = assertThrows(CourseActionException.class,
                        () -> fileUploadService.storeFile(file, "general"),
                        "Expected file " + filename + " to be rejected");
                assertEquals(HttpStatus.BAD_REQUEST, ex.getStatus());
            }
        }

        @Test
        @DisplayName("Security: File upload in specific categories (thumbnail, video, material) must also reject dangerous files")
        void testFileUploadRejectsDangerousInOtherCategories() {
            // Category thumbnail must reject svg and html
            MockMultipartFile svgFile = new MockMultipartFile("file", "icon.svg", "image/svg+xml", "<svg></svg>".getBytes());
            assertThrows(CourseActionException.class, () -> fileUploadService.storeFile(svgFile, "thumbnail"));

            MockMultipartFile htmlFile = new MockMultipartFile("file", "page.html", "text/html", "<html></html>".getBytes());
            assertThrows(CourseActionException.class, () -> fileUploadService.storeFile(htmlFile, "thumbnail"));

            // Category video must reject jsp and exe
            MockMultipartFile jspFile = new MockMultipartFile("file", "shell.jsp", "text/plain", "<% %>".getBytes());
            assertThrows(CourseActionException.class, () -> fileUploadService.storeFile(jspFile, "video"));

            // Category material must reject jsp, svg, and exe
            MockMultipartFile exeFile = new MockMultipartFile("file", "setup.exe", "application/octet-stream", "MZ".getBytes());
            assertThrows(CourseActionException.class, () -> fileUploadService.storeFile(exeFile, "material"));
        }

        @Test
        @DisplayName("Security: Password reset must reject passwords under 8 chars or over 100 chars")
        void testPasswordLengthValidationBoundary() {
            MockHttpSession session = new MockHttpSession();
            session.setAttribute("resetPasswordEmail", "victim@edusphere.com");
            session.setAttribute("resetOtpVerified", true);
            session.setAttribute("resetOtpVerifiedEmail", "victim@edusphere.com");

            ExtendedModelMap model = new ExtendedModelMap();
            RedirectAttributesModelMap ra = new RedirectAttributesModelMap();

            // < 8 chars
            String res1 = passwordController.processResetPassword("short", "short", session, model, ra);
            assertEquals("auth/reset-password", res1);
            assertTrue(model.get("errorMessage").toString().contains("8 đến 100"));

            // > 100 chars
            String longPass = "a".repeat(101);
            String res2 = passwordController.processResetPassword(longPass, longPass, session, model, ra);
            assertEquals("auth/reset-password", res2);
            assertTrue(model.get("errorMessage").toString().contains("8 đến 100"));

            // Service layer also enforces
            assertThrows(IllegalArgumentException.class, () -> resetService.resetPassword("victim@edusphere.com", "short", "short"));
            assertThrows(IllegalArgumentException.class, () -> resetService.resetPassword("victim@edusphere.com", longPass, longPass));
        }

        @Test
        @DisplayName("Security: verifyResetOtp must reject token belonging to a different user")
        void testVerifyResetOtpTokenBelongingToDifferentUser() {
            when(userRepo.findByEmail("victim@edusphere.com")).thenReturn(Optional.of(victimUser));

            // Token belongs to attackerUser (id 102), but verify called with victimUser's email (id 101)
            PasswordResetTokens token = new PasswordResetTokens();
            token.setToken("123456");
            token.setUserId(attackerUser);
            token.setExpiresAt(new Date(System.currentTimeMillis() + 1000 * 60 * 10));

            when(tokenRepo.findByToken("123456")).thenReturn(Optional.of(token));

            IllegalArgumentException ex = assertThrows(IllegalArgumentException.class,
                    () -> resetService.verifyResetOtp("victim@edusphere.com", "123456"));
            assertTrue(ex.getMessage().contains("Mã OTP không hợp lệ"));
        }

        @Test
        @DisplayName("Security: resetPassword without active valid token in database must throw exception")
        void testResetPasswordWithoutActiveValidTokenThrows() {
            when(userRepo.findByEmail("victim@edusphere.com")).thenReturn(Optional.of(victimUser));
            when(tokenRepo.findLatestValidByUserId(victimUser)).thenReturn(Optional.empty());

            IllegalArgumentException ex = assertThrows(IllegalArgumentException.class,
                    () -> resetService.resetPassword("victim@edusphere.com", "ValidP@ssword123", "ValidP@ssword123"));
            assertTrue(ex.getMessage().contains("Phiên đặt lại mật khẩu đã hết hạn"));
        }

        @Test
        @DisplayName("Security: File upload in category 'general' must accept safe extensions (.pdf, .png, .mp4, .docx)")
        void testFileUploadAcceptsSafeExtensionsInGeneralCategory() {
            List<String> safeFiles = List.of("report.pdf", "photo.png", "video.mp4", "lecture.docx");

            for (String filename : safeFiles) {
                MockMultipartFile file = new MockMultipartFile(
                        "file", filename, "application/octet-stream", "valid-content".getBytes());

                String storedUrl = fileUploadService.storeFile(file, "general");
                assertNotNull(storedUrl);
                assertTrue(storedUrl.startsWith("/uploads/general/"), "Url should start with /uploads/general/ for: " + filename);
            }
        }
    }

    // =========================================================================
    // MISSION 2: ADVERSARIAL TEST 2 (QUIZ LOGIC)
    // =========================================================================
    @Nested
    @DisplayName("Adversarial Test 2: Quiz Logic & Publication Constraint")
    class QuizLogicAdversarialTests {

        private QuizRepository quizRepo;
        private QuestionRepository questionRepo;
        private AnswerOptionRepository optionRepo;
        private QuizAttemptRepository attemptRepo;
        private QuizAnswerRepository answerRepo;
        private QuizAnswerOptionRepository linkRepo;
        private CourseRepository courseRepo;
        private LessonRepository lessonRepo;
        private EnrollmentRepository enrollmentRepo;
        private UserRepository userRepo;
        private QuizService quizService;

        private Course course;
        private Users instructor;
        private Users student;
        private Quiz quiz;

        @BeforeEach
        void setUp() {
            quizRepo = mock(QuizRepository.class);
            questionRepo = mock(QuestionRepository.class);
            optionRepo = mock(AnswerOptionRepository.class);
            attemptRepo = mock(QuizAttemptRepository.class);
            answerRepo = mock(QuizAnswerRepository.class);
            linkRepo = mock(QuizAnswerOptionRepository.class);
            courseRepo = mock(CourseRepository.class);
            lessonRepo = mock(LessonRepository.class);
            enrollmentRepo = mock(EnrollmentRepository.class);
            userRepo = mock(UserRepository.class);

            quizService = new QuizService(quizRepo, questionRepo, optionRepo, attemptRepo, answerRepo, linkRepo,
                    courseRepo, lessonRepo, enrollmentRepo, userRepo, null);

            instructor = new Users();
            instructor.setUserId(10);
            instructor.setFullName("Prof Instructor");

            student = new Users();
            student.setUserId(20);
            student.setFullName("Student Tester");

            course = new Course();
            course.setCourseId(100);
            course.setInstructor(instructor);

            quiz = new Quiz();
            quiz.setQuizId(200);
            quiz.setCourse(course);
            quiz.setCreatedBy(instructor);
            quiz.setStatus("PUBLISHED");

            Enrollment enrollment = new Enrollment();
            enrollment.setStatus("ACTIVE");
            when(enrollmentRepo.findByStudent_UserIdAndCourse_CourseId(20, 100)).thenReturn(Optional.of(enrollment));
        }

        @Test
        @DisplayName("Quiz Logic: Submitting expired attempt does NOT throw rollback exception and transitions out of IN_PROGRESS")
        void testExpiredQuizSubmissionDoesNotRollback() {
            QuizAttempt attempt = new QuizAttempt();
            attempt.setAttemptId(9001);
            attempt.setCourse(course);
            attempt.setQuiz(quiz);
            attempt.setStudent(student);
            attempt.setStatus("IN_PROGRESS");
            attempt.setDeadlineAt(LocalDateTime.now().minusHours(2)); // Expired 2 hours ago

            when(attemptRepo.findByAttemptIdAndStudent_UserId(9001, 20)).thenReturn(Optional.of(attempt));
            when(questionRepo.findByQuiz_QuizIdOrderByOrderIndexAsc(200)).thenReturn(List.of());
            when(attemptRepo.save(any(QuizAttempt.class))).thenAnswer(inv -> inv.getArgument(0));

            // Executing submission must succeed without rollback exception
            assertDoesNotThrow(() -> quizService.submitAttempt(100, 200, 9001, 20, Map.of()));

            // Verify attempt transitioned out of IN_PROGRESS
            assertNotEquals("IN_PROGRESS", attempt.getStatus(), "Attempt must not be trapped in IN_PROGRESS");
            assertNotNull(attempt.getSubmittedAt(), "SubmittedAt must be set");
        }

        @Test
        @DisplayName("Quiz Logic: Auto-published attempt must have status=SCORED, resultStatus=PUBLISHED, and valid published_at/published_by")
        void testAutoPublishedQuizSetsRequiredFieldsForConstraint() {
            QuizAttempt attempt = new QuizAttempt();
            attempt.setAttemptId(9002);
            attempt.setCourse(course);
            attempt.setQuiz(quiz);
            attempt.setStudent(student);
            attempt.setStatus("IN_PROGRESS");
            attempt.setDeadlineAt(LocalDateTime.now().plusMinutes(30));

            Question q1 = new Question();
            q1.setQuestionId(1);
            q1.setQuiz(quiz);
            q1.setType("SINGLE_CHOICE");
            q1.setScore(BigDecimal.valueOf(10));

            AnswerOption opt1 = new AnswerOption();
            opt1.setOptionId(11);
            opt1.setQuestion(q1);
            opt1.setContent("Correct");
            opt1.setCorrect(true);

            when(attemptRepo.findByAttemptIdAndStudent_UserId(9002, 20)).thenReturn(Optional.of(attempt));
            when(questionRepo.findByQuiz_QuizIdOrderByOrderIndexAsc(200)).thenReturn(List.of(q1));
            when(optionRepo.findByQuestion_QuestionIdOrderByOrderIndexAsc(1)).thenReturn(List.of(opt1));
            when(answerRepo.save(any())).thenAnswer(inv -> inv.getArgument(0));
            when(attemptRepo.save(any())).thenAnswer(inv -> inv.getArgument(0));

            quizService.submitAttempt(100, 200, 9002, 20, Map.of(1, List.of("11")));

            // Strictly verify CK_quiz_attempts_publication compliance:
            // ([result_status]<>'PUBLISHED' OR [status]='SCORED' AND [published_at] IS NOT NULL AND [published_by] IS NOT NULL AND [published_at]>=[submitted_at])
            assertEquals("SCORED", attempt.getStatus());
            assertEquals("PUBLISHED", attempt.getResultStatus());
            assertNotNull(attempt.getPublishedAt(), "published_at must not be null when result_status=PUBLISHED");
            assertNotNull(attempt.getPublishedBy(), "published_by must not be null when result_status=PUBLISHED");
            assertEquals(instructor.getUserId(), attempt.getPublishedBy().getUserId());
            assertFalse(attempt.getPublishedAt().isBefore(attempt.getSubmittedAt()), "published_at must be >= submitted_at");
        }

        @Test
        @DisplayName("Quiz Logic: Quiz with manual grading questions must NOT be auto-published (published_at and published_by remain null)")
        void testQuizWithManualGradingNotAutoPublished() {
            QuizAttempt attempt = new QuizAttempt();
            attempt.setAttemptId(9003);
            attempt.setCourse(course);
            attempt.setQuiz(quiz);
            attempt.setStudent(student);
            attempt.setStatus("IN_PROGRESS");
            attempt.setDeadlineAt(LocalDateTime.now().plusMinutes(30));

            Question q1 = new Question();
            q1.setQuestionId(2);
            q1.setQuiz(quiz);
            q1.setType("ESSAY");
            q1.setScore(BigDecimal.valueOf(10));

            when(attemptRepo.findByAttemptIdAndStudent_UserId(9003, 20)).thenReturn(Optional.of(attempt));
            when(questionRepo.findByQuiz_QuizIdOrderByOrderIndexAsc(200)).thenReturn(List.of(q1));
            when(answerRepo.save(any())).thenAnswer(inv -> inv.getArgument(0));
            when(attemptRepo.save(any())).thenAnswer(inv -> inv.getArgument(0));

            quizService.submitAttempt(100, 200, 9003, 20, Map.of(2, List.of("Essay text")));

            // For manual questions, status is SUBMITTED, resultStatus is not PUBLISHED, published_at is null
            assertEquals("SUBMITTED", attempt.getStatus());
            assertNotEquals("PUBLISHED", attempt.getResultStatus());
            assertNull(attempt.getPublishedAt());
            assertNull(attempt.getPublishedBy());
        }
    }

    // =========================================================================
    // MISSION 3: ADVERSARIAL TEST 3 (DB & UNIQUE CONSTRAINTS)
    // =========================================================================
    @Nested
    @DisplayName("Adversarial Test 3: Order Index Reordering & Deletion Buffer Mechanics")
    class OrderIndexAdversarialTests {

        private CourseRepository courseRepo;
        private LessonRepository lessonRepo;
        private MaterialRepository matRepo;
        private QuestionRepository questionRepo;
        private QuizRepository quizRepo;
        private QuizService quizService;
        private LessonManagementService lessonService;

        private Course testCourse;
        private Users instructor;
        private Quiz testQuiz;

        @BeforeEach
        void setUp() {
            courseRepo = mock(CourseRepository.class);
            lessonRepo = mock(LessonRepository.class);
            matRepo = mock(MaterialRepository.class);
            questionRepo = mock(QuestionRepository.class);
            quizRepo = mock(QuizRepository.class);

            instructor = new Users();
            instructor.setUserId(10);

            testCourse = new Course();
            testCourse.setCourseId(100);
            testCourse.setInstructor(instructor);
            testCourse.setStatus("DRAFT");

            testQuiz = new Quiz();
            testQuiz.setQuizId(200);
            testQuiz.setCourse(testCourse);
            testQuiz.setCreatedBy(instructor);
            testQuiz.setStatus("DRAFT");

            quizService = new QuizService(quizRepo, questionRepo, mock(AnswerOptionRepository.class),
                    mock(QuizAttemptRepository.class), mock(QuizAnswerRepository.class), mock(QuizAnswerOptionRepository.class),
                    courseRepo, lessonRepo, mock(EnrollmentRepository.class), mock(UserRepository.class), null);

            lessonService = new LessonManagementService(courseRepo, lessonRepo, matRepo,
                    mock(EnrollmentRepository.class), mock(UserRepository.class), mock(EntityManager.class));
        }

        @Test
        @DisplayName("Order Index: Move question down uses buffer (>10000) to ensure zero unique constraint violation")
        void testMoveQuestionUsesBuffer() {
            when(courseRepo.findById(100)).thenReturn(Optional.of(testCourse));
            when(quizRepo.findByQuizIdAndCourse_CourseId(200, 100)).thenReturn(Optional.of(testQuiz));

            Question q1 = new Question();
            q1.setQuestionId(1);
            q1.setOrderIndex(1);

            Question q2 = new Question();
            q2.setQuestionId(2);
            q2.setOrderIndex(2);

            when(questionRepo.findByQuiz_QuizIdOrderByOrderIndexAsc(200)).thenReturn(List.of(q1, q2));

            List<Integer> q1OrderHistory = new ArrayList<>();
            List<Integer> q2OrderHistory = new ArrayList<>();

            doAnswer(inv -> {
                Question saved = inv.getArgument(0);
                if (saved.getQuestionId() == 1) q1OrderHistory.add(saved.getOrderIndex());
                if (saved.getQuestionId() == 2) q2OrderHistory.add(saved.getOrderIndex());
                return saved;
            }).when(questionRepo).saveAndFlush(any(Question.class));

            quizService.moveQuestion(100, 200, 1, "down", 10);

            // Step 1: q1 moved to 10001
            // Step 2: q2 moved to 1
            // Step 3: q1 moved to 2
            assertEquals(List.of(10001, 2), q1OrderHistory, "q1 must move to buffer >10000 before target order 2");
            assertEquals(List.of(1), q2OrderHistory, "q2 must move to order 1 while q1 is in buffer");
        }

        @Test
        @DisplayName("Order Index: Delete question re-indexes remaining items using 2-pass buffering")
        void testDeleteQuestionReindexUsesTwoPassBuffering() {
            when(courseRepo.findById(100)).thenReturn(Optional.of(testCourse));
            when(quizRepo.findByQuizIdAndCourse_CourseId(200, 100)).thenReturn(Optional.of(testQuiz));

            Question q1 = new Question();
            q1.setQuestionId(1);
            q1.setOrderIndex(1);

            Question q2 = new Question();
            q2.setQuestionId(2);
            q2.setQuiz(testQuiz);
            q2.setOptions(new ArrayList<>());
            q2.setOrderIndex(2);

            Question q3 = new Question();
            q3.setQuestionId(3);
            q3.setOrderIndex(3);

            when(questionRepo.findById(2)).thenReturn(Optional.of(q2));
            when(questionRepo.findByQuiz_QuizIdOrderByOrderIndexAsc(200)).thenReturn(List.of(q1, q3));

            List<List<Integer>> batchSaves = new ArrayList<>();
            doAnswer(inv -> {
                List<Question> savedList = inv.getArgument(0);
                batchSaves.add(savedList.stream().map(Question::getOrderIndex).toList());
                return savedList;
            }).when(questionRepo).saveAllAndFlush(any());

            quizService.deleteQuestion(100, 200, 2, 10);

            // Batch 1: buffer pass (10001, 10002)
            // Batch 2: final contiguous pass (1, 2)
            assertEquals(2, batchSaves.size(), "Must execute 2-pass saveAllAndFlush");
            assertEquals(List.of(10001, 10002), batchSaves.get(0), "Pass 1 must move to buffer >10000");
            assertEquals(List.of(1, 2), batchSaves.get(1), "Pass 2 must normalize to 1, 2");
        }

        @Test
        @DisplayName("Order Index: Add material with gaps uses max(orderIndex)+1 rather than count+1")
        void testAddMaterialUsesMaxOrderNotCount() {
            Lesson lesson = new Lesson();
            lesson.setLessonId(40);
            lesson.setCourse(testCourse);

            Material m1 = new Material();
            m1.setMaterialId(10);
            m1.setOrderIndex(1);

            Material m5 = new Material();
            m5.setMaterialId(50);
            m5.setOrderIndex(5); // gap between 1 and 5

            when(courseRepo.findLockedById(100)).thenReturn(Optional.of(testCourse));
            when(lessonRepo.findByLessonIdAndCourse_CourseId(40, 100)).thenReturn(Optional.of(lesson));
            when(matRepo.findByLesson_LessonIdOrderByOrderIndexAsc(40)).thenReturn(List.of(m1, m5));

            MaterialForm form = new MaterialForm();
            form.setTitle("Resource 6");
            form.setType("DOCUMENT");
            form.setFileUrl("https://example.com/file.pdf");

            lessonService.addMaterial(100, 40, 10, form);

            ArgumentCaptor<Material> captor = ArgumentCaptor.forClass(Material.class);
            verify(matRepo).save(captor.capture());
            assertEquals(6, captor.getValue().getOrderIndex(), "Order index should be max(5)+1=6, NOT size(2)+1=3");
        }

        @Test
        @DisplayName("Order Index: Delete material re-indexes remaining items using 2-pass buffering")
        void testDeleteMaterialReindexesUsingTwoPassBuffering() {
            Lesson lesson = new Lesson();
            lesson.setLessonId(40);
            lesson.setCourse(testCourse);

            when(courseRepo.findById(100)).thenReturn(Optional.of(testCourse));
            when(lessonRepo.findByLessonIdAndCourse_CourseId(40, 100)).thenReturn(Optional.of(lesson));

            Material m1 = new Material();
            m1.setMaterialId(10);
            m1.setLesson(lesson);
            m1.setOrderIndex(1);

            Material m2 = new Material();
            m2.setMaterialId(20);
            m2.setLesson(lesson);
            m2.setOrderIndex(2);

            Material m3 = new Material();
            m3.setMaterialId(30);
            m3.setLesson(lesson);
            m3.setOrderIndex(3);

            when(matRepo.findById(20)).thenReturn(Optional.of(m2));
            when(matRepo.findByLesson_LessonIdOrderByOrderIndexAsc(40)).thenReturn(List.of(m1, m3));

            List<List<Integer>> batchSaves = new ArrayList<>();
            doAnswer(inv -> {
                List<Material> savedList = inv.getArgument(0);
                batchSaves.add(savedList.stream().map(Material::getOrderIndex).toList());
                return savedList;
            }).when(matRepo).saveAllAndFlush(any());

            lessonService.deleteMaterial(100, 40, 20, 10);

            assertEquals(2, batchSaves.size(), "Must execute 2-pass saveAllAndFlush");
            assertEquals(List.of(10001, 10002), batchSaves.get(0), "Pass 1 must move to buffer >10000");
            assertEquals(List.of(1, 2), batchSaves.get(1), "Pass 2 must normalize to 1, 2");
        }

        @Test
        @DisplayName("Order Index: Delete lesson re-indexes remaining items using 2-pass buffering")
        void testDeleteLessonReindexesUsingTwoPassBuffering() {
            Lesson l1 = new Lesson();
            l1.setLessonId(41);
            l1.setCourse(testCourse);
            l1.setOrderIndex(1);

            Lesson l2 = new Lesson();
            l2.setLessonId(42);
            l2.setCourse(testCourse);
            l2.setOrderIndex(2);

            Lesson l3 = new Lesson();
            l3.setLessonId(43);
            l3.setCourse(testCourse);
            l3.setOrderIndex(3);

            when(courseRepo.findById(100)).thenReturn(Optional.of(testCourse));
            when(courseRepo.findLockedById(100)).thenReturn(Optional.of(testCourse));
            when(lessonRepo.findByLessonIdAndCourse_CourseId(42, 100)).thenReturn(Optional.of(l2));
            when(lessonRepo.findByCourse_CourseIdOrderByOrderIndexAsc(100)).thenReturn(List.of(l1, l3));

            List<List<Integer>> batchSaves = new ArrayList<>();
            doAnswer(inv -> {
                List<Lesson> savedList = inv.getArgument(0);
                batchSaves.add(savedList.stream().map(Lesson::getOrderIndex).toList());
                return savedList;
            }).when(lessonRepo).saveAllAndFlush(any());

            lessonService.deleteLesson(100, 42, 10);

            assertEquals(2, batchSaves.size(), "Must execute 2-pass saveAllAndFlush");
            assertEquals(List.of(10001, 10002), batchSaves.get(0), "Pass 1 must move to buffer >10000");
            assertEquals(List.of(1, 2), batchSaves.get(1), "Pass 2 must normalize to 1, 2");
        }
    }

    // =========================================================================
    // MISSION 4: ADVERSARIAL TEST 4 (ASSIGNMENT VALIDATION)
    // =========================================================================
    @Nested
    @DisplayName("Adversarial Test 4: Assignment Validation Edge Cases")
    class AssignmentValidationAdversarialTests {

        private AssignmentRepository assignments;
        private SubmissionRepository submissions;
        private GradeRepository grades;
        private CourseRepository courses;
        private LessonRepository lessons;
        private EnrollmentRepository enrollments;
        private UserRepository users;
        private AssignmentService assignmentService;
        private Validator validator;

        private Users instructor;
        private Users student;
        private Course course;

        @BeforeEach
        void setUp() {
            assignments = mock(AssignmentRepository.class);
            submissions = mock(SubmissionRepository.class);
            grades = mock(GradeRepository.class);
            courses = mock(CourseRepository.class);
            lessons = mock(LessonRepository.class);
            enrollments = mock(EnrollmentRepository.class);
            users = mock(UserRepository.class);

            assignmentService = new AssignmentService(assignments, submissions, grades, courses, lessons, enrollments, users);

            instructor = new Users();
            instructor.setUserId(1);
            student = new Users();
            student.setUserId(2);

            course = new Course();
            course.setCourseId(10);
            course.setInstructor(instructor);

            when(courses.findById(10)).thenReturn(Optional.of(course));
            when(users.findById(1)).thenReturn(Optional.of(instructor));
            when(users.findById(2)).thenReturn(Optional.of(student));

            validator = Validation.buildDefaultValidatorFactory().getValidator();
        }

        @Test
        @DisplayName("Assignment Validation: Submitting assignment before unlockAt throws CONFLICT (409)")
        void testSubmittingBeforeUnlockAtThrowsConflict() {
            Enrollment enrollment = new Enrollment();
            enrollment.setStatus("ACTIVE");
            when(enrollments.findByStudent_UserIdAndCourse_CourseId(2, 10)).thenReturn(Optional.of(enrollment));

            Assignment assignment = new Assignment();
            assignment.setAssignmentId(50);
            assignment.setCourse(course);
            assignment.setStatus("PUBLISHED");
            assignment.setDueDate(LocalDateTime.now().plusDays(2));
            assignment.setUnlockAt(LocalDateTime.now().plusHours(1)); // 1 hour in the future
            assignment.setMaxAttempts(1);

            when(assignments.findByAssignmentIdAndCourse_CourseId(50, 10)).thenReturn(Optional.of(assignment));

            SubmissionForm form = new SubmissionForm();
            form.setAnswerText("Early submission attempt");

            CourseActionException ex = assertThrows(CourseActionException.class,
                    () -> assignmentService.submit(10, 50, 2, form));
            assertEquals(HttpStatus.CONFLICT, ex.getStatus());
            assertTrue(ex.getMessage().contains("chưa đến thời gian mở khóa"), "Error message should mention unlock time");
        }

        @Test
        @DisplayName("Assignment Validation: Creating assignment with allowResubmit=false and maxAttempts=2 fails Bean Validation")
        void testCreatingAssignmentWithAllowResubmitFalseAndMaxAttemptsTwoFailsValidation() {
            AssignmentForm form = new AssignmentForm();
            form.setTitle("Adversarial Assignment");
            form.setDueDate("2026-11-10T10:00");
            form.setMaxScore(BigDecimal.valueOf(100));
            form.setAllowResubmit(false);
            form.setMaxAttempts(2); // Inconsistent with allowResubmit = false!

            Set<ConstraintViolation<AssignmentForm>> violations = validator.validate(form);
            assertFalse(violations.isEmpty(), "Violations must not be empty for invalid attempt combination");
            boolean foundAttemptViolation = violations.stream()
                    .anyMatch(v -> v.getPropertyPath().toString().equals("attemptsValid")
                            || v.getMessage().contains("số lần nộp tối đa phải từ 2 trở lên"));
            assertTrue(foundAttemptViolation, "Must flag violation on isAttemptsValid()");
        }

        @Test
        @DisplayName("Assignment Validation: Creating assignment with unlockAt > dueDate fails validation (BAD_REQUEST 400)")
        void testCreatingAssignmentWithUnlockAfterDueDateThrowsBadRequest() {
            AssignmentForm form = new AssignmentForm();
            form.setTitle("Invalid Dates Assignment");
            form.setDueDate("2026-11-10T10:00");
            form.setUnlockAt("2026-11-10T12:00"); // 2 hours after due date!
            form.setMaxScore(BigDecimal.valueOf(100));

            CourseActionException ex = assertThrows(CourseActionException.class,
                    () -> assignmentService.create(10, 1, form));
            assertEquals(HttpStatus.BAD_REQUEST, ex.getStatus());
            assertTrue(ex.getMessage().contains("unlockAt") && ex.getMessage().contains("dueDate"),
                    "Error message should mention unlockAt and dueDate constraint violation");
        }

        @Test
        @DisplayName("Assignment Validation: Creating assignment with lockAt < dueDate fails validation (BAD_REQUEST 400)")
        void testCreatingAssignmentWithLockBeforeDueDateThrowsBadRequest() {
            AssignmentForm form = new AssignmentForm();
            form.setTitle("Invalid Lock Date Assignment");
            form.setDueDate("2026-11-10T10:00");
            form.setLockAt("2026-11-10T08:00"); // 2 hours before due date!
            form.setMaxScore(BigDecimal.valueOf(100));

            CourseActionException ex = assertThrows(CourseActionException.class,
                    () -> assignmentService.create(10, 1, form));
            assertEquals(HttpStatus.BAD_REQUEST, ex.getStatus());
            assertTrue(ex.getMessage().contains("lockAt") && ex.getMessage().contains("dueDate"),
                    "Error message should mention lockAt and dueDate constraint violation");
        }

        @Test
        @DisplayName("Assignment Validation: Creating assignment with allowResubmit=true and maxAttempts=1 fails Bean Validation")
        void testCreatingAssignmentWithAllowResubmitTrueAndMaxAttemptsOneFailsValidation() {
            AssignmentForm form = new AssignmentForm();
            form.setTitle("Adversarial Assignment 2");
            form.setDueDate("2026-11-10T10:00");
            form.setMaxScore(BigDecimal.valueOf(100));
            form.setAllowResubmit(true);
            form.setMaxAttempts(1); // Inconsistent with allowResubmit = true!

            Set<ConstraintViolation<AssignmentForm>> violations = validator.validate(form);
            assertFalse(violations.isEmpty(), "Violations must not be empty for invalid attempt combination");
            boolean foundAttemptViolation = violations.stream()
                    .anyMatch(v -> v.getPropertyPath().toString().equals("attemptsValid")
                            || v.getMessage().contains("số lần nộp tối đa phải từ 2 trở lên"));
            assertTrue(foundAttemptViolation, "Must flag violation on isAttemptsValid()");
        }

        @Test
        @DisplayName("Assignment Validation: Submitting assignment after lockAt throws CONFLICT (409)")
        void testSubmittingAfterLockAtThrowsConflict() {
            Enrollment enrollment = new Enrollment();
            enrollment.setStatus("ACTIVE");
            when(enrollments.findByStudent_UserIdAndCourse_CourseId(2, 10)).thenReturn(Optional.of(enrollment));

            Assignment assignment = new Assignment();
            assignment.setAssignmentId(51);
            assignment.setCourse(course);
            assignment.setStatus("PUBLISHED");
            assignment.setDueDate(LocalDateTime.now().minusDays(2));
            assignment.setLockAt(LocalDateTime.now().minusHours(1)); // Locked 1 hour ago
            assignment.setMaxAttempts(1);

            when(assignments.findByAssignmentIdAndCourse_CourseId(51, 10)).thenReturn(Optional.of(assignment));

            SubmissionForm form = new SubmissionForm();
            form.setAnswerText("Late submission attempt");

            CourseActionException ex = assertThrows(CourseActionException.class,
                    () -> assignmentService.submit(10, 51, 2, form));
            assertEquals(HttpStatus.CONFLICT, ex.getStatus());
            assertTrue(ex.getMessage().contains("đã bị khóa"), "Error message should mention assignment is locked");
        }
    }
}
