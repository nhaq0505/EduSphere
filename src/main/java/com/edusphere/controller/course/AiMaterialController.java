package com.edusphere.controller.course;

import com.edusphere.dto.course.ai.AiMaterialEditForm;
import com.edusphere.dto.course.ai.AiMaterialResultDto;
import com.edusphere.dto.course.ai.AiMaterialTaskResponseDto;
import com.edusphere.security.CustomUserDetails;
import com.edusphere.service.course.ai.AiMaterialService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.Optional;

/**
 * REST API Controller phục vụ việc tích hợp tính năng AI phân tích bài giảng:
 * - Giảng viên: Tạo tài liệu bằng AI, theo dõi tiến trình, xem chi tiết và chỉnh sửa.
 * - Học viên: Xem tài liệu học tập AI trong trang học bài.
 */
@RestController
@RequiredArgsConstructor
public class AiMaterialController {

    private final AiMaterialService aiMaterialService;

    // ──────────────────────────────────────────────────────────
    // GIẢNG VIÊN (INSTRUCTOR) API
    // ──────────────────────────────────────────────────────────

    /**
     * POST /instructor/courses/{courseId}/lessons/{lessonId}/ai-materials/generate
     * Khởi tạo hoặc tạo lại tài liệu AI từ video bài giảng
     */
    @PostMapping("/instructor/courses/{courseId}/lessons/{lessonId}/ai-materials/generate")
    @PreAuthorize("hasRole('INSTRUCTOR')")
    public ResponseEntity<AiMaterialTaskResponseDto> generateMaterial(
            @PathVariable Integer courseId,
            @PathVariable Integer lessonId,
            @RequestParam(value = "force", defaultValue = "false") boolean force,
            @AuthenticationPrincipal CustomUserDetails user) {

        AiMaterialTaskResponseDto response = aiMaterialService.startGeneration(courseId, lessonId, user.getUserId(), force);
        return ResponseEntity.ok(response);
    }

    /**
     * GET /instructor/courses/{courseId}/lessons/{lessonId}/ai-materials/status
     * Kiểm tra và đồng bộ tiến trình xử lý thực tế của tác vụ AI
     */
    @GetMapping("/instructor/courses/{courseId}/lessons/{lessonId}/ai-materials/status")
    @PreAuthorize("hasRole('INSTRUCTOR')")
    public ResponseEntity<AiMaterialTaskResponseDto> getTaskStatus(
            @PathVariable Integer courseId,
            @PathVariable Integer lessonId,
            @AuthenticationPrincipal CustomUserDetails user) {

        AiMaterialTaskResponseDto response = aiMaterialService.checkAndSyncStatus(courseId, lessonId, user.getUserId());
        return ResponseEntity.ok(response);
    }

    /**
     * GET /instructor/courses/{courseId}/lessons/{lessonId}/ai-materials
     * Lấy đầy đủ nội dung tài liệu AI của bài học để hiển thị hoặc chỉnh sửa
     */
    @GetMapping("/instructor/courses/{courseId}/lessons/{lessonId}/ai-materials")
    @PreAuthorize("hasRole('INSTRUCTOR')")
    public ResponseEntity<AiMaterialResultDto> getInstructorMaterial(
            @PathVariable Integer courseId,
            @PathVariable Integer lessonId,
            @AuthenticationPrincipal CustomUserDetails user) {

        Optional<AiMaterialResultDto> material = aiMaterialService.getMaterial(courseId, lessonId, user.getUserId());
        return material.map(ResponseEntity::ok)
                .orElseGet(() -> ResponseEntity.notFound().build());
    }

    /**
     * POST /instructor/courses/{courseId}/lessons/{lessonId}/ai-materials/edit
     * Giảng viên lưu các chỉnh sửa vào 4 phần: summary, keyPoints, terms, conclusion
     */
    @PostMapping("/instructor/courses/{courseId}/lessons/{lessonId}/ai-materials/edit")
    @PreAuthorize("hasRole('INSTRUCTOR')")
    public ResponseEntity<AiMaterialResultDto> editMaterial(
            @PathVariable Integer courseId,
            @PathVariable Integer lessonId,
            @RequestBody AiMaterialEditForm form,
            @AuthenticationPrincipal CustomUserDetails user) {

        AiMaterialResultDto updated = aiMaterialService.updateMaterial(courseId, lessonId, user.getUserId(), form);
        return ResponseEntity.ok(updated);
    }

    // ──────────────────────────────────────────────────────────
    // HỌC VIÊN (STUDENT) & CHUNG API
    // ──────────────────────────────────────────────────────────

    /**
     * GET /courses/{courseId}/lessons/{lessonId}/ai-materials
     * Học viên đã ghi danh xem tài liệu AI của bài học trong giao diện học
     */
    @GetMapping("/courses/{courseId}/lessons/{lessonId}/ai-materials")
    @PreAuthorize("hasAnyRole('STUDENT', 'INSTRUCTOR', 'ADMINISTRATOR')")
    public ResponseEntity<AiMaterialResultDto> getStudentMaterial(
            @PathVariable Integer courseId,
            @PathVariable Integer lessonId,
            @AuthenticationPrincipal CustomUserDetails user) {

        Optional<AiMaterialResultDto> material = aiMaterialService.getMaterial(courseId, lessonId, user.getUserId());
        return material.map(ResponseEntity::ok)
                .orElseGet(() -> ResponseEntity.notFound().build());
    }
}

