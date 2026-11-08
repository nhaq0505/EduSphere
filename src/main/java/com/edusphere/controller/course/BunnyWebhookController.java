package com.edusphere.controller.course;

import com.edusphere.entity.course.Lesson;
import com.edusphere.repository.course.LessonRepository;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;
import java.util.logging.Logger;

/**
 * Nhận Webhook từ Bunny Stream khi video hoàn tất xử lý.
 *
 * Bunny gọi POST về URL này với body JSON:
 * {
 *   "VideoGuid": "...",
 *   "Status": 4,          // 4 = Finished/READY, 5 = Error
 *   "LibraryId": 800127
 * }
 *
 * Endpoint này cần được whitelist trong SecurityConfig (permitAll)
 * và nên được bảo vệ bằng webhook secret nếu Bunny hỗ trợ.
 */
@Controller
@RequestMapping("/webhooks/bunny")
public class BunnyWebhookController {

    private static final Logger log = Logger.getLogger(BunnyWebhookController.class.getName());

    @Value("${bunny.stream.library-id:800127}")
    private String expectedLibraryId;

    @Value("${bunny.stream.webhook-secret:}")
    private String webhookSecret;

    private final LessonRepository lessonRepository;

    public BunnyWebhookController(LessonRepository lessonRepository) {
        this.lessonRepository = lessonRepository;
    }

    @PostMapping
    @ResponseBody
    @Transactional
    public ResponseEntity<String> handleWebhook(
            @RequestBody String body,
            @RequestHeader(value = "Bunny-Signature", required = false) String signature,
            @RequestParam(value = "secret", required = false) String querySecret) {

        if (webhookSecret != null && !webhookSecret.isBlank()) {
            String provided = (signature != null && !signature.isBlank()) ? signature.trim()
                    : (querySecret != null ? querySecret.trim() : "");
            if (!webhookSecret.trim().equals(provided)) {
                log.warning("Bunny Webhook: chữ ký hoặc webhook secret không hợp lệ.");
                return ResponseEntity.status(401).body("Unauthorized");
            }
        }

        log.info("Bunny Webhook received: " + body);

        // Parse VideoGuid và Status từ JSON body thủ công
        String videoGuid = extractField(body, "VideoGuid");
        String statusStr = extractField(body, "Status");
        String libraryStr = extractField(body, "LibraryId");

        if (videoGuid == null || statusStr == null) {
            log.warning("Bunny Webhook: thiếu VideoGuid hoặc Status trong payload");
            return ResponseEntity.badRequest().body("Missing fields");
        }

        // Kiểm tra đúng library
        if (libraryStr != null && !expectedLibraryId.equals(libraryStr.trim())) {
            log.warning("Bunny Webhook: LibraryId không khớp — nhận " + libraryStr + ", mong " + expectedLibraryId);
            return ResponseEntity.ok("Ignored");
        }

        // Map Bunny status code sang internal status
        int bunnyStatus;
        try {
            bunnyStatus = Integer.parseInt(statusStr.trim());
        } catch (NumberFormatException e) {
            return ResponseEntity.badRequest().body("Invalid status");
        }

        String newStatus = switch (bunnyStatus) {
            case 4       -> "READY";
            case 5, 6   -> "FAILED";
            default      -> "PROCESSING";
        };

        // Tìm lesson theo bunny_video_id và cập nhật trạng thái
        List<Lesson> lessons = lessonRepository.findByBunnyVideoId(videoGuid);
        if (lessons.isEmpty()) {
            log.info("Bunny Webhook: không tìm thấy lesson với guid=" + videoGuid);
            return ResponseEntity.ok("Not found");
        }
        for (Lesson lesson : lessons) {
            lesson.setVideoStatus(newStatus);
            lesson.setUpdatedAt(LocalDateTime.now());
            lessonRepository.save(lesson);
            log.info("Bunny Webhook: cập nhật lesson " + lesson.getLessonId()
                    + " → " + newStatus + " (guid=" + videoGuid + ")");
        }

        return ResponseEntity.ok("OK");
    }

    private String extractField(String json, String field) {
        String key = "\"" + field + "\"";
        int idx = json.indexOf(key);
        if (idx < 0) return null;
        int colon = json.indexOf(':', idx + key.length());
        if (colon < 0) return null;
        int start = colon + 1;
        while (start < json.length() && (json.charAt(start) == ' ' || json.charAt(start) == '\t')) start++;
        if (start >= json.length()) return null;
        if (json.charAt(start) == '"') {
            int end = json.indexOf('"', start + 1);
            return end > start ? json.substring(start + 1, end) : null;
        } else {
            int end = start;
            while (end < json.length() && ",}] \t\r\n".indexOf(json.charAt(end)) < 0) end++;
            return json.substring(start, end);
        }
    }
}
