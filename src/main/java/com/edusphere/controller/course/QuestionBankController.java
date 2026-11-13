package com.edusphere.controller.course;

import com.edusphere.dto.quiz.AiRagGenerationResultDto;
import com.edusphere.dto.quiz.BankQuestionForm;
import com.edusphere.dto.quiz.ImportResultDto;
import com.edusphere.dto.quiz.ParsedQuestionDto;
import com.edusphere.dto.quiz.ParsedQuestionDto.ParsedOptionDto;
import com.edusphere.dto.quiz.QuestionBankForm;
import com.edusphere.entity.course.BankAnswerOption;
import com.edusphere.entity.course.BankQuestion;
import com.edusphere.entity.course.Lesson;
import com.edusphere.entity.course.QuestionBank;
import com.edusphere.repository.course.CourseRepository;
import com.edusphere.repository.course.LessonRepository;
import com.edusphere.security.CustomUserDetails;
import com.edusphere.service.course.AiQuestionRagService;
import com.edusphere.service.course.CourseActionException;
import com.edusphere.service.course.FileUploadService;
import com.edusphere.service.course.QuestionBankService;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.poi.xwpf.usermodel.ParagraphAlignment;
import org.apache.poi.xwpf.usermodel.XWPFDocument;
import org.apache.poi.xwpf.usermodel.XWPFParagraph;
import org.apache.poi.xwpf.usermodel.XWPFRun;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Slf4j
@Controller
@RequestMapping("/instructor/question-banks")
@RequiredArgsConstructor
public class QuestionBankController {

    private final QuestionBankService questionBankService;
    private final CourseRepository courseRepository;
    private final LessonRepository lessonRepository;
    private final FileUploadService fileUploadService;
    private final AiQuestionRagService aiQuestionRagService;

    // ==========================================
    // 1. DANH SÁCH NGÂN HÀNG CỦA GIẢNG VIÊN
    // ==========================================

    @GetMapping
    public String listBanks(@AuthenticationPrincipal CustomUserDetails user, Model model) {
        Integer instructorId = user.getUserId();
        model.addAttribute("banks", questionBankService.listBanksForInstructor(instructorId));
        model.addAttribute("courses", courseRepository.findByInstructor_UserIdOrderByCreatedAtDesc(instructorId));
        model.addAttribute("bankForm", new QuestionBankForm());
        return "quizzes/bank-list";
    }

    @PostMapping
    public String createBank(@Valid @ModelAttribute("bankForm") QuestionBankForm form,
                             BindingResult errors,
                             @AuthenticationPrincipal CustomUserDetails user,
                             Model model,
                             RedirectAttributes flash) {
        if (errors.hasErrors()) {
            Integer instructorId = user.getUserId();
            model.addAttribute("banks", questionBankService.listBanksForInstructor(instructorId));
            model.addAttribute("courses", courseRepository.findByInstructor_UserIdOrderByCreatedAtDesc(instructorId));
            return "quizzes/bank-list";
        }

        QuestionBank created = questionBankService.createBank(user.getUserId(), form);
        flash.addFlashAttribute("success", "Đã tạo ngân hàng câu hỏi thành công.");
        return "redirect:/instructor/question-banks/" + created.getBankId();
    }

    // ==========================================
    // 2. CHI TIẾT NGÂN HÀNG & DANH SÁCH CÂU HỎI
    // ==========================================

