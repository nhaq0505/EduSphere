package com.edusphere.service.course.ai;

import com.edusphere.dto.course.ai.AiMaterialEditForm;
import com.edusphere.dto.course.ai.AiMaterialGenerateRequestDto;
import com.edusphere.dto.course.ai.AiMaterialResultDto;
import com.edusphere.dto.course.ai.AiMaterialTaskResponseDto;
import com.edusphere.entity.account.Users;
import com.edusphere.entity.course.Course;
import com.edusphere.entity.course.Lesson;
import com.edusphere.entity.course.LessonAiMaterial;
import com.edusphere.repository.course.CourseRepository;
import com.edusphere.repository.course.EnrollmentRepository;
import com.edusphere.repository.course.LessonAiMaterialRepository;
import com.edusphere.repository.course.LessonRepository;
import com.edusphere.service.course.CourseActionException;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.http.HttpStatus;

import java.time.LocalDateTime;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class AiMaterialServiceTest {

    @Mock
    private LessonAiMaterialRepository aiMaterialRepository;

    @Mock
    private LessonRepository lessonRepository;

    @Mock
    private CourseRepository courseRepository;

    @Mock
    private EnrollmentRepository enrollmentRepository;

    @Mock
    private AiMaterialClient aiClient;

    private AiMaterialService aiMaterialService;

    private Course sampleCourse;
    private Lesson sampleLesson;
    private Users instructor;

    @BeforeEach
    void setUp() {
        aiMaterialService = new AiMaterialService(
                aiMaterialRepository,
                lessonRepository,
                courseRepository,
                enrollmentRepository,
                aiClient
        );

        instructor = new Users();
        instructor.setUserId(10);
        instructor.setEmail("instructor@edusphere.com");

        sampleCourse = new Course();
        sampleCourse.setCourseId(100);
        sampleCourse.setTitle("Lập trình Java căn bản");
        sampleCourse.setInstructor(instructor);

        sampleLesson = new Lesson();
        sampleLesson.setLessonId(501);
        sampleLesson.setTitle("Bài 3: Ghi chú trong Java");
        sampleLesson.setCourse(sampleCourse);
        sampleLesson.setVideoUrl("https://player.mediadelivery.net/embed/800127/guid-1234");
        sampleLesson.setBunnyVideoId("guid-1234");
        sampleLesson.setVideoStatus("READY");
    }

    @Test
    @DisplayName("Giảng viên tạo tài liệu AI thành công: Gửi tới Python và lưu trạng thái PENDING vào database")
    void startGeneration_success() {
        when(courseRepository.findById(100)).thenReturn(Optional.of(sampleCourse));
        when(lessonRepository.findById(501)).thenReturn(Optional.of(sampleLesson));
        when(aiMaterialRepository.findByLesson_LessonId(501)).thenReturn(Optional.empty());

        AiMaterialTaskResponseDto clientResp = AiMaterialTaskResponseDto.builder()
                .taskId("task_abc_123")
                .lessonId(501)
                .status("PENDING")
                .progress(0)
                .message("Đã tiếp nhận yêu cầu.")
                .build();

        when(aiClient.initiateGeneration(any(AiMaterialGenerateRequestDto.class))).thenReturn(clientResp);

        AiMaterialTaskResponseDto result = aiMaterialService.startGeneration(100, 501, 10, false);

        assertNotNull(result);
        assertEquals("task_abc_123", result.getTaskId());
        assertEquals("PENDING", result.getStatus());
        verify(aiMaterialRepository).save(any(LessonAiMaterial.class));
    }

    @Test
    @DisplayName("Giảng viên không sở hữu khóa học bị từ chối 403 FORBIDDEN")
    void startGeneration_forbiddenIfNotOwner() {
        when(courseRepository.findById(100)).thenReturn(Optional.of(sampleCourse));

        CourseActionException ex = assertThrows(CourseActionException.class, () ->
                aiMaterialService.startGeneration(100, 501, 999, false)
        );

        assertEquals(HttpStatus.FORBIDDEN, ex.getStatus());
        verify(aiClient, never()).initiateGeneration(any());
    }

    @Test
    @DisplayName("Bài học không có video bị từ chối 400 BAD_REQUEST")
    void startGeneration_badRequestIfNoVideo() {
        sampleLesson.setVideoUrl(null);
        sampleLesson.setBunnyVideoId(null);

        when(courseRepository.findById(100)).thenReturn(Optional.of(sampleCourse));
        when(lessonRepository.findById(501)).thenReturn(Optional.of(sampleLesson));

        CourseActionException ex = assertThrows(CourseActionException.class, () ->
                aiMaterialService.startGeneration(100, 501, 10, false)
        );

        assertEquals(HttpStatus.BAD_REQUEST, ex.getStatus());
        verify(aiClient, never()).initiateGeneration(any());
    }

    @Test
    @DisplayName("Đồng bộ tiến trình: Khi Python hoàn thành, tự động lưu kết quả vào database")
    void checkAndSyncStatus_completedSavesToDatabase() {
        LessonAiMaterial material = LessonAiMaterial.builder()
                .id(1)
                .lesson(sampleLesson)
                .taskId("task_abc_123")
                .status("PROCESSING")
                .build();

        when(courseRepository.findById(100)).thenReturn(Optional.of(sampleCourse));
        when(lessonRepository.findById(501)).thenReturn(Optional.of(sampleLesson));
        when(aiMaterialRepository.findByLesson_LessonId(501)).thenReturn(Optional.of(material));

        AiMaterialTaskResponseDto statusResp = AiMaterialTaskResponseDto.builder()
                .taskId("task_abc_123")
                .lessonId(501)
                .status("COMPLETED")
                .progress(100)
                .build();

        AiMaterialResultDto resultDto = AiMaterialResultDto.builder()
                .taskId("task_abc_123")
                .summary("Tóm tắt bài học ghi chú...")
                .keyPoints("- Ghi chú 1 dòng //\n- Ghi chú nhiều dòng /* */")
                .terms("- Single-line comment: Ghi chú 1 dòng")
                .conclusion("Ghi chú giúp mã nguồn dễ hiểu hơn.")
                .aiModel("qwen2.5:3b + whisper-small")
                .build();

        when(aiClient.checkTaskStatus("task_abc_123")).thenReturn(statusResp);
        when(aiClient.getTaskResult("task_abc_123")).thenReturn(resultDto);

        AiMaterialTaskResponseDto syncResult = aiMaterialService.checkAndSyncStatus(100, 501, 10);

        assertNotNull(syncResult);
        assertEquals("COMPLETED", syncResult.getStatus());
        assertEquals("COMPLETED", material.getStatus());
        assertEquals("Tóm tắt bài học ghi chú...", material.getSummary());
        assertEquals("- Ghi chú 1 dòng //\n- Ghi chú nhiều dòng /* */", material.getKeyPoints());
        verify(aiMaterialRepository).save(material);
    }

    @Test
    @DisplayName("Giảng viên chỉnh sửa nội dung tài liệu AI thành công")
    void updateMaterial_success() {
        LessonAiMaterial material = LessonAiMaterial.builder()
                .id(1)
                .lesson(sampleLesson)
                .status("COMPLETED")
                .summary("Tóm tắt cũ")
                .createdAt(LocalDateTime.now())
                .build();

        when(courseRepository.findById(100)).thenReturn(Optional.of(sampleCourse));
        when(lessonRepository.findById(501)).thenReturn(Optional.of(sampleLesson));
        when(aiMaterialRepository.findByLesson_LessonId(501)).thenReturn(Optional.of(material));

        AiMaterialEditForm editForm = AiMaterialEditForm.builder()
                .summary("Tóm tắt mới đã được giảng viên biên tập")
                .keyPoints("- Kiến thức trọng tâm mới")
                .terms("- Thuật ngữ mới")
                .conclusion("- Kết luận mới")
                .build();

        AiMaterialResultDto updated = aiMaterialService.updateMaterial(100, 501, 10, editForm);

        assertNotNull(updated);
        assertEquals("Tóm tắt mới đã được giảng viên biên tập", material.getSummary());
        assertEquals("- Kiến thức trọng tâm mới", material.getKeyPoints());
        verify(aiMaterialRepository).save(material);
    }
}

