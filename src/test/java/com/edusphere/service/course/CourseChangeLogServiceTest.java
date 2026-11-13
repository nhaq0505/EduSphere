package com.edusphere.service.course;

import com.edusphere.controller.course.AdminCourseChangeLogController;
import com.edusphere.dto.course.CourseChangeLogView;
import com.edusphere.dto.course.CourseForm;
import com.edusphere.dto.course.LessonForm;
import com.edusphere.dto.course.MaterialForm;
import com.edusphere.dto.course.SectionForm;
import com.edusphere.dto.quiz.QuestionForm;
import com.edusphere.dto.quiz.QuizForm;
import com.edusphere.entity.account.Users;
import com.edusphere.entity.course.AnswerOption;
import com.edusphere.entity.course.Course;
import com.edusphere.entity.course.CourseChangeLog;
import com.edusphere.entity.course.CourseSection;
import com.edusphere.entity.course.Lesson;
import com.edusphere.entity.course.Material;
import com.edusphere.entity.course.Question;
import com.edusphere.entity.course.Quiz;
import com.edusphere.repository.account.UserRepository;
import com.edusphere.repository.course.AnswerOptionRepository;
import com.edusphere.repository.course.CategoryRepository;
import com.edusphere.repository.course.CourseChangeLogRepository;
import com.edusphere.repository.course.CourseRepository;
import com.edusphere.repository.course.CourseReviewRepository;
import com.edusphere.repository.course.CourseSectionRepository;
import com.edusphere.repository.course.EnrollmentRepository;
import com.edusphere.repository.course.LessonRepository;
import com.edusphere.repository.course.MaterialRepository;
import com.edusphere.repository.course.QuestionRepository;
import com.edusphere.repository.course.QuizAnswerOptionRepository;
import com.edusphere.repository.course.QuizAnswerRepository;
import com.edusphere.repository.course.QuizAttemptRepository;
import com.edusphere.repository.course.QuizRepository;

import jakarta.persistence.EntityManager;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.security.access.prepost.PreAuthorize;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

class CourseChangeLogServiceTest {

    private CourseChangeLogRepository logRepository;
    private CourseRepository courseRepository;
    private CourseSectionRepository sectionRepository;
    private LessonRepository lessonRepository;
    private MaterialRepository materialRepository;
    private QuizRepository quizRepository;
    private QuestionRepository questionRepository;
    private AnswerOptionRepository answerOptionRepository;
    private UserRepository userRepository;
    private FileUploadService fileUploadService;

    private CourseChangeLogService changeLogService;
    private CourseManagementService courseManagementService;
    private CourseSectionService sectionService;
    private LessonManagementService lessonService;
    private QuizService quizService;

    private final List<CourseChangeLog> savedLogs = new ArrayList<>();
    private Users instructor;
    private Course course;

