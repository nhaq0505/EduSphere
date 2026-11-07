package com.edusphere.service.course;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URI;
import java.net.URL;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.time.Duration;
import java.util.logging.Logger;

/**
 * Service tích hợp Bunny Stream API.
 *
 * Quy trình upload video:
 *  1. createVideo(title)      → nhận Bunny Video GUID
 *  2. uploadVideo(guid, file) → stream file lên Bunny (không buffer toàn bộ vào RAM)
 *  3. getVideoStatus(guid)    → poll trạng thái xử lý (PROCESSING / READY / FAILED)
 *
 * API Key tuyệt đối KHÔNG được đưa ra frontend.
 */
@Service
public class BunnyStreamService {

    private static final Logger log = Logger.getLogger(BunnyStreamService.class.getName());

    @Value("${bunny.stream.library-id}")
    private String libraryId;

    @Value("${bunny.stream.api-key:#{null}}")
    private String apiKey;

    @Value("${bunny.stream.api-url:https://video.bunnycdn.com}")
    private String apiUrl;

    @Value("${bunny.stream.player-url:https://player.mediadelivery.net}")
    private String playerUrl;

    // ──────────────────────────────────────────────────────────
    // PUBLIC API
    // ──────────────────────────────────────────────────────────

    /**
     * Bước 1: Tạo entry video trên Bunny Stream, nhận Video GUID.
     *
     * @param title Tiêu đề video
     * @return Bunny Video GUID (UUID string)
     */
    public String createVideo(String title) {
        assertApiKeyConfigured();
        String endpoint = apiUrl + "/library/" + libraryId + "/videos";
        String body = "{\"title\":\"" + escapeJson(title) + "\"}";
        try {
            HttpClient client = HttpClient.newBuilder()
                    .connectTimeout(Duration.ofSeconds(10))
                    .build();
            HttpRequest request = HttpRequest.newBuilder()
                    .uri(URI.create(endpoint))
                    .header("AccessKey", apiKey)
                    .header("Content-Type", "application/json")
                    .POST(HttpRequest.BodyPublishers.ofString(body))
                    .build();
            HttpResponse<String> response = client.send(request, HttpResponse.BodyHandlers.ofString());
            if (response.statusCode() != 200) {
                log.warning("Bunny createVideo failed: HTTP " + response.statusCode() + " — " + response.body());
                throw new CourseActionException(HttpStatus.BAD_GATEWAY,
                        "Bunny Stream không thể tạo video: HTTP " + response.statusCode());
            }
            return extractJsonField(response.body(), "guid");
        } catch (CourseActionException ex) {
            throw ex;
        } catch (Exception ex) {
            log.severe("Bunny createVideo error: " + ex.getMessage());
            throw new CourseActionException(HttpStatus.SERVICE_UNAVAILABLE,
                    "Không thể kết nối đến Bunny Stream: " + ex.getMessage());
        }
    }

    /**
     * Bước 2: Upload file video lên Bunny Stream bằng PUT request streaming
     * (không buffer toàn bộ file trong RAM — an toàn với file lớn).
     *
     * @param videoGuid Bunny Video GUID nhận từ createVideo()
     * @param file      MultipartFile từ request của giảng viên
     */
    public void uploadVideo(String videoGuid, MultipartFile file) {
        assertApiKeyConfigured();
        String uploadUrl = apiUrl + "/library/" + libraryId + "/videos/" + videoGuid;
        try {
            // Dùng HttpURLConnection để stream theo chunk, tránh OutOfMemoryError với file lớn
            URL url = URI.create(uploadUrl).toURL();
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("PUT");
            conn.setRequestProperty("AccessKey", apiKey);
            conn.setRequestProperty("Content-Type", "application/octet-stream");
            conn.setRequestProperty("Content-Length", String.valueOf(file.getSize()));
            conn.setDoOutput(true);
            conn.setConnectTimeout(15_000);
            conn.setReadTimeout(300_000); // 5 phút cho file lớn

            // Stream dữ liệu theo chunk 64KB — không load toàn bộ vào RAM
            try (InputStream in = file.getInputStream();
                 OutputStream out = conn.getOutputStream()) {
                byte[] buffer = new byte[65536];
                int bytesRead;
                while ((bytesRead = in.read(buffer)) != -1) {
                    out.write(buffer, 0, bytesRead);
                }
                out.flush();
            }

            int status = conn.getResponseCode();
            conn.disconnect();

            if (status != 200) {
                log.warning("Bunny uploadVideo failed: HTTP " + status + " for GUID " + videoGuid);
                throw new CourseActionException(HttpStatus.BAD_GATEWAY,
                        "Bunny Stream không thể nhận file video: HTTP " + status);
            }
            log.info("Bunny uploadVideo success: GUID=" + videoGuid + ", size=" + file.getSize());
        } catch (CourseActionException ex) {
            throw ex;
        } catch (IOException ex) {
            log.severe("Bunny uploadVideo IO error: " + ex.getMessage());
            throw new CourseActionException(HttpStatus.SERVICE_UNAVAILABLE,
                    "Lỗi kết nối khi upload video lên Bunny Stream: " + ex.getMessage());
        }
    }

