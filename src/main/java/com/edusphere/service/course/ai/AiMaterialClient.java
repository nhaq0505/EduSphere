package com.edusphere.service.course.ai;

import com.edusphere.dto.course.ai.AiMaterialGenerateRequestDto;
import com.edusphere.dto.course.ai.AiMaterialResultDto;
import com.edusphere.dto.course.ai.AiMaterialTaskResponseDto;
import com.edusphere.service.course.CourseActionException;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Component;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.time.Duration;

/**
 * HTTP Client giao tiếp với Python FastAPI Service (Whisper + Qwen 2.5:3B).
 * Cấu hình base URL thông qua application.properties: ai.service.base-url.
 */
@Slf4j
@Component
public class AiMaterialClient {

    private final String baseUrl;
    private final HttpClient httpClient;
    private final ObjectMapper objectMapper;

    public AiMaterialClient(@Value("${ai.service.base-url:http://localhost:8000}") String baseUrl,
                            ObjectMapper objectMapper) {
        this.baseUrl = baseUrl.endsWith("/") ? baseUrl.substring(0, baseUrl.length() - 1) : baseUrl;
        this.objectMapper = objectMapper;
        this.httpClient = HttpClient.newBuilder()
                .connectTimeout(Duration.ofSeconds(6))
                .build();
    }

    /**
     * Gửi yêu cầu khởi tạo tác vụ phân tích video bài giảng (POST /api/ai/materials/generate)
     */
    public AiMaterialTaskResponseDto initiateGeneration(AiMaterialGenerateRequestDto request) {
        String endpoint = baseUrl + "/api/ai/materials/generate";
        try {
            String jsonBody = objectMapper.writeValueAsString(request);
            HttpRequest httpRequest = HttpRequest.newBuilder()
                    .uri(URI.create(endpoint))
                    .header("Content-Type", "application/json")
                    .timeout(Duration.ofSeconds(15))
                    .POST(HttpRequest.BodyPublishers.ofString(jsonBody))
                    .build();

            HttpResponse<String> response = httpClient.send(httpRequest, HttpResponse.BodyHandlers.ofString());

            if (response.statusCode() == 200 || response.statusCode() == 202) {
                return objectMapper.readValue(response.body(), AiMaterialTaskResponseDto.class);
            } else if (response.statusCode() == 400) {
                JsonNode root = objectMapper.readTree(response.body());
                String detail = root.has("detail") ? root.get("detail").asText() : "Dữ liệu yêu cầu không hợp lệ";
                throw new CourseActionException(HttpStatus.BAD_REQUEST, detail);
            } else {
                log.error("AI service generation failed: HTTP {} - {}", response.statusCode(), response.body());
                throw new CourseActionException(HttpStatus.BAD_GATEWAY,
                        "Dịch vụ AI phản hồi lỗi: HTTP " + response.statusCode());
            }
        } catch (CourseActionException ex) {
            throw ex;
        } catch (Exception ex) {
            log.error("Không thể kết nối đến AI service tại {}: {}", endpoint, ex.getMessage());
            throw new CourseActionException(HttpStatus.SERVICE_UNAVAILABLE,
                    "Không thể kết nối đến Dịch vụ AI (FastAPI tại " + baseUrl + "). Vui lòng đảm bảo dịch vụ AI Python đã được khởi chạy.");
        }
    }

    /**
     * Kiểm tra tiến trình xử lý của tác vụ (GET /api/ai/materials/tasks/{taskId})
     */
    public AiMaterialTaskResponseDto checkTaskStatus(String taskId) {
        String endpoint = baseUrl + "/api/ai/materials/tasks/" + taskId;
        try {
            HttpRequest httpRequest = HttpRequest.newBuilder()
                    .uri(URI.create(endpoint))
                    .header("Accept", "application/json")
                    .timeout(Duration.ofSeconds(8))
                    .GET()
                    .build();

            HttpResponse<String> response = httpClient.send(httpRequest, HttpResponse.BodyHandlers.ofString());

            if (response.statusCode() == 200) {
                return objectMapper.readValue(response.body(), AiMaterialTaskResponseDto.class);
            } else if (response.statusCode() == 404) {
                return AiMaterialTaskResponseDto.builder()
                        .taskId(taskId)
                        .status("NOT_FOUND")
                        .message("Không tìm thấy tác vụ trên Python service.")
                        .build();
            } else {
                log.warn("Check status error: HTTP {} for taskId {}", response.statusCode(), taskId);
                return AiMaterialTaskResponseDto.builder()
                        .taskId(taskId)
                        .status("UNKNOWN")
                        .message("Dịch vụ AI phản hồi mã lỗi HTTP " + response.statusCode())
                        .build();
            }
        } catch (Exception ex) {
            log.warn("Lỗi khi kiểm tra tiến trình tác vụ {}: {}", taskId, ex.getMessage());
            return AiMaterialTaskResponseDto.builder()
                    .taskId(taskId)
                    .status("DISCONNECTED")
                    .message("Không thể kết nối tới dịch vụ AI để kiểm tra tiến trình: " + ex.getMessage())
                    .build();
        }
    }

    /**
     * Lấy kết quả tài liệu hoàn chỉnh (GET /api/ai/materials/tasks/{taskId}/result)
     */
    public AiMaterialResultDto getTaskResult(String taskId) {
        String endpoint = baseUrl + "/api/ai/materials/tasks/" + taskId + "/result";
        try {
            HttpRequest httpRequest = HttpRequest.newBuilder()
                    .uri(URI.create(endpoint))
                    .header("Accept", "application/json")
                    .timeout(Duration.ofSeconds(10))
                    .GET()
                    .build();

            HttpResponse<String> response = httpClient.send(httpRequest, HttpResponse.BodyHandlers.ofString());

            if (response.statusCode() == 200) {
                return objectMapper.readValue(response.body(), AiMaterialResultDto.class);
            } else {
                log.warn("Get result error: HTTP {} for taskId {}", response.statusCode(), taskId);
                throw new CourseActionException(HttpStatus.BAD_GATEWAY,
                        "Không thể lấy kết quả AI: HTTP " + response.statusCode());
            }
        } catch (CourseActionException ex) {
            throw ex;
        } catch (Exception ex) {
            log.error("Lỗi khi nhận kết quả từ tác vụ {}: {}", taskId, ex.getMessage());
            throw new CourseActionException(HttpStatus.SERVICE_UNAVAILABLE,
                    "Lỗi kết nối khi nhận kết quả AI: " + ex.getMessage());
        }
    }

    /**
     * Kiểm tra nhanh trạng thái sẵn sàng của dịch vụ AI
     */
    public boolean isServiceAvailable() {
        try {
            HttpRequest request = HttpRequest.newBuilder()
                    .uri(URI.create(baseUrl + "/health"))
                    .timeout(Duration.ofSeconds(2))
                    .GET()
                    .build();
            HttpResponse<String> response = httpClient.send(request, HttpResponse.BodyHandlers.ofString());
            return response.statusCode() == 200;
        } catch (Exception ex) {
            return false;
        }
    }
}

