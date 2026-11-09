package com.edusphere.controller.course;

import com.edusphere.entity.course.Lesson;
import com.edusphere.repository.course.LessonRepository;
import com.edusphere.security.CustomUserDetails;
import com.edusphere.service.course.BunnyStreamService;
import com.edusphere.service.course.CourseActionException;
import com.edusphere.service.course.LessonManagementService;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;
import java.util.Set;

/**
 * REST Controller xử lý upload video bài giảng lên Bunny Stream.
 *
 * Endpoint:
 *   POST  /instructor/videos/upload          — upload video, trả về bunnyVideoId + playerUrl
 *   GET   /instructor/videos/{lessonId}/status — poll trạng thái xử lý từ Bunny
 *   POST  /instructor/videos/{lessonId}/webhook-refresh — cập nhật trạng thái thủ công
 *   POST  /webhooks/bunny                    — Bunny gọi vào khi video READY (public)
 *
 * API Key tuyệt đối KHÔNG trả về cho frontend.
 */
@Controller
@RequestMapping("/instructor/videos")
@PreAuthorize("hasRole('INSTRUCTOR')")
public class VideoUploadController {

    private static final Set<String> ALLOWED_VIDEO_MIME = Set.of(
            "video/mp4", "video/webm", "video/quicktime", "video/x-msvideo",
            "video/x-matroska", "video/mpeg", "application/octet-stream");

    private static final Set<String> ALLOWED_VIDEO_EXT = Set.of(
            "mp4", "webm", "mov", "avi", "mkv", "mpeg", "mpg");

    private static final long MAX_VIDEO_SIZE = 2L * 1024 * 1024 * 1024; // 2 GB

    private final BunnyStreamService bunnyService;
    private final LessonRepository lessonRepository;
    private final LessonManagementService lessonService;

    public VideoUploadController(BunnyStreamService bunnyService,
                                 LessonRepository lessonRepository,
                                 LessonManagementService lessonService) {
        this.bunnyService   = bunnyService;
        this.lessonRepository = lessonRepository;
        this.lessonService  = lessonService;
    }

    // ─────────────────────────────────────────────────────────
    // Upload video lên Bunny Stream
    // ─────────────────────────────────────────────────────────

    /**
     * POST /instructor/videos/upload
     *
     * Nhận file video từ giảng viên, upload lên Bunny Stream.
     * - Nếu đã có lessonId (sửa bài học): lưu trực tiếp GUID và trạng thái PROCESSING vào DB.
     * - Nếu chưa có lessonId (đang tạo bài học mới): trả về playerUrl và bunnyVideoId để điền vào form,
     *   khi giảng viên bấm "Lưu bài học" sẽ lưu đồng bộ vào DB.
     */
    @PostMapping("/upload")
    @ResponseBody
    @Transactional
    public ResponseEntity<Map<String, Object>> uploadVideo(
            @RequestParam(value = "lessonId", required = false) Integer lessonId,
            @RequestParam(value = "title", required = false) String title,
            @RequestParam("file") MultipartFile file,
            @AuthenticationPrincipal CustomUserDetails user) {

        Map<String, Object> resp = new HashMap<>();

        // TC02: File rỗng
        if (file == null || file.isEmpty()) {
            resp.put("success", false);
            resp.put("message", "Vui lòng chọn file video để tải lên.");
            return ResponseEntity.badRequest().body(resp);
        }

        // TC03: Định dạng không hợp lệ
        String originalName = file.getOriginalFilename() != null ? file.getOriginalFilename() : "";
        String ext = originalName.contains(".")
                ? originalName.substring(originalName.lastIndexOf('.') + 1).toLowerCase()
                : "";
        if (!ALLOWED_VIDEO_EXT.contains(ext)) {
            resp.put("success", false);
            resp.put("message", "Định dạng video không hỗ trợ. Cho phép: MP4, WebM, MOV, AVI, MKV.");
            return ResponseEntity.badRequest().body(resp);
        }

        // TC04: Vượt giới hạn 2GB
        if (file.getSize() > MAX_VIDEO_SIZE) {
            resp.put("success", false);
            resp.put("message", "File video quá lớn. Giới hạn tối đa là 2GB.");
            return ResponseEntity.status(HttpStatus.PAYLOAD_TOO_LARGE).body(resp);
        }

        // TC08: Bunny chưa cấu hình
        if (!bunnyService.isConfigured()) {
            resp.put("success", false);
            resp.put("message", "Bunny Stream chưa được cấu hình. Liên hệ quản trị viên để thiết lập BUNNY_API_KEY.");
            return ResponseEntity.status(HttpStatus.SERVICE_UNAVAILABLE).body(resp);
        }

        // Nếu có lessonId thì kiểm tra bài học tồn tại và quyền sở hữu của giảng viên
        Lesson lesson = null;
        if (lessonId != null) {
            lesson = lessonRepository.findById(lessonId).orElse(null);
            if (lesson == null) {
                resp.put("success", false);
                resp.put("message", "Không tìm thấy bài học.");
                return ResponseEntity.status(HttpStatus.NOT_FOUND).body(resp);
            }
            if (!lesson.getCourse().getInstructor().getUserId().equals(user.getUserId())) {
                resp.put("success", false);
                resp.put("message", "Bạn không có quyền upload video cho bài học này.");
                return ResponseEntity.status(HttpStatus.FORBIDDEN).body(resp);
            }
        }

        try {
            // Xác định tiêu đề video
            String videoTitle = (title != null && !title.isBlank())
                    ? title.trim()
                    : (lesson != null ? lesson.getTitle() : originalName);

            if (lesson != null) {
                lesson.setVideoStatus("UPLOADING");
                lesson.setUpdatedAt(LocalDateTime.now());
                lessonRepository.save(lesson);
            }

            // Bước 1: Tạo video entry trên Bunny → nhận GUID
            String videoGuid = bunnyService.createVideo(videoTitle);

            // Bước 2: Upload file lên Bunny (streaming, không buffer toàn bộ RAM)
            bunnyService.uploadVideo(videoGuid, file);

            String playerUrl = bunnyService.buildPlayerUrl(videoGuid);

            // Bước 3: Nếu đã có bài học trong DB thì lưu GUID + trạng thái PROCESSING ngay
            if (lesson != null) {
                lesson.setBunnyVideoId(videoGuid);
                lesson.setVideoUrl(playerUrl);
                lesson.setVideoStatus("PROCESSING");
                lesson.setLessonType("VIDEO");
                lesson.setUpdatedAt(LocalDateTime.now());
                lessonRepository.save(lesson);
            }

            resp.put("success", true);
            resp.put("bunnyVideoId", videoGuid);
            resp.put("playerUrl", playerUrl);
            resp.put("videoStatus", "PROCESSING");
            resp.put("message", "Upload thành công! Video đang được Bunny xử lý, bạn có thể lưu bài học ngay.");
            return ResponseEntity.ok(resp);

        } catch (CourseActionException ex) {
            if (lesson != null) {
                lesson.setVideoStatus("FAILED");
                lesson.setUpdatedAt(LocalDateTime.now());
                lessonRepository.save(lesson);
            }
            resp.put("success", false);
            resp.put("message", ex.getMessage());
            return ResponseEntity.status(ex.getStatus()).body(resp);
        } catch (Exception ex) {
            if (lesson != null) {
                lesson.setVideoStatus("FAILED");
                lesson.setUpdatedAt(LocalDateTime.now());
                lessonRepository.save(lesson);
            }
            resp.put("success", false);
            resp.put("message", "Đã xảy ra lỗi khi upload video: " + ex.getMessage());
            return ResponseEntity.internalServerError().body(resp);
        }
    }

