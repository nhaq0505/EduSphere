package com.edusphere.service.course;

import com.edusphere.dto.course.MaterialForm;
import com.edusphere.dto.planning.PersonalTaskForm;
import com.edusphere.dto.quiz.QuestionForm;
import com.edusphere.dto.quiz.QuizForm;
import com.edusphere.entity.account.Users;
import com.edusphere.entity.course.AnswerOption;
import com.edusphere.entity.course.Course;
import com.edusphere.entity.course.Enrollment;
import com.edusphere.entity.course.Lesson;
import com.edusphere.entity.course.Material;
import com.edusphere.entity.course.PersonalTask;
import com.edusphere.entity.course.Question;
import com.edusphere.entity.course.Quiz;
import com.edusphere.entity.course.QuizAttempt;
import com.edusphere.entity.course.StudyPlan;
import com.edusphere.repository.account.UserRepository;
import com.edusphere.repository.course.AnswerOptionRepository;
import com.edusphere.repository.course.AssignmentRepository;
import com.edusphere.repository.course.CourseRepository;
import com.edusphere.repository.course.CourseSectionRepository;
import com.edusphere.repository.course.EnrollmentRepository;
import com.edusphere.repository.course.LearningProgressRepository;
import com.edusphere.repository.course.LessonCompletionRepository;
import com.edusphere.repository.course.LessonRepository;
import com.edusphere.repository.course.MaterialRepository;
import com.edusphere.repository.course.PersonalTaskRepository;
import com.edusphere.repository.course.QuestionRepository;
import com.edusphere.repository.course.QuizAnswerOptionRepository;
import com.edusphere.repository.course.QuizAnswerRepository;
import com.edusphere.repository.course.QuizAttemptRepository;
import com.edusphere.repository.course.QuizRepository;
import com.edusphere.repository.course.StudyPlanRepository;
import jakarta.persistence.EntityManager;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

class CoreLogicStabilityTest {

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

    private Course testCourse;
    private Users instructor;
    private Users student;
    private Quiz testQuiz;

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
        instructor.setFullName("Instructor A");

        student = new Users();
        student.setUserId(20);
        student.setFullName("Student B");

        testCourse = new Course();
        testCourse.setCourseId(100);
        testCourse.setTitle("Core Java");
        testCourse.setInstructor(instructor);

