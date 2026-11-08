package com.edusphere.service.course;

import com.edusphere.dto.quiz.ImportResultDto;
import com.edusphere.dto.quiz.ParsedQuestionDto;
import com.edusphere.dto.quiz.ParsedQuestionDto.ParsedOptionDto;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.CellType;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.ss.usermodel.WorkbookFactory;
import org.apache.poi.xwpf.usermodel.XWPFDocument;
import org.apache.poi.xwpf.usermodel.XWPFParagraph;
import org.apache.poi.xwpf.usermodel.XWPFPictureData;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

@Slf4j
@Service
@RequiredArgsConstructor
public class QuestionImportService {

    private final FileUploadService fileUploadService;

    public static String normalizeTrueFalse(String val) {
        if (val == null) return null;
        String s = val.trim();
        if (s.isEmpty()) return null;
        String upper = s.toUpperCase(Locale.ROOT);
        if (upper.equals("TRUE") || upper.equals("ĐÚNG") || upper.equals("DUNG") || upper.equals("1")
                || upper.equals("T") || upper.equals("YES") || upper.equals("Y") || upper.equals("A")) {
            return "TRUE";
        }
        if (upper.equals("FALSE") || upper.equals("SAI") || upper.equals("0")
                || upper.equals("F") || upper.equals("NO") || upper.equals("N") || upper.equals("B")) {
            return "FALSE";
        }
        return upper;
    }

    private void finalizeParsedQuestion(ParsedQuestionDto q) {
        if (q == null) return;
        if (!"ESSAY".equals(q.getType()) && !"SHORT_ANSWER".equals(q.getType()) && q.getOptions().size() == 2) {
            String opt0 = q.getOptions().get(0).getContent() != null ? q.getOptions().get(0).getContent().trim().toUpperCase(Locale.ROOT) : "";
            String opt1 = q.getOptions().get(1).getContent() != null ? q.getOptions().get(1).getContent().trim().toUpperCase(Locale.ROOT) : "";
            if ((opt0.contains("ĐÚNG") || opt0.contains("TRUE")) && (opt1.contains("SAI") || opt1.contains("FALSE"))) {
                q.setType("TRUE_FALSE");
            }
        }

        if ("TRUE_FALSE".equals(q.getType())) {
            if (q.getOptions().isEmpty()) {
                String tf = q.getCorrectAnswer() != null ? normalizeTrueFalse(q.getCorrectAnswer()) : "TRUE";
                q.setCorrectAnswer(tf);
                addOption(q, "Đúng", "TRUE".equalsIgnoreCase(tf), 1);
                addOption(q, "Sai", "FALSE".equalsIgnoreCase(tf), 2);
            } else {
                if (q.getCorrectAnswer() == null) {
                    ParsedOptionDto first = q.getOptions().get(0);
                    if (first.isCorrect()) {
                        q.setCorrectAnswer("TRUE");
                    } else if (q.getOptions().size() > 1 && q.getOptions().get(1).isCorrect()) {
                        q.setCorrectAnswer("FALSE");
                    } else {
                        q.setCorrectAnswer("TRUE");
                        first.setCorrect(true);
                    }
                } else {
                    String tf = normalizeTrueFalse(q.getCorrectAnswer());
                    q.setCorrectAnswer(tf);
                    if (!q.getOptions().isEmpty()) q.getOptions().get(0).setCorrect("TRUE".equalsIgnoreCase(tf));
                    if (q.getOptions().size() > 1) q.getOptions().get(1).setCorrect("FALSE".equalsIgnoreCase(tf));
                }
            }
        }
    }

    public ImportResultDto parseFile(MultipartFile file) {
        String filename = file.getOriginalFilename();
        if (filename == null) {
            throw new IllegalArgumentException("Tên tệp không hợp lệ");
        }
        String lower = filename.toLowerCase(Locale.ROOT);

        try (InputStream is = file.getInputStream()) {
            if (lower.endsWith(".csv")) {
                return parseCsv(is);
            } else if (lower.endsWith(".xlsx") || lower.endsWith(".xls")) {
                return parseExcel(is);
            } else if (lower.endsWith(".docx")) {
                return parseWordDocx(is);
            } else {
                throw new IllegalArgumentException("Định dạng tệp không được hỗ trợ. Vui lòng tải file .csv, .xlsx hoặc .docx");
            }
        } catch (Exception e) {
            log.error("Lỗi khi đọc file câu hỏi: {}", e.getMessage(), e);
            ImportResultDto res = new ImportResultDto();
            res.getWarnings().add("Lỗi đọc file: " + e.getMessage());
            return res;
        }
    }

