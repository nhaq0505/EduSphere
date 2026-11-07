package com.edusphere.service.course;

import com.edusphere.dto.quiz.ImportResultDto;
import com.edusphere.dto.quiz.ParsedQuestionDto;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.apache.poi.xwpf.usermodel.XWPFDocument;
import org.apache.poi.xwpf.usermodel.XWPFParagraph;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.mock.web.MockMultipartFile;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;

@ExtendWith(MockitoExtension.class)
class QuestionImportServiceTest {

    @Mock
    private FileUploadService fileUploadService;

    private QuestionImportService importService;

    @BeforeEach
    void setUp() {
        importService = new QuestionImportService(fileUploadService);
    }

    @Test
    void testParseCsvQuestions() {
        String csvContent = "Content,OptionA,OptionB,OptionC,OptionD,CorrectAnswer,Explanation,Type,Difficulty,Score\n"
                + "\"Thủ đô của Việt Nam là gì?\",\"Hà Nội\",\"Hồ Chí Minh\",\"Đà Nẵng\",\"Huế\",\"A\",\"Hà Nội là thủ đô của Việt Nam.\",\"SINGLE_CHOICE\",\"EASY\",1.0\n"
                + "\"Chọn các số nguyên tố:\",\"2\",\"3\",\"4\",\"5\",\"A,B,D\",\"2, 3, 5 là các số nguyên tố.\",\"MULTIPLE_CHOICE\",\"MEDIUM\",2.0\n"
                + "\"Mặt trời mọc ở hướng Đông?\",\"Đúng\",\"Sai\",\"\",\"\",\"Đúng\",\"Mặt trời luôn mọc ở hướng đông.\",\"TRUE_FALSE\",\"EASY\",1.0\n"
                + "\"Nêu cảm nghĩ về bài thơ Tây Tiến.\",\"\",\"\",\"\",\"\",\"Bài làm nêu được các ý chính...\",\"Thang điểm phân bổ theo bố cục.\",\"ESSAY\",\"HARD\",3.0\n";

        MockMultipartFile file = new MockMultipartFile(
                "file",
                "test.csv",
                "text/csv",
                csvContent.getBytes(StandardCharsets.UTF_8)
        );

        ImportResultDto result = importService.parseFile(file);

        assertNotNull(result);
        assertEquals(4, result.getSuccessCount());
        assertEquals(0, result.getErrorCount());
        assertEquals(4, result.getValidQuestions().size());

        // Check single choice
        ParsedQuestionDto q1 = result.getValidQuestions().get(0);
        assertEquals("Thủ đô của Việt Nam là gì?", q1.getContent());
        assertEquals("SINGLE_CHOICE", q1.getType());
        assertEquals("EASY", q1.getDifficultyLevel());
        assertEquals(4, q1.getOptions().size());
        assertTrue(q1.getOptions().get(0).isCorrect()); // Option A
        assertFalse(q1.getOptions().get(1).isCorrect());

        // Check multiple choice
        ParsedQuestionDto q2 = result.getValidQuestions().get(1);
        assertEquals("MULTIPLE_CHOICE", q2.getType());
        assertTrue(q2.getOptions().get(0).isCorrect()); // A
        assertTrue(q2.getOptions().get(1).isCorrect()); // B
        assertFalse(q2.getOptions().get(2).isCorrect()); // C
        assertTrue(q2.getOptions().get(3).isCorrect()); // D

        // Check essay
        ParsedQuestionDto q4 = result.getValidQuestions().get(3);
        assertEquals("ESSAY", q4.getType());
        assertEquals("HARD", q4.getDifficultyLevel());
        assertEquals("Bài làm nêu được các ý chính...", q4.getSampleEssayAnswer());
    }

