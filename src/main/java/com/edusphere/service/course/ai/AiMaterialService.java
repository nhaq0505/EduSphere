package com.edusphere.service.course.ai;

import com.edusphere.dto.course.ai.AiMaterialEditForm;
import com.edusphere.dto.course.ai.AiMaterialGenerateRequestDto;
import com.edusphere.dto.course.ai.AiMaterialResultDto;
import com.edusphere.dto.course.ai.AiMaterialTaskResponseDto;
import com.edusphere.entity.course.Course;
import com.edusphere.entity.course.Lesson;
import com.edusphere.entity.course.LessonAiMaterial;
import com.edusphere.repository.course.CourseRepository;
import com.edusphere.repository.course.EnrollmentRepository;
import com.edusphere.repository.course.LessonAiMaterialRepository;
import com.edusphere.repository.course.LessonRepository;
import com.edusphere.service.course.CourseActionException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.io.File;
import java.time.LocalDateTime;
import java.util.Objects;
import java.util.Optional;

@Slf4j
@Service
@RequiredArgsConstructor
public class AiMaterialService {

    private final LessonAiMaterialRepository aiMaterialRepository;
    private final LessonRepository lessonRepository;
    private final CourseRepository courseRepository;
    private final EnrollmentRepository enrollmentRepository;
    private final AiMaterialClient aiClient;

    @Value("${bunny.stream.library-id:800127}")
    private String bunnyLibraryId;

    @Value("${bunny.stream.api-key:}")
    private String bunnyApiKey;

    @Value("${app.upload.base-dir:${user.home}/edusphere/uploads}")
    private String baseUploadDir;

    // ──────────────────────────────────────────────────────────
    // 1. KHỞI TẠO TÁC VỤ AI
    // ──────────────────────────────────────────────────────────

    @Transactional
    public AiMaterialTaskResponseDto startGeneration(Integer courseId, Integer lessonId, Integer currentUserId, boolean force) {
        Lesson lesson = validateInstructorAccess(courseId, lessonId, currentUserId);

        // Kiểm tra xem bài học có video hoặc file âm thanh để phân tích không
        boolean hasVideo = (lesson.getVideoUrl() != null && !lesson.getVideoUrl().isBlank())
                || (lesson.getBunnyVideoId() != null && !lesson.getBunnyVideoId().isBlank());

        if (!hasVideo) {
            throw new CourseActionException(HttpStatus.BAD_REQUEST,
                    "Bài học chưa có video bài giảng hoặc liên kết âm thanh. Vui lòng thêm video trước khi tạo tài liệu bằng AI.");
        }

        // Kiểm tra bản ghi hiện tại trong database
        Optional<LessonAiMaterial> existingOpt = aiMaterialRepository.findByLesson_LessonId(lessonId);
        if (existingOpt.isPresent() && !force) {
            LessonAiMaterial existing = existingOpt.get();
            if ("COMPLETED".equals(existing.getStatus())) {
                return AiMaterialTaskResponseDto.builder()
                        .taskId(existing.getTaskId())
                        .lessonId(lessonId)
                        .status("COMPLETED")
                        .progress(100)
                        .currentStep("COMPLETED")
                        .message("Tài liệu AI của bài học đã được tạo trước đó.")
                        .build();
            }
            if ("PROCESSING".equals(existing.getStatus()) || "PENDING".equals(existing.getStatus())) {
                // Kiểm tra tiến trình trên Python service
                if (existing.getTaskId() != null) {
                    AiMaterialTaskResponseDto poll = aiClient.checkTaskStatus(existing.getTaskId());
                    if (!"NOT_FOUND".equals(poll.getStatus()) && !"UNKNOWN".equals(poll.getStatus())) {
                        return poll;
                    }
                }
            }
        }

        // Xác định đường dẫn file cục bộ nếu video được upload lên server
        String resolvedFilePath = resolveLocalFilePath(lesson.getVideoUrl());

        // Chuẩn bị payload gửi sang FastAPI
        AiMaterialGenerateRequestDto reqDto = AiMaterialGenerateRequestDto.builder()
                .lessonId(lesson.getLessonId())
                .videoUrl(lesson.getVideoUrl())
                .bunnyVideoId(lesson.getBunnyVideoId())
                .libraryId(bunnyLibraryId)
                .bunnyApiKey(bunnyApiKey)
                .filePath(resolvedFilePath)
                .forceRegenerate(force)
                .build();

        log.info("Gửi yêu cầu tạo tài liệu AI cho bài học {} (videoUrl: {}, bunnyId: {})",
                lessonId, lesson.getVideoUrl(), lesson.getBunnyVideoId());

        // Gửi tới Python Service
        AiMaterialTaskResponseDto response = aiClient.initiateGeneration(reqDto);

        // Lưu / Cập nhật bản ghi trong cơ sở dữ liệu SQL Server
        LessonAiMaterial material = existingOpt.orElseGet(() -> LessonAiMaterial.builder()
                .lesson(lesson)
                .build());

        material.setTaskId(response.getTaskId());
        material.setStatus(response.getStatus() != null ? response.getStatus() : "PENDING");
        material.setErrorMessage(null);
        material.setUpdatedAt(LocalDateTime.now());
        aiMaterialRepository.save(material);

        return response;
    }