    @BeforeEach
    void setUp() {
        logRepository = mock(CourseChangeLogRepository.class);
        courseRepository = mock(CourseRepository.class);
        sectionRepository = mock(CourseSectionRepository.class);
        lessonRepository = mock(LessonRepository.class);
        materialRepository = mock(MaterialRepository.class);
        quizRepository = mock(QuizRepository.class);
        questionRepository = mock(QuestionRepository.class);
        answerOptionRepository = mock(AnswerOptionRepository.class);
        userRepository = mock(UserRepository.class);
        fileUploadService = mock(FileUploadService.class);

        when(logRepository.save(any(CourseChangeLog.class))).thenAnswer(inv -> {
            CourseChangeLog l = inv.getArgument(0);
            l.setLogId((long) (savedLogs.size() + 1));
            savedLogs.add(l);
            return l;
        });

        changeLogService = new CourseChangeLogService(
                logRepository, courseRepository, sectionRepository,
                lessonRepository, materialRepository, quizRepository,
                questionRepository, answerOptionRepository, fileUploadService);

        courseManagementService = new CourseManagementService(
                courseRepository, mock(CourseReviewRepository.class),
                mock(EnrollmentRepository.class), mock(CategoryRepository.class),
                userRepository, lessonRepository);
        courseManagementService.setChangeLogService(changeLogService);

        sectionService = new CourseSectionService(sectionRepository, courseRepository, lessonRepository);
        sectionService.setChangeLogService(changeLogService);

        lessonService = new LessonManagementService(
                courseRepository, lessonRepository, materialRepository,
                mock(EnrollmentRepository.class), userRepository, mock(EntityManager.class));
        lessonService.setChangeLogService(changeLogService);

        quizService = new QuizService(
                quizRepository, questionRepository, answerOptionRepository,
                mock(QuizAttemptRepository.class), mock(QuizAnswerRepository.class),
                mock(QuizAnswerOptionRepository.class), courseRepository,
                lessonRepository, mock(EnrollmentRepository.class), userRepository);
        quizService.setChangeLogService(changeLogService);

        instructor = new Users();
        instructor.setUserId(10);
        instructor.setFullName("Giảng viên Nguyễn Văn A");
        instructor.setEmail("teacher@edusphere.vn");

        course = new Course();
        course.setCourseId(100);
        course.setTitle("Vật lí đại cương");
        course.setInstructor(instructor);
        course.setStatus("DRAFT");
        course.setVersionNo(1);

        when(userRepository.findById(10)).thenReturn(Optional.of(instructor));
        when(userRepository.getReferenceById(10)).thenReturn(instructor);
        when(courseRepository.findById(100)).thenReturn(Optional.of(course));
        when(courseRepository.findLockedById(100)).thenReturn(Optional.of(course));
    }

    // 1. Giáo viên tạo khóa học mới -> Admin nhìn thấy lịch sử
    @Test
    void test1_teacherCreatesCourse_recordsChangeLog() {
        CourseForm form = new CourseForm();
        form.setTitle("Khóa học Spring Boot");
        form.setDescription("Mô tả chi tiết");
        form.setLevel("BEGINNER");
        form.setPrice(BigDecimal.valueOf(500000));

        when(courseRepository.save(any(Course.class))).thenAnswer(inv -> {
            Course c = inv.getArgument(0);
            c.setCourseId(101);
            return c;
        });

        Integer id = courseManagementService.create(10, form);
        assertEquals(101, id);
        assertEquals(1, savedLogs.size());
        CourseChangeLog log = savedLogs.get(0);
        assertEquals("COURSE", log.getEntityType());
        assertEquals("CREATE", log.getActionType());
        assertEquals(101, log.getCourseId());
        assertTrue(log.getSummary().contains("Khóa học Spring Boot"));
    }

    // 2. Giáo viên thêm chương -> Admin nhìn thấy chương mới
    @Test
    void test2_teacherAddsChapter_recordsChangeLog() {
        SectionForm form = new SectionForm();
        form.setTitle("Chương 1: Mở đầu");
        form.setDescription("Giới thiệu Vật lí");
        when(sectionRepository.save(any(CourseSection.class))).thenAnswer(inv -> {
            CourseSection s = inv.getArgument(0);
            s.setSectionId(201);
            return s;
        });

        sectionService.createSection(100, 10, form);
        assertEquals(1, savedLogs.size());
        CourseChangeLog log = savedLogs.get(0);
        assertEquals("CHAPTER", log.getEntityType());
        assertEquals("CREATE", log.getActionType());
        assertEquals(201, log.getEntityId());
        assertTrue(log.getSummary().contains("Chương 1: Mở đầu"));
    }