    @GetMapping("/{bankId}")
    public String viewBank(@PathVariable Integer bankId,
                           @RequestParam(required = false) Integer categoryId,
                           @AuthenticationPrincipal CustomUserDetails user,
                           HttpSession session,
                           Model model) {
        Integer instructorId = user.getUserId();
        QuestionBank bank = questionBankService.getBank(bankId, instructorId);
        var categories = questionBankService.listCategories(bankId, instructorId);
        var questions = questionBankService.listQuestions(bankId, instructorId, categoryId);

        List<Lesson> bankLessons = bank.getCourse() != null
                ? lessonRepository.findByCourse_CourseIdOrderByOrderIndexAsc(bank.getCourse().getCourseId())
                : List.of();

        model.addAttribute("bank", bank);
        model.addAttribute("categories", categories);
        model.addAttribute("questions", questions);
        model.addAttribute("selectedCategoryId", categoryId);
        model.addAttribute("courses", courseRepository.findByInstructor_UserIdOrderByCreatedAtDesc(instructorId));
        model.addAttribute("bankLessons", bankLessons);
        model.addAttribute("savedAiModel", session.getAttribute("INSTRUCTOR_AI_MODEL"));
        return "quizzes/bank-detail";
    }

    @PostMapping("/{bankId}/edit")
    public String updateBank(@PathVariable Integer bankId,
                             @Valid @ModelAttribute("bankForm") QuestionBankForm form,
                             @AuthenticationPrincipal CustomUserDetails user,
                             RedirectAttributes flash) {
        questionBankService.updateBank(bankId, user.getUserId(), form);
        flash.addFlashAttribute("success", "Đã cập nhật thông tin ngân hàng.");
        return "redirect:/instructor/question-banks/" + bankId;
    }

    @PostMapping("/{bankId}/delete")
    public String deleteBank(@PathVariable Integer bankId,
                             @AuthenticationPrincipal CustomUserDetails user,
                             RedirectAttributes flash) {
        questionBankService.deleteBank(bankId, user.getUserId());
        flash.addFlashAttribute("success", "Đã xóa ngân hàng câu hỏi.");
        return "redirect:/instructor/question-banks";
    }

    @PostMapping("/{bankId}/categories")
    public String addCategory(@PathVariable Integer bankId,
                              @RequestParam String name,
                              @RequestParam(required = false) String description,
                              @AuthenticationPrincipal CustomUserDetails user,
                              RedirectAttributes flash) {
        if (name == null || name.isBlank()) {
            flash.addFlashAttribute("error", "Tên chuyên đề không được để trống.");
        } else {
            questionBankService.addCategory(bankId, user.getUserId(), name.trim(), description);
            flash.addFlashAttribute("success", "Đã thêm chuyên đề mới.");
        }
        return "redirect:/instructor/question-banks/" + bankId;
    }

    // ==========================================
    // 3. THÊM / SỬA / XÓA CÂU HỎI TRONG BANK
    // ==========================================

    @GetMapping("/{bankId}/questions/new")
    public String newQuestionForm(@PathVariable Integer bankId,
                                  @AuthenticationPrincipal CustomUserDetails user,
                                  Model model) {
        Integer instructorId = user.getUserId();
        QuestionBank bank = questionBankService.getBank(bankId, instructorId);
        var categories = questionBankService.listCategories(bankId, instructorId);

        model.addAttribute("bank", bank);
        model.addAttribute("categories", categories);
        model.addAttribute("questionForm", new BankQuestionForm());
        model.addAttribute("isEdit", false);
        return "quizzes/bank-question-form";
    }

    @PostMapping("/{bankId}/questions")
    public String createQuestion(@PathVariable Integer bankId,
                                 @Valid @ModelAttribute("questionForm") BankQuestionForm form,
                                 BindingResult errors,
                                 @RequestParam(value = "imageFile", required = false) MultipartFile imageFile,
                                 @AuthenticationPrincipal CustomUserDetails user,
                                 Model model,
                                 RedirectAttributes flash) {
        Integer instructorId = user.getUserId();
        if (errors.hasErrors()) {
            QuestionBank bank = questionBankService.getBank(bankId, instructorId);
            model.addAttribute("bank", bank);
            model.addAttribute("categories", questionBankService.listCategories(bankId, instructorId));
            model.addAttribute("isEdit", false);
            return "quizzes/bank-question-form";
        }

        if (imageFile != null && !imageFile.isEmpty()) {
            String imgUrl = fileUploadService.storeFile(imageFile, "question");
            form.setImageUrl(imgUrl);
        }

        questionBankService.addQuestion(bankId, instructorId, form);
        flash.addFlashAttribute("success", "Đã thêm câu hỏi vào ngân hàng.");
        return "redirect:/instructor/question-banks/" + bankId;
    }