    // ──────────────────────────────────────────────────────────
    // 2. THEO DÕI & ĐỒNG BỘ TIẾN TRÌNH (POLLING)
    // ──────────────────────────────────────────────────────────

    @Transactional
    public AiMaterialTaskResponseDto checkAndSyncStatus(Integer courseId, Integer lessonId, Integer currentUserId) {
        validateCourseAccess(courseId, lessonId, currentUserId);

        Optional<LessonAiMaterial> opt = aiMaterialRepository.findByLesson_LessonId(lessonId);
        if (opt.isEmpty()) {
            return AiMaterialTaskResponseDto.builder()
                    .lessonId(lessonId)
                    .status("NOT_FOUND")
                    .progress(0)
                    .currentStep("NOT_STARTED")
                    .message("Chưa có tài liệu AI cho bài học này.")
                    .build();
        }

        LessonAiMaterial material = opt.get();

        // Nếu DB đã hoàn tất hoặc thất bại, trả về ngay không cần gọi Python
        if ("COMPLETED".equals(material.getStatus())) {
            return AiMaterialTaskResponseDto.builder()
                    .taskId(material.getTaskId())
                    .lessonId(lessonId)
                    .status("COMPLETED")
                    .progress(100)
                    .currentStep("COMPLETED")
                    .message("Tài liệu học tập AI đã hoàn thành!")
                    .build();
        }

        if ("FAILED".equals(material.getStatus())) {
            return AiMaterialTaskResponseDto.builder()
                    .taskId(material.getTaskId())
                    .lessonId(lessonId)
                    .status("FAILED")
                    .progress(0)
                    .currentStep("FAILED")
                    .message("Tạo tài liệu AI thất bại.")
                    .error(material.getErrorMessage())
                    .build();
        }

        if (material.getTaskId() == null || material.getTaskId().isBlank()) {
            return AiMaterialTaskResponseDto.builder()
                    .lessonId(lessonId)
                    .status(material.getStatus())
                    .progress(0)
                    .message("Tác vụ chưa có Task ID hợp lệ.")
                    .build();
        }

        // Gọi Python service để cập nhật tiến trình mới nhất
        AiMaterialTaskResponseDto taskStatus = aiClient.checkTaskStatus(material.getTaskId());

        if ("COMPLETED".equals(taskStatus.getStatus())) {
            log.info("Tác vụ {} đã hoàn thành trên Python service, đang lấy kết quả lưu DB...", material.getTaskId());
            AiMaterialResultDto result = aiClient.getTaskResult(material.getTaskId());

            material.setStatus("COMPLETED");
            material.setOriginalTranscript(result.getOriginalTranscript());
            material.setCorrectedTranscript(result.getCorrectedTranscript());
            material.setSummary(result.getSummary());
            material.setKeyPoints(result.getKeyPoints());
            material.setTerms(result.getTerms());
            material.setConclusion(result.getConclusion());
            material.setAiModel(result.getAiModel());
            material.setErrorMessage(null);
            material.setUpdatedAt(LocalDateTime.now());
            aiMaterialRepository.save(material);

            return AiMaterialTaskResponseDto.builder()
                    .taskId(material.getTaskId())
                    .lessonId(lessonId)
                    .status("COMPLETED")
                    .progress(100)
                    .currentStep("COMPLETED")
                    .message("Phân tích bài giảng và tạo tài liệu thành công!")
                    .build();

        } else if ("FAILED".equals(taskStatus.getStatus())) {
            material.setStatus("FAILED");
            material.setErrorMessage(taskStatus.getError() != null ? taskStatus.getError() : taskStatus.getMessage());
            material.setUpdatedAt(LocalDateTime.now());
            aiMaterialRepository.save(material);
        } else if (!"UNKNOWN".equals(taskStatus.getStatus()) && !"DISCONNECTED".equals(taskStatus.getStatus())) {
            // Đang xử lý các bước (EXTRACTING_AUDIO, TRANSCRIBING, CORRECTING, GENERATING)
            if (!"PROCESSING".equals(material.getStatus())) {
                material.setStatus("PROCESSING");
                material.setUpdatedAt(LocalDateTime.now());
                aiMaterialRepository.save(material);
            }
        }

        return taskStatus;
    }

    // ──────────────────────────────────────────────────────────
    // 3. TRUY VẤN TÀI LIỆU AI CỦA BÀI HỌC
    // ──────────────────────────────────────────────────────────

    @Transactional(readOnly = true)
    public Optional<AiMaterialResultDto> getMaterial(Integer courseId, Integer lessonId, Integer currentUserId) {
        validateCourseAccess(courseId, lessonId, currentUserId);

        return aiMaterialRepository.findByLesson_LessonId(lessonId).map(m -> AiMaterialResultDto.builder()
                .id(m.getId())
                .lessonId(m.getLesson().getLessonId())
                .taskId(m.getTaskId())
                .status(m.getStatus())
                .originalTranscript(m.getOriginalTranscript())
                .correctedTranscript(m.getCorrectedTranscript())
                .summary(m.getSummary())
                .keyPoints(m.getKeyPoints())
                .terms(m.getTerms())
                .conclusion(m.getConclusion())
                .aiModel(m.getAiModel())
                .errorMessage(m.getErrorMessage())
                .createdAt(m.getCreatedAt())
                .updatedAt(m.getUpdatedAt())
                .build());
    }