    // 3 & 4. Giáo viên thêm bài học + video -> Admin nhìn thấy bài học mới và thông tin video
    @Test
    void test3_and_4_teacherAddsLessonWithVideo_recordsLessonAndVideoLogs() {
        LessonForm form = new LessonForm();
        form.setTitle("Bài 1: Làm quen với Vật lí");
        form.setLessonType("VIDEO");
        form.setVideoUrl("https://player.mediadelivery.net/embed/12345/guid-abc-111");
        form.setVideoDuration(20);
        form.setAllowSeek(false);
        form.setQuizRequiresVideo(true);
        form.setMinWatchPercent(80);
        form.setContent("Nội dung ghi chú bài 1");

        when(lessonRepository.save(any(Lesson.class))).thenAnswer(inv -> {
            Lesson l = inv.getArgument(0);
            l.setLessonId(301);
            return l;
        });

        lessonService.create(100, 10, form);
        assertEquals(2, savedLogs.size());
        assertEquals("LESSON", savedLogs.get(0).getEntityType());
        assertEquals("CREATE", savedLogs.get(0).getActionType());
        assertEquals("VIDEO", savedLogs.get(1).getEntityType());
        assertEquals("VIDEO_UPLOAD", savedLogs.get(1).getActionType());
        assertTrue(savedLogs.get(1).getAfterData().contains("guid-abc-111"));
    }

    // 5. Giáo viên thay thế video -> Admin thấy được video cũ và video mới
    @Test
    void test5_teacherReplacesVideo_recordsOldAndNewVideoInChangeLog() {
        Lesson existing = new Lesson();
        existing.setLessonId(301);
        existing.setCourse(course);
        existing.setTitle("Bài 1: Làm quen với Vật lí");
        existing.setLessonType("VIDEO");
        existing.setVideoUrl("https://player.mediadelivery.net/embed/12345/old-guid-111");
        existing.setBunnyVideoId("old-guid-111");
        existing.setOrderIndex(1);
        existing.setStatus("PUBLISHED");

        when(lessonRepository.findByLessonIdAndCourse_CourseId(301, 100)).thenReturn(Optional.of(existing));
        when(lessonRepository.findByCourse_CourseIdOrderByOrderIndexAsc(100)).thenReturn(List.of(existing));

        LessonForm form = new LessonForm();
        form.setTitle("Bài 1: Làm quen với Vật lí");
        form.setLessonType("VIDEO");
        form.setVideoUrl("https://player.mediadelivery.net/embed/12345/new-guid-222");
        form.setOrderIndex(1);

        lessonService.edit(100, 301, 10, form);

        CourseChangeLog videoLog = savedLogs.stream()
                .filter(l -> "VIDEO".equals(l.getEntityType()))
                .findFirst().orElseThrow();
        assertEquals("VIDEO_REPLACE", videoLog.getActionType());
        assertTrue(videoLog.getBeforeData().contains("old-guid-111"));
        assertTrue(videoLog.getAfterData().contains("new-guid-222"));
    }

    // 6 & 7. Giáo viên thêm tài liệu & cập nhật tài liệu -> Admin xem được thông tin trước và sau
    @Test
    void test6_and_7_teacherAddsAndUpdatesMaterial_recordsLogs() {
        Lesson existing = new Lesson();
        existing.setLessonId(301);
        existing.setCourse(course);
        existing.setTitle("Bài 1");
        when(lessonRepository.findByLessonIdAndCourse_CourseId(301, 100)).thenReturn(Optional.of(existing));

        MaterialForm addForm = new MaterialForm();
        addForm.setTitle("Slide chương 1 v1");
        addForm.setType("DOCUMENT");
        addForm.setFileUrl("/uploads/materials/slide_v1.pdf");

        Material savedMat = new Material();
        savedMat.setMaterialId(401);
        savedMat.setLesson(existing);
        savedMat.setTitle("Slide chương 1 v1");
        savedMat.setType("DOCUMENT");
        savedMat.setFileUrl("/uploads/materials/slide_v1.pdf");
        savedMat.setOrderIndex(1);

        when(materialRepository.save(any(Material.class))).thenAnswer(inv -> {
            Material m = inv.getArgument(0);
            if (m.getMaterialId() == null) m.setMaterialId(401);
            return m;
        });
        when(materialRepository.findById(401)).thenReturn(Optional.of(savedMat));

        lessonService.addMaterial(100, 301, 10, addForm);
        assertEquals(1, savedLogs.size());
        assertEquals("DOCUMENT", savedLogs.get(0).getEntityType());
        assertEquals("CREATE", savedLogs.get(0).getActionType());

        MaterialForm updateForm = new MaterialForm();
        updateForm.setTitle("Slide chương 1 v2 (Mới)");
        updateForm.setType("DOCUMENT");
        updateForm.setFileUrl("/uploads/materials/slide_v2.pdf");

        lessonService.updateMaterial(100, 301, 401, 10, updateForm);
        assertEquals(2, savedLogs.size());
        CourseChangeLog updateLog = savedLogs.get(1);
        assertEquals("DOCUMENT", updateLog.getEntityType());
        assertEquals("UPDATE", updateLog.getActionType());
        assertTrue(updateLog.getBeforeData().contains("slide_v1.pdf"));
        assertTrue(updateLog.getAfterData().contains("slide_v2.pdf"));
    }