        testQuiz = new Quiz();
        testQuiz.setQuizId(200);
        testQuiz.setTitle("Midterm Quiz");
        testQuiz.setCourse(testCourse);
        testQuiz.setCreatedBy(instructor);
        testQuiz.setStatus("PUBLISHED");
    }

    @Test
    void testQuizTimeoutSubmitDoesNotRollbackAndAutoPublishesMCQ() {
        // Prepare attempt with deadline in the past
        QuizAttempt attempt = new QuizAttempt();
        attempt.setAttemptId(501);
        attempt.setCourse(testCourse);
        attempt.setQuiz(testQuiz);
        attempt.setStudent(student);
        attempt.setStatus("IN_PROGRESS");
        attempt.setDeadlineAt(LocalDateTime.now().minusMinutes(10)); // expired

        Enrollment activeEnrollment = new Enrollment();
        activeEnrollment.setStatus("ACTIVE");
        when(enrollmentRepo.findByStudent_UserIdAndCourse_CourseId(20, 100))
                .thenReturn(Optional.of(activeEnrollment));
        when(attemptRepo.findByAttemptIdAndStudent_UserId(501, 20))
                .thenReturn(Optional.of(attempt));

        // Question is MCQ (auto-graded)
        Question q1 = new Question();
        q1.setQuestionId(1);
        q1.setQuiz(testQuiz);
        q1.setType("SINGLE_CHOICE");
        q1.setScore(BigDecimal.TEN);
        q1.setOrderIndex(1);

        AnswerOption opt1 = new AnswerOption();
        opt1.setOptionId(11);
        opt1.setQuestion(q1);
        opt1.setContent("Option A");
        opt1.setCorrect(true);
        opt1.setOrderIndex(1);

        when(questionRepo.findByQuiz_QuizIdOrderByOrderIndexAsc(200)).thenReturn(List.of(q1));
        when(optionRepo.findByQuestion_QuestionIdOrderByOrderIndexAsc(1)).thenReturn(List.of(opt1));
        when(answerRepo.save(any())).thenAnswer(inv -> inv.getArgument(0));
        when(attemptRepo.save(any())).thenAnswer(inv -> inv.getArgument(0));

        // Submit with student answer pointing to option 11
        quizService.submitAttempt(100, 200, 501, 20, Map.of(1, List.of("11")));

        // Verify status moved to SCORED (auto-graded) and resultStatus is PUBLISHED
        assertEquals("SCORED", attempt.getStatus());
        assertEquals("PUBLISHED", attempt.getResultStatus());
        assertNotNull(attempt.getPublishedAt());
        assertNotNull(attempt.getPublishedBy());
        assertEquals(instructor.getUserId(), attempt.getPublishedBy().getUserId());
        assertTrue(attempt.getPublishedAt().isEqual(attempt.getSubmittedAt()) || attempt.getPublishedAt().isAfter(attempt.getSubmittedAt()));
    }

    @Test
    void testQuizScoreAndWindowConstraints() {
        when(courseRepo.findById(100)).thenReturn(Optional.of(testCourse));
        when(quizRepo.findByQuizIdAndCourse_CourseId(200, 100)).thenReturn(Optional.of(testQuiz));

        // Question score <= 0 must fail
        QuestionForm badScoreForm = new QuestionForm();
        badScoreForm.setContent("Test Q");
        badScoreForm.setType("SINGLE_CHOICE");
        badScoreForm.setScore(BigDecimal.ZERO);
        assertThrows(CourseActionException.class, () -> quizService.addQuestion(100, 200, 10, badScoreForm));

        // Quiz window: start after end must fail
        QuizForm badWindowForm = new QuizForm();
        badWindowForm.setTitle("Invalid Dates Quiz");
        badWindowForm.setStartTime("2026-11-10T15:00");
        badWindowForm.setEndTime("2026-11-05T10:00");
        assertThrows(CourseActionException.class, () -> quizService.updateQuiz(100, 200, 10, badWindowForm));
    }

    @Test
    void testQuizMoveQuestionUsesBufferToAvoidUniqueClash() {
        when(courseRepo.findById(100)).thenReturn(Optional.of(testCourse));
        when(quizRepo.findByQuizIdAndCourse_CourseId(200, 100)).thenReturn(Optional.of(testQuiz));

        Question q1 = new Question();
        q1.setQuestionId(1);
        q1.setOrderIndex(1);
        Question q2 = new Question();
        q2.setQuestionId(2);
        q2.setOrderIndex(2);

        when(questionRepo.findByQuiz_QuizIdOrderByOrderIndexAsc(200)).thenReturn(List.of(q1, q2));

        quizService.moveQuestion(100, 200, 1, "down", 10);

        // Verify saveAndFlush called with buffer index
        verify(questionRepo, atLeast(3)).saveAndFlush(any(Question.class));
        assertEquals(2, q1.getOrderIndex());
        assertEquals(1, q2.getOrderIndex());
    }

    @Test
    void testLessonManagementAddMaterialUsesMaxOrder() {
        Lesson lesson = new Lesson();
        lesson.setLessonId(40);
        lesson.setCourse(testCourse);

        Material m1 = new Material();
        m1.setMaterialId(1);
        m1.setOrderIndex(1);
        Material m3 = new Material();
        m3.setMaterialId(3);
        m3.setOrderIndex(3);

        MaterialRepository matRepo = mock(MaterialRepository.class);
        LessonRepository lesRepo = mock(LessonRepository.class);
        CourseRepository crRepo = mock(CourseRepository.class);
        when(crRepo.findLockedById(100)).thenReturn(Optional.of(testCourse));
        when(lesRepo.findByLessonIdAndCourse_CourseId(40, 100)).thenReturn(Optional.of(lesson));
        when(matRepo.findByLesson_LessonIdOrderByOrderIndexAsc(40)).thenReturn(List.of(m1, m3));

        LessonManagementService lesService = new LessonManagementService(crRepo, lesRepo, matRepo,
                mock(EnrollmentRepository.class), userRepo, mock(EntityManager.class));

        MaterialForm form = new MaterialForm();
        form.setTitle("Doc 4");
        form.setType("DOCUMENT");
        form.setFileUrl("https://example.com/doc.pdf");

        lesService.addMaterial(100, 40, 10, form);

        ArgumentCaptor<Material> captor = ArgumentCaptor.forClass(Material.class);
        verify(matRepo).save(captor.capture());
        assertEquals(4, captor.getValue().getOrderIndex()); // max(3) + 1 = 4, NOT size(2) + 1 = 3
    }

    @Test
    void testLearningServicePreviewAllowsUnenrolledStudent() {
        Lesson previewLesson = new Lesson();
        previewLesson.setLessonId(55);
        previewLesson.setTitle("Free Preview");
        previewLesson.setOrderIndex(1);
        previewLesson.setContent("Preview content");
        previewLesson.setIsPreview(true);
        previewLesson.setCourse(testCourse);

        LessonRepository lesRepo = mock(LessonRepository.class);
        EnrollmentRepository enrRepo = mock(EnrollmentRepository.class);
        CourseRepository cRepo = mock(CourseRepository.class);

        when(lesRepo.findByCourse_CourseIdAndStatusOrderByOrderIndexAsc(100, "PUBLISHED"))
                .thenReturn(List.of(previewLesson));
        when(enrRepo.findByStudent_UserIdAndCourse_CourseId(99, 100))
                .thenReturn(Optional.empty()); // not enrolled
        when(cRepo.findById(100)).thenReturn(Optional.of(testCourse));

        LearningService lService = new LearningService(lesRepo, enrRepo, mock(LessonCompletionRepository.class),
                mock(MaterialRepository.class), userRepo, null, cRepo);

        var context = lService.getStudyContext(100, 55, 99);
        assertNotNull(context);
        assertEquals("Preview content", context.lessonContent());
        assertTrue(context.isPreviewMode());
    }

    @Test
    void testLearningProgressClamping() {
        LearningProgressRepository progRepo = mock(LearningProgressRepository.class);
        LessonRepository lesRepo = mock(LessonRepository.class);
        LessonCompletionRepository compRepo = mock(LessonCompletionRepository.class);
        CourseRepository crRepo = mock(CourseRepository.class);
        UserRepository uRepo = mock(UserRepository.class);

        when(uRepo.findById(20)).thenReturn(Optional.of(student));
        when(crRepo.findById(100)).thenReturn(Optional.of(testCourse));
        // total 5 lessons, but completions mock returns 7 (e.g. from previously unpublished lessons)
        when(lesRepo.countByCourse_CourseIdAndStatus(100, "PUBLISHED")).thenReturn(5L);
        when(compRepo.countByStudent_UserIdAndCourse_CourseId(20, 100)).thenReturn(7L);
        when(progRepo.findByStudent_UserIdAndCourse_CourseId(20, 100)).thenReturn(Optional.empty());

        LearningProgressService progService = new LearningProgressService(progRepo, mock(com.edusphere.repository.course.LearningHistoryRepository.class),
                mock(EnrollmentRepository.class), crRepo, lesRepo, compRepo, mock(AssignmentRepository.class), mock(QuizRepository.class), uRepo);

        progService.updateProgressOnLessonCompleted(20, 100, 1);

        ArgumentCaptor<com.edusphere.entity.course.LearningProgress> captor = ArgumentCaptor.forClass(com.edusphere.entity.course.LearningProgress.class);
        verify(progRepo).save(captor.capture());
        var savedProgress = captor.getValue();
        assertEquals(5, savedProgress.getTotalLessons());
        assertEquals(5, savedProgress.getCompletedLessons()); // Clamped to 5
        assertEquals(new BigDecimal("100.00"), savedProgress.getPercentComplete()); // Clamped to 100%
    }

    @Test
    void testStudyPlanServiceStatusAndReferenceValidation() {
        StudyPlan plan = new StudyPlan();
        plan.setPlanId(88);
        plan.setStudent(student);
        plan.setTitle("Sprint 1");

        StudyPlanRepository planRepo = mock(StudyPlanRepository.class);
        PersonalTaskRepository taskRepo = mock(PersonalTaskRepository.class);
        EnrollmentRepository enrRepo = mock(EnrollmentRepository.class);
        CourseRepository crRepo = mock(CourseRepository.class);
        UserRepository uRepo = mock(UserRepository.class);

        when(planRepo.findByPlanIdAndStudent_UserId(88, 20)).thenReturn(Optional.of(plan));
        when(uRepo.findById(20)).thenReturn(Optional.of(student));

        StudyPlanService planService = new StudyPlanService(planRepo, taskRepo, uRepo, enrRepo, crRepo,
                mock(LessonRepository.class), mock(AssignmentRepository.class), mock(QuizRepository.class));

        // Multiple references (lesson + quiz) must throw BAD_REQUEST
        PersonalTaskForm multiRefForm = new PersonalTaskForm();
        multiRefForm.setTitle("Review lesson & quiz");
        multiRefForm.setPlannedStartAt("2026-11-10T09:00");
        multiRefForm.setPlannedEndAt("2026-11-10T10:00");
        multiRefForm.setCourseId(100);
        multiRefForm.setRelatedLessonId(1);
        multiRefForm.setRelatedQuizId(2);

        assertThrows(CourseActionException.class, () -> planService.createTask(88, 20, multiRefForm));

        // Reference without courseId must throw BAD_REQUEST
        PersonalTaskForm noCourseRefForm = new PersonalTaskForm();
        noCourseRefForm.setTitle("Review lesson");
        noCourseRefForm.setPlannedStartAt("2026-11-10T09:00");
        noCourseRefForm.setPlannedEndAt("2026-11-10T10:00");
        noCourseRefForm.setRelatedLessonId(1);

        assertThrows(CourseActionException.class, () -> planService.createTask(88, 20, noCourseRefForm));
    }
}