    @GetMapping("/{bankId}/questions/{questionId}/edit")
    public String editQuestionForm(@PathVariable Integer bankId,
                                   @PathVariable Integer questionId,
                                   @AuthenticationPrincipal CustomUserDetails user,
                                   Model model) {
        Integer instructorId = user.getUserId();
        QuestionBank bank = questionBankService.getBank(bankId, instructorId);
        BankQuestion q = questionBankService.getQuestion(bankId, questionId, instructorId);

        BankQuestionForm form = new BankQuestionForm();
        form.setContent(q.getContent());
        form.setType(q.getType());
        form.setDifficultyLevel(q.getDifficultyLevel());
        form.setDefaultScore(q.getDefaultScore());
        form.setImageUrl(q.getImageUrl());
        form.setVideoUrl(q.getVideoUrl());
        form.setExplanation(q.getExplanation());
        form.setCorrectAnswer(q.getCorrectAnswer());
        form.setSampleEssayAnswer(q.getSampleEssayAnswer());
        form.setTags(q.getTags());
        if (q.getCategory() != null) {
            form.setCategoryId(q.getCategory().getCategoryId());
        }

        // Đổ danh sách đáp án
        List<BankAnswerOption> options = q.getOptions();
        List<String> texts = new ArrayList<>();
        List<Boolean> corrects = new ArrayList<>();
        int singleIdx = 0;
        for (int i = 0; i < options.size(); i++) {
            BankAnswerOption opt = options.get(i);
            texts.add(opt.getContent());
            corrects.add(opt.isCorrect());
            if (opt.isCorrect()) singleIdx = i;
        }
        while (texts.size() < 4) {
            texts.add("");
            corrects.add(false);
        }
        form.setOptionTexts(texts);
        form.setOptionCorrects(corrects);
        form.setSingleCorrectIndex(singleIdx);

        model.addAttribute("bank", bank);
        model.addAttribute("categories", questionBankService.listCategories(bankId, instructorId));
        model.addAttribute("questionForm", form);
        model.addAttribute("questionId", questionId);
        model.addAttribute("isEdit", true);
        return "quizzes/bank-question-form";
    }

    @PostMapping("/{bankId}/questions/{questionId}/edit")
    public String updateQuestion(@PathVariable Integer bankId,
                                 @PathVariable Integer questionId,
                                 @Valid @ModelAttribute("questionForm") BankQuestionForm form,
                                 BindingResult errors,
                                 @RequestParam(value = "imageFile", required = false) MultipartFile imageFile,
                                 @AuthenticationPrincipal CustomUserDetails user,
                                 Model model,
                                 RedirectAttributes flash) {
        Integer instructorId = user.getUserId();
        if (errors.hasErrors()) {
            QuestionBank bank = questionBankService.getBank(bankId, instructorId);
            model.addAttribute("bank", bank);
            model.addAttribute("categories", questionBankService.listCategories(bankId, instructorId));
            model.addAttribute("questionId", questionId);
            model.addAttribute("isEdit", true);
            return "quizzes/bank-question-form";
        }

        if (imageFile != null && !imageFile.isEmpty()) {
            String imgUrl = fileUploadService.storeFile(imageFile, "question");
            form.setImageUrl(imgUrl);
        }

        questionBankService.updateQuestion(bankId, questionId, instructorId, form);
        flash.addFlashAttribute("success", "Đã cập nhật câu hỏi.");
        return "redirect:/instructor/question-banks/" + bankId;
    }