    // 8 & 9. Giáo viên thêm quiz và chỉnh sửa câu hỏi -> Admin xem được nội dung cũ và mới
    @Test
    void test8_and_9_teacherCreatesQuizAndUpdatesQuestion_recordsBeforeAndAfter() {
        QuizForm qForm = new QuizForm();
        qForm.setTitle("Kiểm tra Chương 1");
        qForm.setTimeLimitMinutes(15);
        qForm.setMaxAttempts(3);
        when(quizRepository.save(any(Quiz.class))).thenAnswer(inv -> {
            Quiz q = inv.getArgument(0);
            q.setQuizId(501);
            return q;
        });

        Integer quizId = quizService.create(100, 10, qForm);
        assertEquals(501, quizId);
        assertEquals("QUIZ", savedLogs.get(0).getEntityType());
        assertEquals("CREATE", savedLogs.get(0).getActionType());

        Quiz quiz = new Quiz();
        quiz.setQuizId(501);
        quiz.setCourse(course);
        quiz.setTitle("Kiểm tra Chương 1");
        when(quizRepository.findByQuizIdAndCourse_CourseId(501, 100)).thenReturn(Optional.of(quiz));

        Question existingQ = new Question();
        existingQ.setQuestionId(601);
        existingQ.setQuiz(quiz);
        existingQ.setOrderIndex(1);
        existingQ.setContent("Đơn vị đo độ dài trong hệ SI là gì?");
        existingQ.setType("SINGLE_CHOICE");
        existingQ.setScore(BigDecimal.ONE);

        AnswerOption opt1 = new AnswerOption();
        opt1.setOptionId(1);
        opt1.setContent("Mét (m)");
        opt1.setCorrect(true);
        opt1.setOrderIndex(1);

        when(questionRepository.findById(601)).thenReturn(Optional.of(existingQ));
        when(answerOptionRepository.findByQuestion_QuestionIdOrderByOrderIndexAsc(601))
                .thenReturn(List.of(opt1));

        QuestionForm editQForm = new QuestionForm();
        editQForm.setContent("Đơn vị đo thời gian chuẩn trong hệ SI là gì?");
        editQForm.setType("SINGLE_CHOICE");
        editQForm.setScore(BigDecimal.valueOf(2));
        editQForm.setOptionContents(List.of("Giây (s)", "Phút"));
        editQForm.setOptionCorrects(List.of(true, false));

        quizService.updateQuestion(100, 501, 601, 10, editQForm);

        CourseChangeLog qLog = savedLogs.get(1);
        assertEquals("QUESTION", qLog.getEntityType());
        assertEquals("UPDATE", qLog.getActionType());
        assertTrue(qLog.getBeforeData().contains("Đơn vị đo độ dài"));
        assertTrue(qLog.getAfterData().contains("Đơn vị đo thời gian"));
    }