    // ==========================================
    // 1. CSV PARSER
    // ==========================================
    public ImportResultDto parseCsv(InputStream is) {
        ImportResultDto result = new ImportResultDto();
        List<ParsedQuestionDto> list = new ArrayList<>();

        try (BufferedReader reader = new BufferedReader(new InputStreamReader(is, StandardCharsets.UTF_8))) {
            String line;
            int lineNum = 0;
            while ((line = reader.readLine()) != null) {
                lineNum++;
                line = line.trim();
                if (line.isEmpty()) continue;

                // Bỏ qua header
                if (lineNum == 1 && (line.toLowerCase().contains("nội dung") || line.toLowerCase().contains("content") || line.toLowerCase().contains("loại"))) {
                    continue;
                }

                String[] cols = parseCsvLine(line);
                if (cols.length < 2) {
                    result.getWarnings().add("Dòng " + lineNum + ": Bỏ qua vì không đủ thông tin.");
                    continue;
                }

                String content = cols[0].trim();
                if (content.isEmpty()) continue;

                String type = parseType(cols.length > 1 ? cols[1] : "");
                String diff = parseDiff(cols.length > 2 ? cols[2] : "");

                ParsedQuestionDto q = ParsedQuestionDto.builder()
                        .content(content)
                        .type(type)
                        .difficultyLevel(diff)
                        .build();

                if ("ESSAY".equals(type) || "SHORT_ANSWER".equals(type)) {
                    // Câu tự luận: nếu có đáp án gợi ý ở cột tiếp theo
                    if (cols.length > 3) q.setSampleEssayAnswer(cols[3].trim());
                    if (cols.length > 4) q.setExplanation(cols[4].trim());
                } else if ("TRUE_FALSE".equals(type)) {
                    String optA = cols.length > 3 && !cols[3].trim().isEmpty() ? cols[3].trim() : "Đúng";
                    String optB = cols.length > 4 && !cols[4].trim().isEmpty() ? cols[4].trim() : "Sai";
                    String rawAns = cols.length > 7 ? cols[7].trim() : "A";
                    String tf = normalizeTrueFalse(rawAns);
                    if (tf == null) {
                        String upper = rawAns.toUpperCase(Locale.ROOT);
                        tf = (upper.contains("B") || upper.contains("SAI") || upper.contains("2") || upper.contains("F")) ? "FALSE" : "TRUE";
                    }
                    q.setCorrectAnswer(tf);
                    addOption(q, optA, "TRUE".equalsIgnoreCase(tf), 1);
                    addOption(q, optB, "FALSE".equalsIgnoreCase(tf), 2);

                    String explanation = cols.length > 8 ? cols[8].trim() : "";
                    String imgUrl = cols.length > 9 ? cols[9].trim() : "";
                    q.setExplanation(explanation);
                    q.setImageUrl(imgUrl.isEmpty() ? null : imgUrl);
                } else {
                    // Câu trắc nghiệm: cột 3..6 là A, B, C, D
                    String optA = cols.length > 3 ? cols[3].trim() : "";
                    String optB = cols.length > 4 ? cols[4].trim() : "";
                    String optC = cols.length > 5 ? cols[5].trim() : "";
                    String optD = cols.length > 6 ? cols[6].trim() : "";
                    String correct = cols.length > 7 ? cols[7].trim().toUpperCase() : "A";
                    String explanation = cols.length > 8 ? cols[8].trim() : "";
                    String imgUrl = cols.length > 9 ? cols[9].trim() : "";

                    addOption(q, optA, correct.contains("A"), 1);
                    addOption(q, optB, correct.contains("B"), 2);
                    if (!optC.isEmpty()) addOption(q, optC, correct.contains("C"), 3);
                    if (!optD.isEmpty()) addOption(q, optD, correct.contains("D"), 4);

                    q.setExplanation(explanation);
                    q.setImageUrl(imgUrl.isEmpty() ? null : imgUrl);
                }

                finalizeParsedQuestion(q);
                list.add(q);
            }
        } catch (Exception e) {
            result.getWarnings().add("Lỗi đọc CSV: " + e.getMessage());
        }

        result.setTotalRead(list.size());
        result.setSuccessCount(list.size());
        result.setValidQuestions(list);
        return result;
    }