    @PostMapping("/{bankId}/questions/{questionId}/delete")
    public String deleteQuestion(@PathVariable Integer bankId,
                                 @PathVariable Integer questionId,
                                 @RequestParam(value = "categoryId", required = false) Integer categoryId,
                                 @AuthenticationPrincipal CustomUserDetails user,
                                 RedirectAttributes flash) {
        try {
            questionBankService.deleteQuestion(bankId, questionId, user.getUserId());
            flash.addFlashAttribute("success", "Đã xóa câu hỏi khỏi ngân hàng.");
        } catch (Exception ex) {
            log.error("Lỗi khi xóa câu hỏi id {}: ", questionId, ex);
            flash.addFlashAttribute("error", "Không thể xóa câu hỏi: " + ex.getMessage());
        }
        return "redirect:/instructor/question-banks/" + bankId + (categoryId != null && categoryId > 0 ? "?categoryId=" + categoryId : "");
    }

    // ==========================================
    // 4. IMPORT CÂU HỎI TỪ TỆP (CSV / EXCEL / WORD)
    // ==========================================

    @PostMapping("/{bankId}/import")
    public String importQuestions(@PathVariable Integer bankId,
                                  @RequestParam(value = "categoryId", required = false) Integer categoryId,
                                  @RequestParam(value = "newCategoryName", required = false) String newCategoryName,
                                  @RequestParam("file") MultipartFile file,
                                  @AuthenticationPrincipal CustomUserDetails user,
                                  RedirectAttributes flash) {
        if (file == null || file.isEmpty()) {
            flash.addFlashAttribute("error", "Vui lòng chọn tệp CSV, Excel (.xlsx, .xls) hoặc Word (.docx) để tải lên.");
            return "redirect:/instructor/question-banks/" + bankId;
        }

        Integer redirectCategoryId = categoryId;
        try {
            ImportResultDto result = questionBankService.importQuestionsFromFile(bankId, user.getUserId(), categoryId, newCategoryName, file);
            if (result.getTargetCategoryId() != null) {
                redirectCategoryId = result.getTargetCategoryId();
            }
            if (result.getSuccessCount() > 0) {
                flash.addFlashAttribute("success", "Nhập thành công " + result.getSuccessCount() + " câu hỏi vào ngân hàng!");
            }
            if (result.getErrorCount() > 0) {
                flash.addFlashAttribute("warning", "Có " + result.getErrorCount() + " câu hỏi bị bỏ qua do lỗi: " + String.join("; ", result.getWarnings()));
            } else if (result.getSuccessCount() == 0) {
                flash.addFlashAttribute("error", "Không đọc được câu hỏi nào từ tệp. Lỗi: " + String.join("; ", result.getWarnings()));
            }
        } catch (Exception ex) {
            log.error("Lỗi khi import file: ", ex);
            flash.addFlashAttribute("error", "Lỗi xử lý tệp: " + ex.getMessage());
        }

        return "redirect:/instructor/question-banks/" + bankId + (redirectCategoryId != null && redirectCategoryId > 0 ? "?categoryId=" + redirectCategoryId : "");
    }

    // ==========================================
    // 5. TẠO CÂU HỎI BẰNG AI (RAG) & GIẢNG VIÊN KIỂM DUYỆT CUỐI
    // ==========================================

    /**
     * API lấy danh sách bài học của một khóa học để giảng viên chọn làm nguồn ngữ cảnh RAG.
     */
    @GetMapping("/api/courses/{courseId}/lessons")
    @ResponseBody
    public List<Map<String, Object>> getCourseLessonsApi(@PathVariable Integer courseId,
                                                         @AuthenticationPrincipal CustomUserDetails user) {
        List<Lesson> lessons = lessonRepository.findByCourse_CourseIdOrderByOrderIndexAsc(courseId);
        List<Map<String, Object>> result = new ArrayList<>();
        for (Lesson lesson : lessons) {
            Map<String, Object> item = new HashMap<>();
            item.put("lessonId", lesson.getLessonId());
            item.put("title", lesson.getTitle());
            item.put("hasContent", lesson.getContent() != null && !lesson.getContent().isBlank());
            result.add(item);
        }
        return result;
    }