    /**
     * GET /instructor/videos/guid/{videoGuid}/status
     *
     * Kiểm tra trạng thái xử lý video trực tiếp trên Bunny theo videoGuid
     * (dùng khi giảng viên vừa upload video ở màn hình Tạo bài học mới chưa có lessonId).
     */
    @GetMapping("/guid/{videoGuid}/status")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> getVideoStatusByGuid(@PathVariable String videoGuid) {
        Map<String, Object> resp = new HashMap<>();
        String status = bunnyService.isConfigured() ? bunnyService.getVideoStatus(videoGuid) : "PROCESSING";
        resp.put("success", true);
        resp.put("videoStatus", status);
        resp.put("bunnyVideoId", videoGuid);
        resp.put("playerUrl", bunnyService.buildPlayerUrl(videoGuid));
        resp.put("hasVideo", true);
        return ResponseEntity.ok(resp);
    }

    // ─────────────────────────────────────────────────────────
    // Poll trạng thái video từ Bunny
    // ─────────────────────────────────────────────────────────

    /**
     * GET /instructor/videos/{lessonId}/status
     *
     * Giảng viên (hoặc JS frontend) poll trạng thái xử lý video trên Bunny.
     * Cập nhật trạng thái trong DB nếu Bunny đã READY hoặc FAILED.
     */
    @GetMapping("/{lessonId}/status")
    @ResponseBody
    @Transactional
    public ResponseEntity<Map<String, Object>> getVideoStatus(
            @PathVariable Integer lessonId,
            @AuthenticationPrincipal CustomUserDetails user) {

        Map<String, Object> resp = new HashMap<>();
        Lesson lesson = lessonRepository.findById(lessonId).orElse(null);
        if (lesson == null) {
            resp.put("success", false);
            resp.put("message", "Không tìm thấy bài học.");
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(resp);
        }
        if (!lesson.getCourse().getInstructor().getUserId().equals(user.getUserId())) {
            resp.put("success", false);
            resp.put("message", "Không có quyền truy cập.");
            return ResponseEntity.status(HttpStatus.FORBIDDEN).body(resp);
        }

        String guid = lesson.getBunnyVideoId();
        if (guid == null || guid.isBlank()) {
            resp.put("success", true);
            resp.put("videoStatus", lesson.getVideoStatus() != null ? lesson.getVideoStatus() : "NONE");
            resp.put("hasVideo", false);
            return ResponseEntity.ok(resp);
        }

        // Chỉ poll Bunny nếu đang PROCESSING (tránh gọi thừa khi đã READY/FAILED)
        String currentStatus = lesson.getVideoStatus();
        if ("PROCESSING".equals(currentStatus) || "UPLOADING".equals(currentStatus)) {
            if (bunnyService.isConfigured()) {
                String bunnyStatus = bunnyService.getVideoStatus(guid);
                if (!bunnyStatus.equals(currentStatus)) {
                    lesson.setVideoStatus(bunnyStatus);
                    lesson.setUpdatedAt(LocalDateTime.now());
                    lessonRepository.save(lesson);
                    currentStatus = bunnyStatus;
                }
            }
        }

        resp.put("success", true);
        resp.put("videoStatus", currentStatus);
        resp.put("bunnyVideoId", guid);
        resp.put("playerUrl", bunnyService.buildPlayerUrl(guid));
        resp.put("hasVideo", true);
        return ResponseEntity.ok(resp);
    }
}