    private String[] parseCsvLine(String line) {
        List<String> tokens = new ArrayList<>();
        StringBuilder sb = new StringBuilder();
        boolean inQuotes = false;
        char delimiter = line.contains(";") && !line.contains(",") ? ';' : ',';

        for (int i = 0; i < line.length(); i++) {
            char c = line.charAt(i);
            if (c == '"') {
                inQuotes = !inQuotes;
            } else if (c == delimiter && !inQuotes) {
                tokens.add(sb.toString().trim());
                sb.setLength(0);
            } else {
                sb.append(c);
            }
        }
        tokens.add(sb.toString().trim());
        return tokens.toArray(new String[0]);
    }

    // ==========================================
    // 2. EXCEL PARSER (.xlsx, .xls)
    // ==========================================
    public ImportResultDto parseExcel(InputStream is) {
        ImportResultDto result = new ImportResultDto();
        List<ParsedQuestionDto> list = new ArrayList<>();

        try (Workbook workbook = WorkbookFactory.create(is)) {
            Sheet sheet = workbook.getSheetAt(0);
            int rowIdx = 0;

            for (Row row : sheet) {
                rowIdx++;
                if (row == null) continue;

                // Bỏ qua header ở dòng 1
                if (rowIdx == 1) {
                    String firstCell = getCellText(row.getCell(0));
                    if (firstCell.toLowerCase().contains("nội dung") || firstCell.toLowerCase().contains("câu hỏi")) {
                        continue;
                    }
                }

                String content = getCellText(row.getCell(0));
                if (content.isEmpty()) continue;

                String typeRaw = getCellText(row.getCell(1));
                String diffRaw = getCellText(row.getCell(2));
                String type = parseType(typeRaw);
                String diff = parseDiff(diffRaw);

                ParsedQuestionDto q = ParsedQuestionDto.builder()
                        .content(content)
                        .type(type)
                        .difficultyLevel(diff)
                        .build();

                if ("ESSAY".equals(type) || "SHORT_ANSWER".equals(type)) {
                    q.setSampleEssayAnswer(getCellText(row.getCell(3)));
                    q.setExplanation(getCellText(row.getCell(4)));
                    String imgUrl = getCellText(row.getCell(5));
                    if (!imgUrl.isEmpty()) q.setImageUrl(imgUrl);
                } else if ("TRUE_FALSE".equals(type)) {
                    String optA = getCellText(row.getCell(3));
                    if (optA.isEmpty()) optA = "Đúng";
                    String optB = getCellText(row.getCell(4));
                    if (optB.isEmpty()) optB = "Sai";
                    String rawAns = getCellText(row.getCell(7));
                    String tf = normalizeTrueFalse(rawAns);
                    if (tf == null) {
                        String upper = rawAns.toUpperCase(Locale.ROOT);
                        tf = (upper.contains("B") || upper.contains("SAI") || upper.contains("2") || upper.contains("F")) ? "FALSE" : "TRUE";
                    }
                    q.setCorrectAnswer(tf);
                    addOption(q, optA, "TRUE".equalsIgnoreCase(tf), 1);
                    addOption(q, optB, "FALSE".equalsIgnoreCase(tf), 2);

                    String explanation = getCellText(row.getCell(8));
                    String imgUrl = getCellText(row.getCell(9));
                    q.setExplanation(explanation);
                    q.setImageUrl(imgUrl.isEmpty() ? null : imgUrl);
                } else {
                    String optA = getCellText(row.getCell(3));
                    String optB = getCellText(row.getCell(4));
                    String optC = getCellText(row.getCell(5));
                    String optD = getCellText(row.getCell(6));
                    String correct = getCellText(row.getCell(7)).toUpperCase();
                    String explanation = getCellText(row.getCell(8));
                    String imgUrl = getCellText(row.getCell(9));

                    addOption(q, optA, correct.contains("A") || correct.contains("1"), 1);
                    addOption(q, optB, correct.contains("B") || correct.contains("2"), 2);
                    if (!optC.isEmpty()) addOption(q, optC, correct.contains("C") || correct.contains("3"), 3);
                    if (!optD.isEmpty()) addOption(q, optD, correct.contains("D") || correct.contains("4"), 4);

                    q.setExplanation(explanation);
                    q.setImageUrl(imgUrl.isEmpty() ? null : imgUrl);
                }

                finalizeParsedQuestion(q);
                list.add(q);
            }
        } catch (Exception e) {
            result.getWarnings().add("Lỗi đọc Excel: " + e.getMessage());
        }

        result.setTotalRead(list.size());
        result.setSuccessCount(list.size());
        result.setValidQuestions(list);
        return result;
    }