    /**
     * Bước 1: Thực hiện RAG (truy xuất ngữ cảnh từ bài học/tài liệu) + gọi Model AI qua API Key để sinh câu hỏi nháp,
     * sau đó chuyển sang màn hình Kiểm duyệt dành cho Giảng viên (chưa lưu vào DB).
     */
    @PostMapping("/{bankId}/ai-generate")
    public String generateQuestionsWithAiRag(
            @PathVariable Integer bankId,
            @RequestParam(required = false) Integer sourceCourseId,
            @RequestParam(required = false) List<Integer> lessonIds,
            @RequestParam(value = "documentFile", required = false) MultipartFile documentFile,
            @RequestParam(required = false) String customContext,
            @RequestParam(required = false) String topicPrompt,
            @RequestParam(defaultValue = "MIXED") String questionType,
            @RequestParam(defaultValue = "MIXED") String difficulty,
            @RequestParam(defaultValue = "5") int questionCount,
            @RequestParam(required = false) Integer categoryId,
            @RequestParam(required = false) String newCategoryName,
            @RequestParam(required = false) String apiKey,
            @RequestParam(defaultValue = "gemini-2.5-flash") String aiModel,
            @AuthenticationPrincipal CustomUserDetails user,
            HttpSession session,
            Model model,
            RedirectAttributes flash) {

        Integer instructorId = user.getUserId();
        QuestionBank bank = questionBankService.getBank(bankId, instructorId);

        if (apiKey != null && !apiKey.isBlank()) {
            session.setAttribute("INSTRUCTOR_AI_API_KEY", apiKey.trim());
        }
        if (aiModel != null && !aiModel.isBlank()) {
            session.setAttribute("INSTRUCTOR_AI_MODEL", aiModel.trim());
        }
        String effectiveApiKey = (apiKey != null && !apiKey.isBlank())
                ? apiKey.trim()
                : (String) session.getAttribute("INSTRUCTOR_AI_API_KEY");

        try {
            AiRagGenerationResultDto ragResult = aiQuestionRagService.generateDraftQuestionsWithRag(
                    sourceCourseId,
                    lessonIds,
                    documentFile,
                    customContext,
                    topicPrompt,
                    questionType,
                    difficulty,
                    questionCount,
                    effectiveApiKey,
                    aiModel
            );
            ragResult.setTargetCategoryId(categoryId);
            ragResult.setNewCategoryName(newCategoryName);

            model.addAttribute("bank", bank);
            model.addAttribute("categories", questionBankService.listCategories(bankId, instructorId));
            model.addAttribute("ragResult", ragResult);
            return "quizzes/ai-review";
        } catch (CourseActionException ex) {
            flash.addFlashAttribute("error", ex.getMessage());
            return "redirect:/instructor/question-banks/" + bankId;
        } catch (Exception ex) {
            log.error("Lỗi khi tạo câu hỏi bằng AI RAG: ", ex);
            flash.addFlashAttribute("error", "Lỗi khi gọi AI tạo câu hỏi: " + ex.getMessage());
            return "redirect:/instructor/question-banks/" + bankId;
        }
    }