    // 10. Giáo viên xóa nội dung -> Admin vẫn xem được lịch sử và thông báo tài nguyên đã xóa
    @Test
    void test10_teacherDeletesLesson_adminStillViewsHistoricalSnapshot() {
        Lesson existing = new Lesson();
        existing.setLessonId(301);
        existing.setCourse(course);
        existing.setTitle("Bài học bị xóa");
        existing.setContent("Nội dung quan trọng trước khi xóa");
        existing.setOrderIndex(1);

        when(lessonRepository.findByLessonIdAndCourse_CourseId(301, 100)).thenReturn(Optional.of(existing));
        when(lessonRepository.findByCourse_CourseIdOrderByOrderIndexAsc(100)).thenReturn(List.of());

        lessonService.deleteLesson(100, 301, 10);

        assertEquals(1, savedLogs.size());
        CourseChangeLog delLog = savedLogs.get(0);
        assertEquals("DELETE", delLog.getActionType());
        when(logRepository.findById(delLog.getLogId())).thenReturn(Optional.of(delLog));

        CourseChangeLogView detail = changeLogService.getLogDetail(delLog.getLogId());
        assertFalse(detail.isResourceExists());
        assertNotNull(detail.getResourceStatusMessage());
        assertEquals("Nội dung quan trọng trước khi xóa", detail.getOldLessonContent());
    }

    // 11. Người không có quyền ADMIN không truy cập được Controller quản trị
    @Test
    void test11_adminControllerRequiresAdministratorRole() {
        PreAuthorize annotation = AdminCourseChangeLogController.class.getAnnotation(PreAuthorize.class);
        assertNotNull(annotation);
        assertEquals("hasRole('ADMINISTRATOR')", annotation.value());
    }

    // 12. Khi nghiệp vụ thất bại -> không ghi nhận lịch sử giả
    @Test
    void test12_failedOperationDoesNotRecordFakeLog() {
        LessonForm invalidForm = new LessonForm();
        invalidForm.setTitle("   "); // Tiêu đề rỗng -> lỗi nghiệp vụ

        assertThrows(CourseActionException.class, () -> lessonService.create(100, 10, invalidForm));
        assertTrue(savedLogs.isEmpty());
    }

    // 13. Khóa học lần đầu gửi duyệt vs Cập nhật lần 2 sau khi đã duyệt
    @Test
    void test13_firstSubmissionDoesNotShowChangeState_secondUpdateShowsChanges() {
        Lesson l1 = new Lesson();
        l1.setLessonId(301);
        l1.setCourse(course);
        l1.setTitle("Bài 1");
        l1.setLessonType("QUIZ");
        l1.setStatus("DRAFT");
        l1.setOrderIndex(1);
        when(lessonRepository.findByCourse_CourseIdOrderByOrderIndexAsc(100)).thenReturn(List.of(l1));

        // Lần đầu gửi lên (chưa từng được phê duyệt)
        assertFalse(changeLogService.isUpdateAfterApproval(100));
        var initialMap = changeLogService.buildCourseLessonReviewMap(100);
        assertEquals("INITIAL", initialMap.get(301).getChangeState());
        assertTrue(initialMap.get(301).getChangeLogs().isEmpty());

        // Sau khi khóa học đã được phê duyệt lần 1 và giảng viên chỉnh sửa bổ sung lần 2
        course.setApprovedAt(java.time.LocalDateTime.now().minusMinutes(5));
        l1.setStatus("PUBLISHED");
        Lesson l2 = new Lesson();
        l2.setLessonId(302);
        l2.setCourse(course);
        l2.setTitle("Bài 2 bổ sung");
        l2.setLessonType("VIDEO");
        l2.setStatus("DRAFT");
        l2.setOrderIndex(2);
        l2.setCreatedAt(java.time.LocalDateTime.now());
        when(lessonRepository.findByCourse_CourseIdOrderByOrderIndexAsc(100)).thenReturn(List.of(l1, l2));

        assertTrue(changeLogService.isUpdateAfterApproval(100));
        var updateMap = changeLogService.buildCourseLessonReviewMap(100);
        assertEquals("PUBLISHED", updateMap.get(301).getChangeState());
        assertEquals("NEW", updateMap.get(302).getChangeState());
    }
}