    private String getCellText(Cell cell) {
        if (cell == null) return "";
        if (cell.getCellType() == CellType.STRING) return cell.getStringCellValue().trim();
        if (cell.getCellType() == CellType.NUMERIC) {
            double val = cell.getNumericCellValue();
            if (val == (long) val) return String.valueOf((long) val);
            return String.valueOf(val);
        }
        if (cell.getCellType() == CellType.BOOLEAN) return String.valueOf(cell.getBooleanCellValue());
        return "";
    }

    // ==========================================
    // 3. WORD PARSER (.docx) kèm trích xuất ảnh nhúng
    // ==========================================
    public ImportResultDto parseWordDocx(InputStream is) {
        ImportResultDto result = new ImportResultDto();
        List<ParsedQuestionDto> list = new ArrayList<>();

        try (XWPFDocument doc = new XWPFDocument(is)) {
            // Trích xuất toàn bộ ảnh nhúng trong tài liệu Word
            List<String> extractedImageUrls = new ArrayList<>();
            for (XWPFPictureData pic : doc.getAllPictures()) {
                byte[] data = pic.getData();
                String ext = pic.suggestFileExtension();
                String storedUrl = fileUploadService.storeBytes(data, ext, "questions");
                if (storedUrl != null) {
                    extractedImageUrls.add(storedUrl);
                }
            }

            Pattern qPattern = Pattern.compile("^(Câu|Question)\\s*\\d*[:.]\\s*(.*)$", Pattern.CASE_INSENSITIVE);
            Pattern optPattern = Pattern.compile("^([A-D])[.:)]\\s*(.*)$");
            Pattern ansPattern = Pattern.compile("^(Đáp\\s*án|Answer)[:.]\\s*(.*)$", Pattern.CASE_INSENSITIVE);
            Pattern expPattern = Pattern.compile("^(Lời\\s*giải|Giải\\s*thích|Explanation)[:.]\\s*(.*)$", Pattern.CASE_INSENSITIVE);

            ParsedQuestionDto current = null;
            int picIndex = 0;

            for (XWPFParagraph p : doc.getParagraphs()) {
                String text = p.getText().trim();
                if (text.isEmpty()) continue;

                Matcher qMatcher = qPattern.matcher(text);
                Matcher optMatcher = optPattern.matcher(text);
                Matcher ansMatcher = ansPattern.matcher(text);
                Matcher expMatcher = expPattern.matcher(text);

                if (qMatcher.find()) {
                    // Lưu câu trước đó nếu có
                    if (current != null && current.getContent() != null && !current.getContent().isEmpty()) {
                        finalizeParsedQuestion(current);
                        list.add(current);
                    }

                    String qContent = qMatcher.group(2).trim();
                    if (qContent.isEmpty()) qContent = text; // Trường hợp "Câu 1:" ở dòng trên

                    boolean isEssay = text.toLowerCase().contains("[tự luận]") || text.toLowerCase().contains("[essay]");
                    boolean isTf = text.toLowerCase().contains("[đúng sai]") || text.toLowerCase().contains("[true_false]") || text.toLowerCase().contains("[đúng/sai]");

                    current = ParsedQuestionDto.builder()
                            .content(qContent)
                            .type(isEssay ? "ESSAY" : (isTf ? "TRUE_FALSE" : "SINGLE_CHOICE"))
                            .difficultyLevel(parseDiff(text))
                            .build();

                    // Gán ảnh nhúng tương ứng nếu trong paragraph này có ảnh
                    if (!p.getRuns().isEmpty()) {
                        boolean hasPicture = p.getRuns().stream().anyMatch(r -> !r.getEmbeddedPictures().isEmpty());
                        if (hasPicture && picIndex < extractedImageUrls.size()) {
                            current.setImageUrl(extractedImageUrls.get(picIndex++));
                        }
                    }
                } else if (optMatcher.find() && current != null) {
                    String optLabel = optMatcher.group(1).toUpperCase();
                    String optText = optMatcher.group(2).trim();
                    int order = optLabel.charAt(0) - 'A' + 1;
                    addOption(current, optText, false, order);
                } else if (ansMatcher.find() && current != null) {
                    String ansVal = ansMatcher.group(2).trim();
                    if ("ESSAY".equals(current.getType())) {
                        current.setSampleEssayAnswer(ansVal);
                    } else if ("TRUE_FALSE".equals(current.getType()) || ansVal.equalsIgnoreCase("Đúng") || ansVal.equalsIgnoreCase("Sai") || ansVal.equalsIgnoreCase("True") || ansVal.equalsIgnoreCase("False")) {
                        String tf = normalizeTrueFalse(ansVal);
                        if (tf == null) {
                            String upper = ansVal.toUpperCase(Locale.ROOT);
                            tf = (upper.contains("B") || upper.contains("SAI") || upper.contains("2") || upper.contains("F")) ? "FALSE" : "TRUE";
                        }
                        current.setType("TRUE_FALSE");
                        current.setCorrectAnswer(tf);
                    } else {
                        // Cập nhật isCorrect cho các đáp án đã đọc
                        String upper = ansVal.toUpperCase(Locale.ROOT);
                        for (int i = 0; i < current.getOptions().size(); i++) {
                            char letter = (char) ('A' + i);
                            if (upper.contains(String.valueOf(letter))) {
                                current.getOptions().get(i).setCorrect(true);
                            }
                        }
                    }
                } else if (expMatcher.find() && current != null) {
                    current.setExplanation(expMatcher.group(2).trim());
                } else if (current != null) {
                    // Nối tiếp văn bản mô tả nếu đề bài nhiều dòng
                    if (current.getOptions().isEmpty()) {
                        current.setContent(current.getContent() + "\n" + text);
                    }
                }
            }

            // Lưu câu cuối cùng
            if (current != null && current.getContent() != null && !current.getContent().isEmpty()) {
                finalizeParsedQuestion(current);
                list.add(current);
            }
        } catch (Exception e) {
            result.getWarnings().add("Lỗi đọc Word (.docx): " + e.getMessage());
        }

        result.setTotalRead(list.size());
        result.setSuccessCount(list.size());
        result.setValidQuestions(list);
        return result;
    }

    private void addOption(ParsedQuestionDto q, String text, boolean correct, int order) {
        if (text == null || text.isEmpty()) return;
        q.getOptions().add(new ParsedOptionDto(text, correct, order));
    }

    private String parseType(String raw) {
        if (raw == null) return "SINGLE_CHOICE";
        String s = raw.trim().toUpperCase();
        if (s.contains("ESSAY") || s.contains("TỰ LUẬN") || s.contains("TU_LUAN")) return "ESSAY";
        if (s.contains("SHORT") || s.contains("ĐIỀN")) return "SHORT_ANSWER";
        if (s.contains("TRUE") || s.contains("ĐÚNG SAI") || s.contains("DUNG_SAI")) return "TRUE_FALSE";
        if (s.contains("MULTI") || s.contains("NHIỀU")) return "MULTIPLE_CHOICE";
        return "SINGLE_CHOICE";
    }

    private String parseDiff(String raw) {
        if (raw == null) return "MEDIUM";
        String s = raw.trim().toUpperCase();
        if (s.contains("EASY") || s.contains("DỄ") || s.contains("DE")) return "EASY";
        if (s.contains("HARD") || s.contains("KHÓ") || s.contains("KHO")) return "HARD";
        return "MEDIUM";
    }
}