    /**
     * Bước 2 (Kiểm duyệt cuối của Giảng viên): Nhận danh sách các câu hỏi đã được Giảng viên tick duyệt
     * và chỉnh sửa trên màn hình Kiểm duyệt, lưu chính thức vào Ngân hàng câu hỏi.
     */
    @PostMapping("/{bankId}/ai-approve")
    public String approveAiQuestions(
            @PathVariable Integer bankId,
            @RequestParam(required = false) Integer categoryId,
            @RequestParam(required = false) String newCategoryName,
            @RequestParam(value = "approvedIndices", required = false) List<Integer> approvedIndices,
            @RequestParam(value = "contents", required = false) List<String> contents,
            @RequestParam(value = "types", required = false) List<String> types,
            @RequestParam(value = "difficulties", required = false) List<String> difficulties,
            @RequestParam(value = "scores", required = false) List<String> scores,
            @RequestParam(value = "optionAs", required = false) List<String> optionAs,
            @RequestParam(value = "optionBs", required = false) List<String> optionBs,
            @RequestParam(value = "optionCs", required = false) List<String> optionCs,
            @RequestParam(value = "optionDs", required = false) List<String> optionDs,
            @RequestParam(value = "correctAnswers", required = false) List<String> correctAnswers,
            @RequestParam(value = "explanations", required = false) List<String> explanations,
            @RequestParam(value = "sampleEssayAnswers", required = false) List<String> sampleEssayAnswers,
            @AuthenticationPrincipal CustomUserDetails user,
            RedirectAttributes flash) {

        if (approvedIndices == null || approvedIndices.isEmpty()) {
            flash.addFlashAttribute("warning", "Bạn chưa chọn câu hỏi nào để phê duyệt vào ngân hàng.");
            return "redirect:/instructor/question-banks/" + bankId;
        }

        List<ParsedQuestionDto> approvedList = new ArrayList<>();
        for (Integer idx : approvedIndices) {
            if (idx == null || contents == null || idx < 0 || idx >= contents.size()) {
                continue;
            }
            String content = getAt(contents, idx);
            if (content == null || content.isBlank()) {
                continue;
            }
            String type = getAt(types, idx);
            if (type == null || type.isBlank()) type = "SINGLE_CHOICE";

            String difficulty = getAt(difficulties, idx);
            if (difficulty == null || difficulty.isBlank()) difficulty = "MEDIUM";

            java.math.BigDecimal score = java.math.BigDecimal.valueOf(1.0);
            try {
                String rawScore = getAt(scores, idx);
                if (rawScore != null && !rawScore.isBlank()) {
                    score = new java.math.BigDecimal(rawScore.trim());
                }
            } catch (Exception ignored) {
            }

            String correct = getAt(correctAnswers, idx);
            if (correct == null || correct.isBlank()) correct = "A";
            correct = correct.trim().toUpperCase(java.util.Locale.ROOT);

            List<ParsedOptionDto> options = new ArrayList<>();
            if ("SINGLE_CHOICE".equals(type) || "MULTIPLE_CHOICE".equals(type)) {
                String[] opts = {getAt(optionAs, idx), getAt(optionBs, idx), getAt(optionCs, idx), getAt(optionDs, idx)};
                String[] labels = {"A", "B", "C", "D"};
                for (int i = 0; i < opts.length; i++) {
                    if (opts[i] != null && !opts[i].isBlank()) {
                        boolean isCorr = correct.contains(labels[i]);
                        options.add(new ParsedOptionDto(opts[i].trim(), isCorr, i + 1));
                    }
                }
            }

            approvedList.add(ParsedQuestionDto.builder()
                    .content(content.trim())
                    .type(type)
                    .difficultyLevel(difficulty)
                    .defaultScore(score)
                    .correctAnswer(correct)
                    .explanation(getAt(explanations, idx))
                    .sampleEssayAnswer(getAt(sampleEssayAnswers, idx))
                    .options(options)
                    .build());
        }

        int savedCount = questionBankService.saveApprovedAiQuestions(
                bankId, user.getUserId(), categoryId, newCategoryName, approvedList);

        flash.addFlashAttribute("success",
                "Đã kiểm duyệt và lưu thành công " + savedCount + " câu hỏi từ AI (RAG) vào ngân hàng câu hỏi!");
        return "redirect:/instructor/question-banks/" + bankId;
    }

    private String getAt(List<String> list, int idx) {
        if (list == null || idx < 0 || idx >= list.size()) return null;
        return list.get(idx);
    }

    // ==========================================
    // 6. REST API CHO QUIZ BUILDER (LẤY CÂU HỎI THEO BANK)
    // ==========================================