    // ──────────────────────────────────────────────────────────
    // 4. GIẢNG VIÊN CHỈNH SỬA TÀI LIỆU AI
    // ──────────────────────────────────────────────────────────

    @Transactional
    public AiMaterialResultDto updateMaterial(Integer courseId, Integer lessonId, Integer currentUserId, AiMaterialEditForm form) {
        validateInstructorAccess(courseId, lessonId, currentUserId);

        LessonAiMaterial material = aiMaterialRepository.findByLesson_LessonId(lessonId)
                .orElseThrow(() -> new CourseActionException(HttpStatus.NOT_FOUND, "Không tìm thấy tài liệu AI để chỉnh sửa."));

        material.setSummary(form.getSummary());
        material.setKeyPoints(form.getKeyPoints());
        material.setTerms(form.getTerms());
        material.setConclusion(form.getConclusion());
        material.setStatus("COMPLETED");
        material.setUpdatedAt(LocalDateTime.now());
        aiMaterialRepository.save(material);

        log.info("Giảng viên {} đã cập nhật nội dung tài liệu AI cho bài học {}", currentUserId, lessonId);

        return AiMaterialResultDto.builder()
                .id(material.getId())
                .lessonId(lessonId)
                .status("COMPLETED")
                .summary(material.getSummary())
                .keyPoints(material.getKeyPoints())
                .terms(material.getTerms())
                .conclusion(material.getConclusion())
                .updatedAt(material.getUpdatedAt())
                .build();
    }

    // ──────────────────────────────────────────────────────────
    // HELPERS & VALIDATION
    // ──────────────────────────────────────────────────────────

    private Lesson validateInstructorAccess(Integer courseId, Integer lessonId, Integer currentUserId) {
        Course course = courseRepository.findById(courseId)
                .orElseThrow(() -> new CourseActionException(HttpStatus.NOT_FOUND, "Không tìm thấy khóa học"));

        if (!Objects.equals(course.getInstructor().getUserId(), currentUserId)) {
            throw new CourseActionException(HttpStatus.FORBIDDEN, "Bạn không có quyền quản lý bài học của khóa học này.");
        }

        Lesson lesson = lessonRepository.findById(lessonId)
                .orElseThrow(() -> new CourseActionException(HttpStatus.NOT_FOUND, "Không tìm thấy bài học"));

        if (!Objects.equals(lesson.getCourse().getCourseId(), courseId)) {
            throw new CourseActionException(HttpStatus.BAD_REQUEST, "Bài học không thuộc khóa học này.");
        }

        return lesson;
    }

    private void validateCourseAccess(Integer courseId, Integer lessonId, Integer currentUserId) {
        Course course = courseRepository.findById(courseId)
                .orElseThrow(() -> new CourseActionException(HttpStatus.NOT_FOUND, "Không tìm thấy khóa học"));

        Lesson lesson = lessonRepository.findById(lessonId)
                .orElseThrow(() -> new CourseActionException(HttpStatus.NOT_FOUND, "Không tìm thấy bài học"));

        if (!Objects.equals(lesson.getCourse().getCourseId(), courseId)) {
            throw new CourseActionException(HttpStatus.BAD_REQUEST, "Bài học không thuộc khóa học này.");
        }

        // Quyền xem: Giảng viên sở hữu, hoặc bài học xem trước (isPreview), hoặc học viên đã ghi danh
        boolean isOwner = Objects.equals(course.getInstructor().getUserId(), currentUserId);
        boolean isPreview = Boolean.TRUE.equals(lesson.getIsPreview());
        boolean isEnrolled = enrollmentRepository.existsByStudent_UserIdAndCourse_CourseId(currentUserId, courseId);

        if (!isOwner && !isPreview && !isEnrolled) {
            throw new CourseActionException(HttpStatus.FORBIDDEN, "Bạn chưa đăng ký khóa học này để xem tài liệu.");
        }
    }

    private String resolveLocalFilePath(String videoUrl) {
        if (videoUrl == null || videoUrl.isBlank()) return null;

        // Nếu là đường dẫn tệp tuyệt đối trên Windows (VD: D:\...)
        if (videoUrl.contains(":\\") || videoUrl.contains(":/")) {
            File f = new File(videoUrl);
            if (f.exists()) return f.getAbsolutePath();
        }

        // Nếu là upload trong EduSphere (VD: /uploads/videos/... hoặc /EduSphere/uploads/videos/...)
        if (videoUrl.contains("/uploads/")) {
            String sub = videoUrl.substring(videoUrl.indexOf("/uploads/") + "/uploads/".length());
            File f = new File(baseUploadDir, sub.replace("/", File.separator));
            if (f.exists()) return f.getAbsolutePath();
        }

        return null;
    }
}
