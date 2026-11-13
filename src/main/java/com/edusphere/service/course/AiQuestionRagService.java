package com.edusphere.service.course;

import com.edusphere.dto.quiz.AiRagGenerationResultDto;
import com.edusphere.dto.quiz.AiRagGenerationResultDto.AiDraftQuestionDto;
import com.edusphere.dto.quiz.AiRagGenerationResultDto.RagChunkDto;
import com.edusphere.entity.course.Course;
import com.edusphere.entity.course.Lesson;
import com.edusphere.repository.course.CourseRepository;
import com.edusphere.repository.course.LessonRepository;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.poi.xwpf.usermodel.XWPFDocument;
import org.apache.poi.xwpf.usermodel.XWPFParagraph;
import org.apache.poi.xwpf.usermodel.XWPFTable;
import org.apache.poi.xwpf.usermodel.XWPFTableCell;
import org.apache.poi.xwpf.usermodel.XWPFTableRow;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.InputStream;
import java.math.BigDecimal;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.time.Duration;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Comparator;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

/**
 * Dịch vụ tạo câu hỏi ngân hàng bằng AI theo kiến trúc RAG (Retrieval-Augmented Generation):
 * 1. Thu thập tài liệu từ bài giảng khóa học, file tài liệu (.docx/.txt) và văn bản giảng viên cung cấp.
 * 2. Chia nhỏ ngữ cảnh thành các đoạn (Chunking) có gối đầu (Overlap).
 * 3. Truy xuất Top-K đoạn kiến thức liên quan nhất (Lexical/BM25 Retrieval) theo chủ đề yêu cầu.
 * 4. Gọi Model AI qua API Key (Gemini / OpenAI / Groq) để sinh câu hỏi nháp kèm trích dẫn nguồn cho Giảng viên kiểm duyệt.
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class AiQuestionRagService {

    private static final int CHUNK_SIZE = 750;
    private static final int CHUNK_OVERLAP = 120;
    private static final int TOP_K_CHUNKS = 6;

    private final CourseRepository courseRepository;
    private final LessonRepository lessonRepository;
    private final ObjectMapper objectMapper;

    @Value("${ai.rag.api-key:}")
    private String defaultApiKey;

    @Value("${ai.rag.model:gemini-2.5-flash}")
    private String defaultModel;

    private static final List<String> GEMINI_FALLBACK_MODELS = List.of(
            "gemini-2.5-flash",
            "gemini-3-flash-preview",
            "gemini-flash-latest"
    );

    private volatile HttpClient httpClient;

    private HttpClient getHttpClient() {
        HttpClient client = this.httpClient;
        if (client == null) {
            synchronized (this) {
                client = this.httpClient;
                if (client == null) {
                    client = HttpClient.newBuilder()
                            .connectTimeout(Duration.ofSeconds(20))
                            .build();
                    this.httpClient = client;
                }
            }
        }
        return client;
    }

    /**
     * Thực thi toàn bộ luồng RAG (Collect -> Chunk -> Retrieve Top-K -> Call LLM) để sinh danh sách câu hỏi nháp.
     */
    public AiRagGenerationResultDto generateDraftQuestionsWithRag(
            Integer courseId,
            List<Integer> lessonIds,
            MultipartFile documentFile,
            String customContext,
            String topicPrompt,
            String questionType,
            String difficulty,
            int questionCount,
            String apiKeyInput,
            String modelInput) {

        String resolvedApiKey = resolveApiKey(apiKeyInput);
        String resolvedModel = normalizeModelName((modelInput != null && !modelInput.isBlank()) ? modelInput.trim() : defaultModel);
        int safeCount = Math.max(1, Math.min(20, questionCount));

        // Bước 1: Thu thập toàn bộ tài liệu gốc từ bài học, tệp đính kèm và văn bản nhập tay
        Map<String, String> sourceDocuments = collectKnowledgeDocuments(courseId, lessonIds, documentFile, customContext, topicPrompt);
        if (sourceDocuments.isEmpty()) {
            throw new CourseActionException(HttpStatus.BAD_REQUEST,
                    "Không có dữ liệu ngữ cảnh để thực hiện RAG. Vui lòng chọn bài học trong khóa học, tải lên tệp tài liệu (.docx/.txt) hoặc dán nội dung bài giảng.");
        }

        // Bước 2: Chia nhỏ tài liệu thành các đoạn ngữ cảnh (Overlapping Chunking)
        List<RagChunkDto> allChunks = chunkDocuments(sourceDocuments);
        if (allChunks.isEmpty()) {
            throw new CourseActionException(HttpStatus.BAD_REQUEST,
                    "Tài liệu ngữ cảnh đang trống. Vui lòng cung cấp nội dung bài học hoặc tài liệu hợp lệ.");
        }

        // Bước 3: Truy xuất Top-K đoạn ngữ cảnh sát nhất với chủ đề yêu cầu của giảng viên (RAG Retrieval)
        List<RagChunkDto> topChunks = retrieveTopKChunks(allChunks, topicPrompt, TOP_K_CHUNKS);

        // Bước 4: Gọi Model AI qua API Key với ngữ cảnh Top-K đã truy xuất để sinh câu hỏi nháp
        String rawJson = callLlmWithRagContext(
                resolvedApiKey,
                resolvedModel,
                topChunks,
                topicPrompt,
                questionType,
                difficulty,
                safeCount
        );

        // Bước 5: Chuyển đổi JSON từ AI sang danh sách câu hỏi nháp để Giảng viên kiểm duyệt
        List<AiDraftQuestionDto> drafts = parseAiJsonToDrafts(rawJson, questionType, difficulty);
        if (drafts.isEmpty()) {
            throw new CourseActionException(HttpStatus.BAD_GATEWAY,
                    "Model AI không trả về được câu hỏi hợp lệ từ tài liệu này. Vui lòng thử lại hoặc cụ thể hóa yêu cầu chủ đề.");
        }

        return AiRagGenerationResultDto.builder()
                .modelUsed(resolvedModel)
                .topicPrompt(topicPrompt)
                .retrievedChunks(topChunks)
                .draftQuestions(drafts)
                .build();
    }

    /**
     * Thu thập văn bản ngữ cảnh từ bài học trong khóa học, tệp tài liệu (.docx/.txt/.md) và văn bản giảng viên dán trực tiếp.
     */
    private Map<String, String> collectKnowledgeDocuments(
            Integer courseId,
            List<Integer> lessonIds,
            MultipartFile documentFile,
            String customContext,
            String topicPrompt) {

        Map<String, String> docs = new LinkedHashMap<>();

        // 1. Nguồn từ Khóa học & Bài học trong hệ thống
        if (courseId != null && courseId > 0) {
            Course course = courseRepository.findById(courseId).orElse(null);
            if (course != null) {
                StringBuilder courseIntro = new StringBuilder();
                if (course.getTitle() != null && !course.getTitle().isBlank()) {
                    courseIntro.append("Khóa học: ").append(course.getTitle().trim()).append("\n");
                }
                if (course.getDescription() != null && !course.getDescription().isBlank()) {
                    courseIntro.append(course.getDescription().trim()).append("\n");
                }
                if (course.getObjectives() != null && !course.getObjectives().isBlank()) {
                    courseIntro.append("Mục tiêu khóa học: ").append(course.getObjectives().trim()).append("\n");
                }
                if (course.getRequirements() != null && !course.getRequirements().isBlank()) {
                    courseIntro.append("Yêu cầu kiến thức: ").append(course.getRequirements().trim());
                }
                if (!courseIntro.isEmpty()) {
                    docs.put("Khóa học: " + course.getTitle(), courseIntro.toString().trim());
                }
            }

            List<Lesson> lessons = lessonRepository.findByCourse_CourseIdOrderByOrderIndexAsc(courseId);
            Set<Integer> selectedIds = (lessonIds != null && !lessonIds.isEmpty())
                    ? new HashSet<>(lessonIds)
                    : null;

            for (Lesson lesson : lessons) {
                if (selectedIds != null && !selectedIds.contains(lesson.getLessonId())) {
                    continue;
                }
                StringBuilder lessonText = new StringBuilder();
                if (lesson.getTitle() != null && !lesson.getTitle().isBlank()) {
                    lessonText.append("Chủ đề bài học: ").append(lesson.getTitle().trim()).append("\n");
                }
                if (lesson.getContent() != null && !lesson.getContent().isBlank()) {
                    lessonText.append(lesson.getContent().trim()).append("\n");
                }
                if (!lessonText.isEmpty()) {
                    docs.put("Bài học: " + lesson.getTitle(), lessonText.toString().trim());
                }
            }
        }

        // 2. Nguồn từ tệp tài liệu tải lên (.docx / .txt / .md / .csv)
        if (documentFile != null && !documentFile.isEmpty()) {
            String extracted = extractTextFromUploadedFile(documentFile);
            if (!extracted.isBlank()) {
                String fileName = documentFile.getOriginalFilename() != null
                        ? documentFile.getOriginalFilename()
                        : "Tài liệu tải lên";
                docs.put("Tệp đính kèm: " + fileName, extracted);
            }
        }

        // 3. Nguồn từ văn bản giảng viên dán trực tiếp
        if (customContext != null && !customContext.isBlank()) {
            docs.put("Tài liệu giảng viên cung cấp", customContext.trim());
        }

        // 4. Dự phòng nếu giảng viên chỉ nhập chủ đề trọng tâm mà không chọn khóa học/tài liệu
        if (docs.isEmpty() && topicPrompt != null && !topicPrompt.isBlank()) {
            docs.put("Chủ đề trọng tâm giảng viên yêu cầu", topicPrompt.trim());
        }

        return docs;
    }

    /**
     * Trích xuất văn bản thuần từ tệp .docx (qua Apache POI) hoặc .txt/.md/.csv.
     */
    private String extractTextFromUploadedFile(MultipartFile file) {
        String filename = file.getOriginalFilename() != null
                ? file.getOriginalFilename().toLowerCase(Locale.ROOT)
                : "";
        try (InputStream is = file.getInputStream()) {
            if (filename.endsWith(".docx")) {
                try (XWPFDocument doc = new XWPFDocument(is)) {
                    StringBuilder sb = new StringBuilder();
                    for (XWPFParagraph p : doc.getParagraphs()) {
                        String text = p.getText();
                        if (text != null && !text.isBlank()) {
                            sb.append(text.trim()).append("\n");
                        }
                    }
                    for (XWPFTable table : doc.getTables()) {
                        for (XWPFTableRow row : table.getRows()) {
                            for (XWPFTableCell cell : row.getTableCells()) {
                                String cellText = cell.getText();
                                if (cellText != null && !cellText.isBlank()) {
                                    sb.append(cellText.trim()).append(" | ");
                                }
                            }
                            sb.append("\n");
                        }
                    }
                    return sb.toString().trim();
                }
            }
            return new String(is.readAllBytes(), StandardCharsets.UTF_8).trim();
        } catch (Exception ex) {
            log.warn("Lỗi trích xuất văn bản từ tệp {}: {}", filename, ex.getMessage());
            throw new CourseActionException(HttpStatus.BAD_REQUEST,
                    "Không thể đọc nội dung tệp đính kèm (" + filename + "). Vui lòng chọn tệp .docx hoặc .txt hợp lệ.");
        }
    }

    /**
     * Chia nhỏ các tài liệu dài thành các đoạn ngữ cảnh (RagChunkDto) có gối đầu (Sliding Window Overlap).
     */
    public List<RagChunkDto> chunkDocuments(Map<String, String> sourceDocuments) {
        List<RagChunkDto> chunks = new ArrayList<>();
        int index = 1;

        for (Map.Entry<String, String> entry : sourceDocuments.entrySet()) {
            String sourceTitle = entry.getKey();
            String rawText = entry.getValue();
            if (rawText == null || rawText.isBlank()) {
                continue;
            }
            String normalized = rawText.replaceAll("\\r\\n?", "\n").replaceAll("\\n{3,}", "\n\n").trim();
            if (normalized.length() <= CHUNK_SIZE) {
                chunks.add(new RagChunkDto(index++, sourceTitle, normalized, 1.0));
                continue;
            }

            int start = 0;
            while (start < normalized.length()) {
                int end = Math.min(start + CHUNK_SIZE, normalized.length());
                if (end < normalized.length()) {
                    // Ưu tiên cắt ở dấu xuống dòng hoặc dấu chấm câu gần nhất để không cắt ngang từ/câu
                    int lastBreak = Math.max(
                            normalized.lastIndexOf('\n', end),
                            normalized.lastIndexOf(". ", end)
                    );
                    if (lastBreak > start + (CHUNK_SIZE / 2)) {
                        end = lastBreak + 1;
                    }
                }
                String piece = normalized.substring(start, end).trim();
                if (!piece.isEmpty()) {
                    chunks.add(new RagChunkDto(index++, sourceTitle, piece, 1.0));
                }
                if (end >= normalized.length()) {
                    break;
                }
                start = Math.max(start + 1, end - CHUNK_OVERLAP);
            }
        }
        return chunks;
    }

    /**
     * Chấm điểm độ liên quan (BM25 / Lexical TF-IDF) giữa yêu cầu của giảng viên và các đoạn ngữ cảnh,
     * trả về Top-K đoạn ngữ cảnh sát nhất để đưa vào Prompt cho Model AI.
     */
    public List<RagChunkDto> retrieveTopKChunks(List<RagChunkDto> allChunks, String queryPrompt, int topK) {
        if (allChunks.size() <= topK) {
            return allChunks;
        }

        List<String> queryTokens = tokenizeVietnamese(queryPrompt);
        if (queryTokens.isEmpty()) {
            // Nếu giảng viên không nhập chủ đề cụ thể, lấy mẫu trải đều khắp tài liệu
            List<RagChunkDto> sampled = new ArrayList<>();
            double step = (double) allChunks.size() / topK;
            for (int i = 0; i < topK; i++) {
                int idx = Math.min(allChunks.size() - 1, (int) Math.floor(i * step));
                sampled.add(allChunks.get(idx));
            }
            return sampled;
        }

        // Tính Document Frequency (DF) cho từng token trong tập chunks
        int totalDocs = allChunks.size();
        Map<String, Integer> docFreq = new HashMap<>();
        List<List<String>> chunkTokenLists = new ArrayList<>();
        double avgDocLen = 0.0;

        for (RagChunkDto chunk : allChunks) {
            List<String> tokens = tokenizeVietnamese(chunk.getSourceTitle() + " " + chunk.getContent());
            chunkTokenLists.add(tokens);
            avgDocLen += tokens.size();
            Set<String> unique = new HashSet<>(tokens);
            for (String token : unique) {
                docFreq.put(token, docFreq.getOrDefault(token, 0) + 1);
            }
        }
        avgDocLen = Math.max(1.0, avgDocLen / totalDocs);

        // Tham số chuẩn BM25
        double k1 = 1.5;
        double b = 0.75;

        List<RagChunkDto> scored = new ArrayList<>();
        for (int i = 0; i < allChunks.size(); i++) {
            RagChunkDto chunk = allChunks.get(i);
            List<String> docTokens = chunkTokenLists.get(i);
            Map<String, Long> tfMap = docTokens.stream()
                    .collect(Collectors.groupingBy(t -> t, Collectors.counting()));

            double score = 0.0;
            for (String qToken : queryTokens) {
                long tf = tfMap.getOrDefault(qToken, 0L);
                if (tf == 0) continue;
                int df = docFreq.getOrDefault(qToken, 0);
                double idf = Math.log(1.0 + (totalDocs - df + 0.5) / (df + 0.5));
                double numerator = tf * (k1 + 1.0);
                double denominator = tf + k1 * (1.0 - b + b * (docTokens.size() / avgDocLen));
                score += idf * (numerator / denominator);
            }

            // Cộng điểm thưởng nếu khớp cụm từ chính xác trong nội dung hoặc tiêu đề bài học
            String normalizedQuery = queryPrompt != null ? queryPrompt.trim().toLowerCase(Locale.ROOT) : "";
            if (!normalizedQuery.isEmpty()) {
                if (chunk.getContent().toLowerCase(Locale.ROOT).contains(normalizedQuery)) {
                    score += 3.0;
                }
                if (chunk.getSourceTitle().toLowerCase(Locale.ROOT).contains(normalizedQuery)) {
                    score += 2.0;
                }
            }

            double roundedScore = Math.round(score * 100.0) / 100.0;
            scored.add(new RagChunkDto(chunk.getChunkIndex(), chunk.getSourceTitle(), chunk.getContent(), roundedScore));
        }

        return scored.stream()
                .sorted(Comparator.comparingDouble(RagChunkDto::getRelevanceScore).reversed()
                        .thenComparingInt(RagChunkDto::getChunkIndex))
                .limit(topK)
                .toList();
    }

    /**
     * Gọi REST API của Model AI (Google Gemini, OpenAI hoặc Groq) bằng API Key kèm ngữ cảnh RAG đã truy xuất.
     */
    private String callLlmWithRagContext(
            String apiKey,
            String model,
            List<RagChunkDto> retrievedChunks,
            String topicPrompt,
            String questionType,
            String difficulty,
            int questionCount) {

        if (apiKey == null || apiKey.isBlank()) {
            throw new CourseActionException(HttpStatus.BAD_REQUEST,
                    "Vui lòng nhập API Key (Google Gemini, OpenAI hoặc Groq) hoặc cấu hình ai.rag.api-key trong application.properties.");
        }

        String systemPrompt = buildSystemPrompt();
        String userPrompt = buildUserPrompt(retrievedChunks, topicPrompt, questionType, difficulty, questionCount);

        boolean isGemini = model.toLowerCase(Locale.ROOT).startsWith("gemini") || apiKey.startsWith("AIza");
        try {
            if (isGemini) {
                return callGeminiApi(apiKey, model, systemPrompt, userPrompt);
            } else {
                return callOpenAiCompatibleApi(apiKey, model, systemPrompt, userPrompt);
            }
        } catch (CourseActionException ex) {
            throw ex;
        } catch (Exception ex) {
            log.error("Lỗi khi gọi Model AI ({}): ", model, ex);
            throw new CourseActionException(HttpStatus.BAD_GATEWAY,
                    "Không thể kết nối tới Model AI (" + model + "): " + ex.getMessage());
        }
    }

    /**
     * Chuẩn hóa tên model Gemini để tự động nâng cấp các mã model cũ (như gemini-2.0-flash, gemini-1.5-flash)
     * đã bị Google AI Studio ngừng hỗ trợ (HTTP 404) sang gemini-2.5-flash.
     */
    private String normalizeModelName(String rawModel) {
        if (rawModel == null || rawModel.isBlank()) {
            return "gemini-2.5-flash";
        }
        String trimmed = rawModel.trim();
        String lower = trimmed.toLowerCase(Locale.ROOT);
        if (lower.equals("gemini-2.0-flash")
                || lower.equals("gemini-1.5-flash")
                || lower.equals("gemini-1.5-pro")
                || lower.equals("gemini-2.5-pro")
                || lower.equals("gemini-2.5-flash-lite")) {
            return "gemini-2.5-flash";
        }
        return trimmed;
    }

    /**
     * Gọi Google Gemini API (generateContent) có cơ chế tự động thử lại qua danh sách model dự phòng
     * nếu một model bị ngừng hỗ trợ (404) hoặc quá tải tạm thời (429/503).
     */
    private String callGeminiApi(String apiKey, String model, String systemPrompt, String userPrompt) throws Exception {
        String primaryModel = model.toLowerCase(Locale.ROOT).startsWith("gemini")
                ? normalizeModelName(model)
                : "gemini-2.5-flash";

        List<String> candidateModels = new ArrayList<>();
        candidateModels.add(primaryModel);
        for (String fallback : GEMINI_FALLBACK_MODELS) {
            if (!candidateModels.contains(fallback)) {
                candidateModels.add(fallback);
            }
        }

        Map<String, Object> payload = new LinkedHashMap<>();
        payload.put("systemInstruction", Map.of(
                "parts", List.of(Map.of("text", systemPrompt))
        ));
        payload.put("contents", List.of(Map.of(
                "role", "user",
                "parts", List.of(Map.of("text", userPrompt))
        )));
        payload.put("generationConfig", Map.of(
                "temperature", 0.3,
                "responseMimeType", "application/json"
        ));
        String requestBody = objectMapper.writeValueAsString(payload);

        int lastStatus = 500;
        String lastBody = "";

        for (String candidateModel : candidateModels) {
            // Gửi khóa qua header thay vì query string để khóa không lọt vào log hay thông báo lỗi
            String url = "https://generativelanguage.googleapis.com/v1beta/models/" + candidateModel + ":generateContent";
            HttpRequest request = HttpRequest.newBuilder()
                    .uri(URI.create(url))
                    .header("Content-Type", "application/json; charset=UTF-8")
                    .header("x-goog-api-key", apiKey)
                    .timeout(Duration.ofSeconds(60))
                    .POST(HttpRequest.BodyPublishers.ofString(requestBody, StandardCharsets.UTF_8))
                    .build();

            HttpResponse<String> response = getHttpClient().send(request, HttpResponse.BodyHandlers.ofString(StandardCharsets.UTF_8));
            lastStatus = response.statusCode();
            lastBody = response.body();

            if (lastStatus >= 200 && lastStatus < 300) {
                JsonNode root = objectMapper.readTree(lastBody);
                JsonNode textNode = root.at("/candidates/0/content/parts/0/text");
                if (!textNode.isMissingNode() && !textNode.asText().isBlank()) {
                    return textNode.asText();
                }
            }

            log.warn("Gemini API (model={}) trả về HTTP {}: {}", candidateModel, lastStatus, lastBody);
            // Nếu lỗi do API key không hợp lệ (400/401/403), dừng ngay không cần thử model khác
            if (lastStatus == 400 || lastStatus == 401 || lastStatus == 403) {
                break;
            }
        }

        throw new CourseActionException(HttpStatus.BAD_GATEWAY, geminiErrorMessage(lastStatus, lastBody));
    }

    /** Thông báo lỗi dễ hiểu theo lý do Google trả về. */
    static String geminiErrorMessage(int status, String body) {
        String lower = body == null ? "" : body.toLowerCase(Locale.ROOT);
        if (lower.contains("leaked")) {
            return "API Key Gemini đã bị Google khóa vì bị lộ công khai. Hãy tạo khóa mới trong Google AI Studio "
                    + "và cấu hình lại (biến môi trường AI_RAG_API_KEY) hoặc nhập khóa mới trong form.";
        }
        if (lower.contains("api_key_invalid") || lower.contains("api key not valid")) {
            return "API Key Gemini không hợp lệ. Vui lòng kiểm tra lại khóa.";
        }
        if (status == 429 || lower.contains("resource_exhausted")) {
            return "Gemini đang vượt hạn mức sử dụng (HTTP 429). Vui lòng thử lại sau ít phút.";
        }
        return "Gemini API trả về lỗi (HTTP " + status + "). Vui lòng kiểm tra lại API Key hoặc thử lại sau.";
    }

    /**
     * Gọi OpenAI hoặc Groq API (/v1/chat/completions) tương thích chuẩn Chat Completions.
     */
    private String callOpenAiCompatibleApi(String apiKey, String model, String systemPrompt, String userPrompt) throws Exception {
        boolean isGroq = apiKey.startsWith("gsk_") || model.toLowerCase(Locale.ROOT).contains("llama");
        String endpoint = isGroq
                ? "https://api.groq.com/openai/v1/chat/completions"
                : "https://api.openai.com/v1/chat/completions";

        Map<String, Object> payload = new LinkedHashMap<>();
        payload.put("model", model);
        payload.put("temperature", 0.3);
        payload.put("messages", List.of(
                Map.of("role", "system", "content", systemPrompt),
                Map.of("role", "user", "content", userPrompt)
        ));

        String requestBody = objectMapper.writeValueAsString(payload);
        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create(endpoint))
                .header("Content-Type", "application/json; charset=UTF-8")
                .header("Authorization", "Bearer " + apiKey)
                .timeout(Duration.ofSeconds(60))
                .POST(HttpRequest.BodyPublishers.ofString(requestBody, StandardCharsets.UTF_8))
                .build();

        HttpResponse<String> response = getHttpClient().send(request, HttpResponse.BodyHandlers.ofString(StandardCharsets.UTF_8));
        if (response.statusCode() < 200 || response.statusCode() >= 300) {
            log.warn("OpenAI/Groq API trả về HTTP {}: {}", response.statusCode(), response.body());
            throw new CourseActionException(HttpStatus.BAD_GATEWAY,
                    "API Model trả về lỗi (HTTP " + response.statusCode() + "). Vui lòng kiểm tra lại API Key và tên Model.");
        }

        JsonNode root = objectMapper.readTree(response.body());
        JsonNode contentNode = root.at("/choices/0/message/content");
        if (contentNode.isMissingNode() || contentNode.asText().isBlank()) {
            throw new CourseActionException(HttpStatus.BAD_GATEWAY, "API Model không trả về nội dung câu hỏi hợp lệ.");
        }
        return contentNode.asText();
    }

    /**
     * Xây dựng System Prompt bắt buộc AI tuân thủ nghiêm ngặt ngữ cảnh RAG và trả về mảng JSON chuẩn.
     */
    private String buildSystemPrompt() {
        return """
                Bạn là chuyên gia khảo thí và thiết kế đề thi đại học/trực tuyến trên nền tảng EduSphere.
                Nhiệm vụ của bạn là tạo các câu hỏi kiểm tra chất lượng cao bằng tiếng Việt CHỈ DỰA TRÊN các đoạn ngữ cảnh RAG được cung cấp.
                Quy tắc bắt buộc:
                1. Tuyệt đối bám sát kiến thức trong các đoạn [NGUỒN NGỮ CẢNH RAG]. Không bịa đặt thông tin ngoài tài liệu.
                2. Trả về KẾT QUẢ DUY NHẤT là một mảng JSON (JSON Array), không bọc trong markdown, theo đúng cấu trúc sau:
                [
                  {
                    "content": "Nội dung câu hỏi rõ ràng, chính xác?",
                    "type": "SINGLE_CHOICE | MULTIPLE_CHOICE | TRUE_FALSE | ESSAY",
                    "difficultyLevel": "EASY | MEDIUM | HARD",
                    "defaultScore": 1.0,
                    "optionA": "Phương án A (để trống nếu là TRUE_FALSE hoặc ESSAY)",
                    "optionB": "Phương án B (để trống nếu là TRUE_FALSE hoặc ESSAY)",
                    "optionC": "Phương án C (để trống nếu là TRUE_FALSE hoặc ESSAY)",
                    "optionD": "Phương án D (để trống nếu là TRUE_FALSE hoặc ESSAY)",
                    "correctAnswer": "A (hoặc A,C nếu MULTIPLE_CHOICE; hoặc TRUE / FALSE nếu TRUE_FALSE; để trống nếu ESSAY)",
                    "explanation": "Giải thích chi tiết vì sao đáp án đó đúng dựa trên tài liệu",
                    "sampleEssayAnswer": "Đáp án mẫu / tiêu chí chấm điểm chi tiết (nếu type là ESSAY)",
                    "sourceExcerpt": "Ghi tên nguồn và trích 1 câu ngắn từ [NGUỒN NGỮ CẢNH RAG] làm căn cứ"
                  }
                ]
                """;
    }

    /**
     * Xây dựng User Prompt kết hợp các đoạn ngữ cảnh Top-K RAG và yêu cầu cấu hình câu hỏi của giảng viên.
     */
    private String buildUserPrompt(
            List<RagChunkDto> retrievedChunks,
            String topicPrompt,
            String questionType,
            String difficulty,
            int questionCount) {

        StringBuilder sb = new StringBuilder();
        sb.append("=== CÁC ĐOẠN NGỮ CẢNH ĐÃ TRUY XUẤT (RAG RETRIEVED CHUNKS) ===\n\n");
        for (int i = 0; i < retrievedChunks.size(); i++) {
            RagChunkDto chunk = retrievedChunks.get(i);
            sb.append("[Nguồn #").append(i + 1).append(" - ").append(chunk.getSourceTitle()).append("]\n");
            sb.append(chunk.getContent()).append("\n\n");
        }

        sb.append("=== YÊU CẦU TẠO CÂU HỎI CỦA GIẢNG VIÊN ===\n");
        sb.append("- Số lượng câu hỏi cần tạo: ").append(questionCount).append(" câu.\n");
        if (topicPrompt != null && !topicPrompt.isBlank()) {
            sb.append("- Trọng tâm / Chủ đề yêu cầu: ").append(topicPrompt.trim()).append("\n");
        }
        if (questionType == null || "MIXED".equalsIgnoreCase(questionType)) {
            sb.append("- Loại câu hỏi: Kết hợp đa dạng giữa SINGLE_CHOICE, MULTIPLE_CHOICE, TRUE_FALSE.\n");
        } else {
            sb.append("- Loại câu hỏi bắt buộc: ").append(questionType.trim().toUpperCase(Locale.ROOT)).append(".\n");
        }
        if (difficulty == null || "MIXED".equalsIgnoreCase(difficulty)) {
            sb.append("- Độ khó: Phân bổ hợp lý từ EASY, MEDIUM đến HARD.\n");
        } else {
            sb.append("- Độ khó bắt buộc: ").append(difficulty.trim().toUpperCase(Locale.ROOT)).append(".\n");
        }
        sb.append("\nHãy trả về đúng mảng JSON gồm ").append(questionCount).append(" câu hỏi theo định dạng đã quy định.");
        return sb.toString();
    }

    /**
     * Phân tích chuỗi JSON do Model AI trả về thành danh sách AiDraftQuestionDto để Giảng viên kiểm duyệt.
     */
    public List<AiDraftQuestionDto> parseAiJsonToDrafts(String rawJson, String fallbackType, String fallbackDifficulty) {
        String cleaned = cleanJsonFence(rawJson);
        List<AiDraftQuestionDto> result = new ArrayList<>();
        try {
            JsonNode root = objectMapper.readTree(cleaned);
            JsonNode arrayNode = root.isArray() ? root : (root.has("questions") ? root.get("questions") : null);
            if (arrayNode == null || !arrayNode.isArray()) {
                return result;
            }

            for (JsonNode node : arrayNode) {
                String content = textOrNull(node, "content");
                if (content == null || content.isBlank()) {
                    continue;
                }

                String type = normalizeType(textOrNull(node, "type"), fallbackType);
                String diff = normalizeDifficulty(textOrNull(node, "difficultyLevel"), fallbackDifficulty);
                BigDecimal score = node.hasNonNull("defaultScore")
                        ? BigDecimal.valueOf(Math.max(0.5, node.get("defaultScore").asDouble(1.0)))
                        : BigDecimal.valueOf(1.0);

                String optA = textOrNull(node, "optionA");
                String optB = textOrNull(node, "optionB");
                String optC = textOrNull(node, "optionC");
                String optD = textOrNull(node, "optionD");
                String correct = textOrNull(node, "correctAnswer");

                if ("TRUE_FALSE".equals(type)) {
                    optA = "Đúng";
                    optB = "Sai";
                    optC = "";
                    optD = "";
                    String tf = QuestionImportService.normalizeTrueFalse(correct);
                    correct = tf != null ? tf : "TRUE";
                } else if ("SINGLE_CHOICE".equals(type) || "MULTIPLE_CHOICE".equals(type)) {
                    if (correct == null || correct.isBlank()) {
                        correct = "A";
                    }
                }

                result.add(AiDraftQuestionDto.builder()
                        .content(content.trim())
                        .type(type)
                        .difficultyLevel(diff)
                        .defaultScore(score)
                        .optionA(optA != null ? optA : "")
                        .optionB(optB != null ? optB : "")
                        .optionC(optC != null ? optC : "")
                        .optionD(optD != null ? optD : "")
                        .correctAnswer(correct != null ? correct.trim().toUpperCase(Locale.ROOT) : "A")
                        .explanation(textOrNull(node, "explanation"))
                        .sampleEssayAnswer(textOrNull(node, "sampleEssayAnswer"))
                        .sourceExcerpt(textOrNull(node, "sourceExcerpt"))
                        .build());
            }
        } catch (Exception ex) {
            log.warn("Không thể parse JSON từ AI: {}", ex.getMessage());
        }
        return result;
    }

    /**
     * Tách từ vựng tiếng Việt/tiếng Anh (loại bỏ dấu câu và từ dừng cơ bản) phục vụ chấm điểm BM25 cho RAG.
     */
    private List<String> tokenizeVietnamese(String text) {
        if (text == null || text.isBlank()) {
            return List.of();
        }
        Set<String> stopWords = Set.of("và", "của", "là", "các", "trong", "cho", "với", "được", "một", "những", "này", "khi", "để");
        return Arrays.stream(text.toLowerCase(Locale.ROOT)
                        .replaceAll("[^\\p{L}\\p{N}\\s]", " ")
                        .split("\\s+"))
                .map(String::trim)
                .filter(t -> t.length() >= 2 && !stopWords.contains(t))
                .toList();
    }

    private String resolveApiKey(String apiKeyInput) {
        if (apiKeyInput != null && !apiKeyInput.isBlank()) {
            return apiKeyInput.trim();
        }
        return defaultApiKey == null ? "" : defaultApiKey.trim();
    }

    private String cleanJsonFence(String raw) {
        if (raw == null) return "[]";
        String trimmed = raw.trim();
        if (trimmed.startsWith("```")) {
            int firstNewLine = trimmed.indexOf('\n');
            if (firstNewLine > 0) {
                trimmed = trimmed.substring(firstNewLine + 1);
            }
            if (trimmed.endsWith("```")) {
                trimmed = trimmed.substring(0, trimmed.length() - 3);
            }
        }
        return trimmed.trim();
    }

    private String textOrNull(JsonNode node, String field) {
        if (node == null || !node.hasNonNull(field)) return null;
        String val = node.get(field).asText("");
        return val.isBlank() ? null : val.trim();
    }

    private String normalizeType(String raw, String fallback) {
        String candidate = (raw != null && !raw.isBlank()) ? raw.trim().toUpperCase(Locale.ROOT) : "";
        if (Set.of("SINGLE_CHOICE", "MULTIPLE_CHOICE", "TRUE_FALSE", "ESSAY").contains(candidate)) {
            return candidate;
        }
        if (fallback != null && Set.of("SINGLE_CHOICE", "MULTIPLE_CHOICE", "TRUE_FALSE", "ESSAY").contains(fallback.toUpperCase(Locale.ROOT))) {
            return fallback.toUpperCase(Locale.ROOT);
        }
        return "SINGLE_CHOICE";
    }

    private String normalizeDifficulty(String raw, String fallback) {
        String candidate = (raw != null && !raw.isBlank()) ? raw.trim().toUpperCase(Locale.ROOT) : "";
        if (Set.of("EASY", "MEDIUM", "HARD").contains(candidate)) {
            return candidate;
        }
        if (fallback != null && Set.of("EASY", "MEDIUM", "HARD").contains(fallback.toUpperCase(Locale.ROOT))) {
            return fallback.toUpperCase(Locale.ROOT);
        }
        return "MEDIUM";
    }
}
