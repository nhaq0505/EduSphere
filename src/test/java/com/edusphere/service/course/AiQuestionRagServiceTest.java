package com.edusphere.service.course;

import com.edusphere.dto.quiz.AiRagGenerationResultDto.AiDraftQuestionDto;
import com.edusphere.dto.quiz.AiRagGenerationResultDto.RagChunkDto;
import com.edusphere.repository.course.CourseRepository;
import com.edusphere.repository.course.LessonRepository;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.*;

@ExtendWith(MockitoExtension.class)
class AiQuestionRagServiceTest {

    @Mock
    private CourseRepository courseRepository;

    @Mock
    private LessonRepository lessonRepository;

    private AiQuestionRagService aiQuestionRagService;

    @BeforeEach
    void setUp() {
        aiQuestionRagService = new AiQuestionRagService(
                courseRepository, lessonRepository, new ObjectMapper());
    }

    @Test
    void chunkAndRetrieveTopKChunks_ranksMostRelevantChunkFirst() {
        Map<String, String> docs = new LinkedHashMap<>();
        docs.put("Bài 1: HTML & CSS", "HTML là ngôn ngữ đánh dấu siêu văn bản. CSS dùng để định kiểu giao diện.");
        docs.put("Bài 2: Spring Transaction", "Annotation @Transactional trong Spring giúp quản lý giao dịch cơ sở dữ liệu và tự động rollback khi xảy ra RuntimeException.");
        docs.put("Bài 3: SQL JOIN", "LEFT JOIN giữ lại toàn bộ bản ghi ở bảng bên trái kể cả khi không khớp bảng phải.");

        List<RagChunkDto> chunks = aiQuestionRagService.chunkDocuments(docs);
        assertEquals(3, chunks.size());

        List<RagChunkDto> top = aiQuestionRagService.retrieveTopKChunks(
                chunks, "Transactional rollback giao dịch", 1);

        assertEquals(1, top.size());
        assertEquals("Bài 2: Spring Transaction", top.get(0).getSourceTitle());
        assertTrue(top.get(0).getRelevanceScore() > 0);
    }

    @Test
    void parseAiJsonToDrafts_parsesMarkdownFencedJsonCorrectly() {
        String rawAiResponse = """
                ```json
                [
                  {
                    "content": "Annotation nào giúp tự động rollback giao dịch khi có RuntimeException?",
                    "type": "SINGLE_CHOICE",
                    "difficultyLevel": "MEDIUM",
                    "defaultScore": 1.5,
                    "optionA": "@Transactional",
                    "optionB": "@Controller",
                    "optionC": "@Autowired",
                    "optionD": "@Bean",
                    "correctAnswer": "A",
                    "explanation": "Theo Bài 2, @Transactional quản lý giao dịch và tự động rollback.",
                    "sourceExcerpt": "[Nguồn #1 - Bài 2: Spring Transaction]"
                  }
                ]
                ```
                """;

        List<AiDraftQuestionDto> drafts = aiQuestionRagService.parseAiJsonToDrafts(
                rawAiResponse, "SINGLE_CHOICE", "MEDIUM");

        assertEquals(1, drafts.size());
        AiDraftQuestionDto q = drafts.get(0);
        assertEquals("SINGLE_CHOICE", q.getType());
        assertEquals("@Transactional", q.getOptionA());
        assertEquals("A", q.getCorrectAnswer());
        assertEquals("[Nguồn #1 - Bài 2: Spring Transaction]", q.getSourceExcerpt());
    }

    @Test
    void geminiErrorMessage_explainsLeakedInvalidAndQuotaErrors() {
        String leaked = "{\"error\":{\"code\":403,\"message\":\"Your API key was reported as leaked. Please use another API key.\",\"status\":\"PERMISSION_DENIED\"}}";
        assertTrue(AiQuestionRagService.geminiErrorMessage(403, leaked).contains("bị lộ"));

        String invalid = "{\"error\":{\"code\":400,\"message\":\"API key not valid. Please pass a valid API key.\",\"details\":[{\"reason\":\"API_KEY_INVALID\"}]}}";
        assertTrue(AiQuestionRagService.geminiErrorMessage(400, invalid).contains("không hợp lệ"));

        assertTrue(AiQuestionRagService.geminiErrorMessage(429, "{}").contains("hạn mức"));
        assertTrue(AiQuestionRagService.geminiErrorMessage(500, null).contains("HTTP 500"));
    }
}