    @GetMapping("/api/{bankId}/questions")
    @ResponseBody
    public List<Map<String, Object>> getBankQuestionsApi(@PathVariable Integer bankId,
                                                         @RequestParam(required = false) Integer categoryId,
                                                         @AuthenticationPrincipal CustomUserDetails user) {
        var list = questionBankService.listQuestions(bankId, user.getUserId(), categoryId);
        List<Map<String, Object>> result = new ArrayList<>();
        for (BankQuestion q : list) {
            Map<String, Object> map = new HashMap<>();
            map.put("id", q.getBankQuestionId());
            map.put("content", q.getContent());
            map.put("type", q.getType());
            map.put("difficulty", q.getDifficultyLevel());
            map.put("score", q.getDefaultScore());
            map.put("imageUrl", q.getImageUrl());
            map.put("videoUrl", q.getVideoUrl());
            map.put("optionsCount", q.getOptions() != null ? q.getOptions().size() : 0);
            result.add(map);
        }
        return result;
    }

    // ==========================================
    // 6. TẢI FILE MẪU (CSV, EXCEL)
    // ==========================================

    @GetMapping("/sample/csv")
    public ResponseEntity<byte[]> downloadSampleCsv() {
        String csvContent = "Content,OptionA,OptionB,OptionC,OptionD,CorrectAnswer,Explanation,Type,Difficulty,Score\n"
                + "\"HTML là viết tắt của cụm từ nào?\",\"Hyper Text Markup Language\",\"Hyperlinks Text Mark Language\",\"Home Tool Markup Language\",\"Hyperlink Text Makeup Language\",\"A\",\"HTML là ngôn ngữ đánh dấu siêu văn bản.\",\"SINGLE_CHOICE\",\"EASY\",1.0\n"
                + "\"Các phương thức HTTP nào thường dùng?\",\"GET\",\"POST\",\"FETCH\",\"PUT\",\"A,B,D\",\"GET, POST, PUT là các phương thức HTTP chuẩn.\",\"MULTIPLE_CHOICE\",\"MEDIUM\",2.0\n"
                + "\"Java là ngôn ngữ lập trình hướng đối tượng?\",\"Đúng\",\"Sai\",\"\",\"\",\"Đúng\",\"Java là pure/hybrid OOP language.\",\"TRUE_FALSE\",\"EASY\",1.0\n"
                + "\"Trình bày nguyên lý Dependency Inversion trong SOLID.\",\"\",\"\",\"\",\"\",\"SOLID D principle: Module cấp cao không phụ thuộc module cấp thấp.\",\"Học viên cần nêu định nghĩa và ví dụ thực tế.\",\"ESSAY\",\"HARD\",3.0\n";

        byte[] bytes = csvContent.getBytes(StandardCharsets.UTF_8);
        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"edusphere_sample_questions.csv\"")
                .contentType(MediaType.parseMediaType("text/csv; charset=UTF-8"))
                .body(bytes);
    }

    @GetMapping("/sample/word")
    public ResponseEntity<byte[]> downloadSampleWord() {
        try (XWPFDocument doc = new XWPFDocument();
             ByteArrayOutputStream out = new ByteArrayOutputStream()) {

            // Header Title
            XWPFParagraph titlePara = doc.createParagraph();
            titlePara.setAlignment(ParagraphAlignment.CENTER);
            XWPFRun titleRun = titlePara.createRun();
            titleRun.setText("BỘ ĐỀ CÂU HỎI MẪU - EDUSPHERE");
            titleRun.setBold(true);
            titleRun.setFontSize(16);
            titleRun.setColor("1E40AF");
            titleRun.setFontFamily("Arial");

            // Subtitle
            XWPFParagraph subPara = doc.createParagraph();
            subPara.setAlignment(ParagraphAlignment.CENTER);
            XWPFRun subRun = subPara.createRun();
            subRun.setText("(Hỗ trợ trắc nghiệm 1 đáp án, nhiều đáp án, đúng/sai, tự luận và ảnh minh họa)");
            subRun.setItalic(true);
            subRun.setFontSize(11);
            subRun.setColor("6B7280");
            subRun.setFontFamily("Arial");

            doc.createParagraph(); // Spacing

            // Câu 1
            addDocxPara(doc, "Câu 1: Ngôn ngữ lập trình nào sau đây chạy trực tiếp trên máy ảo Java (JVM)?", true, "111827");
            addDocxPara(doc, "A. Java", false, "374151");
            addDocxPara(doc, "B. C++", false, "374151");
            addDocxPara(doc, "C. PHP", false, "374151");
            addDocxPara(doc, "D. Ruby", false, "374151");
            addDocxPara(doc, "Đáp án: A", true, "15803D");
            addDocxPara(doc, "Lời giải: Java biên dịch mã nguồn thành bytecode (.class) và được thực thi trên máy ảo Java Virtual Machine (JVM).", false, "0369A1");
            doc.createParagraph();

            // Câu 2
            addDocxPara(doc, "Câu 2: Các phương thức HTTP nào thường được sử dụng trong việc thiết kế RESTful API?", true, "111827");
            addDocxPara(doc, "A. GET", false, "374151");
            addDocxPara(doc, "B. POST", false, "374151");
            addDocxPara(doc, "C. FETCH", false, "374151");
            addDocxPara(doc, "D. DELETE", false, "374151");
            addDocxPara(doc, "Đáp án: A, B, D", true, "15803D");
            addDocxPara(doc, "Lời giải: GET (lấy dữ liệu), POST (tạo mới) và DELETE (xóa) là các HTTP methods tiêu chuẩn của REST API.", false, "0369A1");
            doc.createParagraph();

            // Câu 3
            addDocxPara(doc, "Câu 3: Giao thức HTTPS sử dụng cơ chế mã hóa SSL/TLS để bảo mật đường truyền mạng?", true, "111827");
            addDocxPara(doc, "A. Đúng", false, "374151");
            addDocxPara(doc, "B. Sai", false, "374151");
            addDocxPara(doc, "Đáp án: A", true, "15803D");
            addDocxPara(doc, "Lời giải: Đúng, HTTPS bảo mật hơn HTTP thông qua lớp chứng chỉ bảo mật SSL/TLS.", false, "0369A1");
            doc.createParagraph();

            // Câu 4
            addDocxPara(doc, "Câu 4: [Tự luận] Trình bày 4 tính chất cơ bản của lập trình hướng đối tượng (OOP). Nêu ví dụ về tính Kế thừa.", true, "111827");
            addDocxPara(doc, "Lời giải: 4 tính chất OOP gồm: Đóng gói (Encapsulation), Kế thừa (Inheritance), Đa hình (Polymorphism), Trừu tượng (Abstraction). Ví dụ: Lớp Dog kế thừa lớp Animal, có thể dùng lại các thuộc tính như eat(), sleep() của Animal.", false, "0369A1");

            doc.write(out);
            byte[] bytes = out.toByteArray();

            return ResponseEntity.ok()
                    .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"Mau_Cau_Hoi_EduSphere.docx\"")
                    .contentType(MediaType.parseMediaType("application/vnd.openxmlformats-officedocument.wordprocessingml.document"))
                    .body(bytes);
        } catch (Exception e) {
            log.error("Lỗi khi tạo file word mẫu: ", e);
            return ResponseEntity.internalServerError().build();
        }
    }

    private void addDocxPara(XWPFDocument doc, String text, boolean bold, String hexColor) {
        XWPFParagraph p = doc.createParagraph();
        XWPFRun r = p.createRun();
        r.setText(text);
        r.setBold(bold);
        r.setFontFamily("Arial");
        r.setFontSize(12);
        if (hexColor != null) {
            r.setColor(hexColor);
        }
    }

    @ExceptionHandler(CourseActionException.class)
    public String handleError(CourseActionException ex, HttpServletResponse response, Model model) {
        response.setStatus(ex.getStatus().value());
        model.addAttribute("errorMessage", ex.getMessage());
        return "courses/action-error";
    }
}