    @Test
    void testParseExcelQuestions() throws IOException {
        ByteArrayOutputStream bos = new ByteArrayOutputStream();
        try (Workbook wb = new XSSFWorkbook()) {
            Sheet sheet = wb.createSheet("Questions");
            // Header
            Row header = sheet.createRow(0);
            header.createCell(0).setCellValue("Content");
            header.createCell(1).setCellValue("OptionA");
            header.createCell(2).setCellValue("OptionB");
            header.createCell(3).setCellValue("OptionC");
            header.createCell(4).setCellValue("OptionD");
            header.createCell(5).setCellValue("CorrectAnswer");
            header.createCell(6).setCellValue("Explanation");
            header.createCell(7).setCellValue("Type");
            header.createCell(8).setCellValue("Difficulty");
            header.createCell(9).setCellValue("Score");

            // Row 1
            Row r1 = sheet.createRow(1);
            r1.createCell(0).setCellValue("1 + 1 bằng mấy?");
            r1.createCell(1).setCellValue("1");
            r1.createCell(2).setCellValue("2");
            r1.createCell(3).setCellValue("3");
            r1.createCell(4).setCellValue("4");
            r1.createCell(5).setCellValue("B");
            r1.createCell(6).setCellValue("Phép tính cơ bản");
            r1.createCell(7).setCellValue("SINGLE_CHOICE");
            r1.createCell(8).setCellValue("EASY");
            r1.createCell(9).setCellValue(1.0);

            wb.write(bos);
        }

        MockMultipartFile file = new MockMultipartFile(
                "file",
                "questions.xlsx",
                "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
                bos.toByteArray()
        );

        ImportResultDto result = importService.parseFile(file);

        assertNotNull(result);
        assertEquals(1, result.getSuccessCount());
        ParsedQuestionDto q = result.getValidQuestions().get(0);
        assertEquals("1 + 1 bằng mấy?", q.getContent());
        assertEquals(4, q.getOptions().size());
        assertTrue(q.getOptions().get(1).isCorrect()); // B is correct
    }

    @Test
    void testParseWordDocxQuestions() throws IOException {
        ByteArrayOutputStream bos = new ByteArrayOutputStream();
        try (XWPFDocument doc = new XWPFDocument()) {
            XWPFParagraph p1 = doc.createParagraph();
            p1.createRun().setText("Câu 1: Đâu là ngôn ngữ lập trình chạy trên máy ảo JVM?");
            XWPFParagraph p2 = doc.createParagraph();
            p2.createRun().setText("A. Java");
            XWPFParagraph p3 = doc.createParagraph();
            p3.createRun().setText("B. C++");
            XWPFParagraph p4 = doc.createParagraph();
            p4.createRun().setText("C. Python");
            XWPFParagraph p5 = doc.createParagraph();
            p5.createRun().setText("D. Ruby");
            XWPFParagraph p6 = doc.createParagraph();
            p6.createRun().setText("Đáp án: A");
            XWPFParagraph p7 = doc.createParagraph();
            p7.createRun().setText("Lời giải: Java biên dịch ra bytecode và chạy trên JVM.");

            // Câu 2: Tự luận
            XWPFParagraph p8 = doc.createParagraph();
            p8.createRun().setText("Câu 2: [Tự luận] Trình bày chu trình sống của một Thread trong Java.");
            XWPFParagraph p9 = doc.createParagraph();
            p9.createRun().setText("Lời giải: Các trạng thái New, Runnable, Blocked, Waiting, Terminated.");

            doc.write(bos);
        }

        MockMultipartFile file = new MockMultipartFile(
                "file",
                "quiz_exam.docx",
                "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
                bos.toByteArray()
        );

        ImportResultDto result = importService.parseFile(file);

        assertNotNull(result);
        assertEquals(2, result.getSuccessCount());

        ParsedQuestionDto q1 = result.getValidQuestions().get(0);
        assertTrue(q1.getContent().contains("ngôn ngữ lập trình chạy trên máy ảo JVM"));
        assertEquals("SINGLE_CHOICE", q1.getType());
        assertEquals(4, q1.getOptions().size());
        assertTrue(q1.getOptions().get(0).isCorrect()); // A is correct

        ParsedQuestionDto q2 = result.getValidQuestions().get(1);
        assertEquals("ESSAY", q2.getType());
        assertTrue(q2.getContent().contains("chu trình sống của một Thread"));
        assertTrue(q2.getSampleEssayAnswer().contains("New, Runnable, Blocked"));
    }

    @Test
    void testUnsupportedFormatThrowsException() {
        MockMultipartFile file = new MockMultipartFile(
                "file",
                "file.pdf",
                "application/pdf",
                new byte[]{1, 2, 3}
        );

        assertThrows(CourseActionException.class, () -> importService.parseFile(file));
    }
}