    /**
     * Lấy trạng thái xử lý video từ Bunny Stream.
     *
     * Bunny status codes:
     *  0 = Created (chờ upload), 1 = Uploaded, 2 = Processing,
     *  3 = Transcoding, 4 = Finished (READY), 5 = Error, 6 = UploadFailed
     *
     * @return "PROCESSING", "READY", hoặc "FAILED"
     */
    public String getVideoStatus(String videoGuid) {
        assertApiKeyConfigured();
        String endpoint = apiUrl + "/library/" + libraryId + "/videos/" + videoGuid;
        try {
            HttpClient client = HttpClient.newBuilder()
                    .connectTimeout(Duration.ofSeconds(10))
                    .build();
            HttpRequest request = HttpRequest.newBuilder()
                    .uri(URI.create(endpoint))
                    .header("AccessKey", apiKey)
                    .GET()
                    .build();
            HttpResponse<String> response = client.send(request, HttpResponse.BodyHandlers.ofString());
            if (response.statusCode() != 200) {
                return "FAILED";
            }
            String statusStr = extractJsonField(response.body(), "status");
            int bunnyStatus = statusStr != null ? Integer.parseInt(statusStr.trim()) : -1;
            return switch (bunnyStatus) {
                case 4       -> "READY";
                case 5, 6   -> "FAILED";
                default      -> "PROCESSING";
            };
        } catch (Exception ex) {
            log.warning("Bunny getVideoStatus error for " + videoGuid + ": " + ex.getMessage());
            return "PROCESSING"; // Không biết → giả sử đang xử lý
        }
    }

    /**
     * Tạo embed URL cho Bunny Player.
     * Format: https://player.mediadelivery.net/embed/{libraryId}/{videoGuid}
     */
    public String buildPlayerUrl(String videoGuid) {
        return playerUrl + "/embed/" + libraryId + "/" + videoGuid;
    }

    /**
     * Kiểm tra Bunny API Key đã được cấu hình chưa.
     */
    public boolean isConfigured() {
        return apiKey != null && !apiKey.isBlank();
    }

    // ──────────────────────────────────────────────────────────
    // PRIVATE HELPERS
    // ──────────────────────────────────────────────────────────

    private void assertApiKeyConfigured() {
        if (apiKey == null || apiKey.isBlank()) {
            throw new CourseActionException(HttpStatus.SERVICE_UNAVAILABLE,
                    "Bunny Stream chưa được cấu hình. Vui lòng thiết lập BUNNY_API_KEY trong biến môi trường.");
        }
    }

    /**
     * Parse JSON field đơn giản — tránh thêm dependency JSON parser mới.
     * Chỉ dùng cho response đơn giản từ Bunny API.
     */
    private String extractJsonField(String json, String field) {
        // Tìm "field":"value" hoặc "field":value
        String searchKey = "\"" + field + "\"";
        int keyIdx = json.indexOf(searchKey);
        if (keyIdx < 0) return null;
        int colonIdx = json.indexOf(':', keyIdx + searchKey.length());
        if (colonIdx < 0) return null;
        // Bỏ qua khoảng trắng sau dấu :
        int start = colonIdx + 1;
        while (start < json.length() && (json.charAt(start) == ' ' || json.charAt(start) == '\t')) start++;
        if (start >= json.length()) return null;
        if (json.charAt(start) == '"') {
            // String value
            int end = json.indexOf('"', start + 1);
            return end > start ? json.substring(start + 1, end) : null;
        } else {
            // Number / boolean / null
            int end = start;
            while (end < json.length() && ",}] \t\r\n".indexOf(json.charAt(end)) < 0) end++;
            return json.substring(start, end);
        }
    }

    /** Escape ký tự đặc biệt trong JSON string để tránh injection. */
    private String escapeJson(String value) {
        if (value == null) return "";
        return value.replace("\\", "\\\\")
                    .replace("\"", "\\\"")
                    .replace("\n", "\\n")
                    .replace("\r", "\\r")
                    .replace("\t", "\\t");
    }
}
