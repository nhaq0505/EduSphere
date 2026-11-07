package com.edusphere.service.course;

import com.edusphere.dto.quiz.BankQuestionForm;
import com.edusphere.dto.quiz.ImportResultDto;
import com.edusphere.dto.quiz.ParsedQuestionDto;
import com.edusphere.dto.quiz.ParsedQuestionDto.ParsedOptionDto;
import com.edusphere.dto.quiz.QuestionBankForm;
import com.edusphere.entity.account.Users;
import com.edusphere.entity.course.BankAnswerOption;
import com.edusphere.entity.course.BankCategory;
import com.edusphere.entity.course.BankQuestion;
import com.edusphere.entity.course.Course;
import com.edusphere.entity.course.QuestionBank;
import com.edusphere.repository.account.UserRepository;
import com.edusphere.repository.course.BankAnswerOptionRepository;
import com.edusphere.repository.course.BankCategoryRepository;
import com.edusphere.repository.course.BankQuestionRepository;
import com.edusphere.repository.course.CourseRepository;
import com.edusphere.repository.course.QuestionBankRepository;
import com.edusphere.repository.course.QuestionRepository;
import com.edusphere.repository.course.QuizRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;
import java.util.Objects;

@Slf4j
@Service
@RequiredArgsConstructor
public class QuestionBankService {

    private final QuestionBankRepository bankRepository;
    private final BankCategoryRepository categoryRepository;
    private final BankQuestionRepository questionRepository;
    private final BankAnswerOptionRepository optionRepository;
    private final CourseRepository courseRepository;
    private final UserRepository userRepository;
    private final QuestionImportService importService;
    private final QuestionRepository quizQuestionRepository;
    private final QuizRepository quizRepository;

    // ==========================================
    // QUẢN LÝ NGÂN HÀNG CỦA GIẢNG VIÊN (CÔ LẬP THEO INSTRUCTOR)
    // ==========================================

    @Transactional(readOnly = true)
    public List<QuestionBank> listBanksForInstructor(Integer instructorId) {
        List<QuestionBank> list = bankRepository.findByInstructor_UserIdOrderByCreatedAtDesc(instructorId);
        for (QuestionBank b : list) {
            org.hibernate.Hibernate.initialize(b.getQuestions());
            if (b.getCourse() != null) {
                org.hibernate.Hibernate.initialize(b.getCourse());
            }
        }
        return list;
    }

    @Transactional(readOnly = true)
    public QuestionBank getBank(Integer bankId, Integer instructorId) {
        QuestionBank bank = bankRepository.findByBankIdAndInstructor_UserId(bankId, instructorId)
                .orElseThrow(() -> new CourseActionException(HttpStatus.NOT_FOUND, "Không tìm thấy ngân hàng câu hỏi hoặc bạn không có quyền truy cập."));
        org.hibernate.Hibernate.initialize(bank.getQuestions());
        if (bank.getCourse() != null) {
            org.hibernate.Hibernate.initialize(bank.getCourse());
        }
        return bank;
    }

    @Transactional
    public QuestionBank createBank(Integer instructorId, QuestionBankForm form) {
        Users instructor = userRepository.findById(instructorId)
                .orElseThrow(() -> new CourseActionException(HttpStatus.UNAUTHORIZED, "Tài khoản không hợp lệ."));

        QuestionBank bank = new QuestionBank();
        bank.setInstructor(instructor);
        bank.setName(form.getName());
        bank.setDescription(form.getDescription());

        if (form.getCourseId() != null) {
            Course c = courseRepository.findById(form.getCourseId()).orElse(null);
            bank.setCourse(c);
        }

        return bankRepository.save(bank);
    }

    @Transactional
    public void updateBank(Integer bankId, Integer instructorId, QuestionBankForm form) {
        QuestionBank bank = getBank(bankId, instructorId);
        bank.setName(form.getName());
        bank.setDescription(form.getDescription());
        if (form.getCourseId() != null) {
            bank.setCourse(courseRepository.findById(form.getCourseId()).orElse(null));
        } else {
            bank.setCourse(null);
        }
        bankRepository.save(bank);
    }

    @Transactional
    public void deleteBank(Integer bankId, Integer instructorId) {
        QuestionBank bank = getBank(bankId, instructorId);
        // Gỡ liên kết ngân hàng này khỏi Quiz và các câu hỏi trong Quiz
        quizRepository.detachBank(bankId);
        quizQuestionRepository.detachBank(bankId);
        bankRepository.delete(bank);
    }

    // ==========================================
    // QUẢN LÝ CÂU HỎI TRONG BANK
    // ==========================================

    @Transactional(readOnly = true)
    public List<BankQuestion> listQuestions(Integer bankId, Integer instructorId, Integer categoryId) {
        getBank(bankId, instructorId); // Verify ownership
        List<BankQuestion> list;
        if (categoryId != null && categoryId > 0) {
            list = questionRepository.findByBank_BankIdAndCategory_CategoryIdOrderByCreatedAtDesc(bankId, categoryId);
        } else {
            list = questionRepository.findByBank_BankIdOrderByCreatedAtDesc(bankId);
        }
        for (BankQuestion q : list) {
            org.hibernate.Hibernate.initialize(q.getOptions());
            if (q.getCategory() != null) org.hibernate.Hibernate.initialize(q.getCategory());
        }
        return list;
    }

    @Transactional(readOnly = true)
    public BankQuestion getQuestion(Integer bankId, Integer questionId, Integer instructorId) {
        getBank(bankId, instructorId); // Verify ownership
        BankQuestion q = questionRepository.findByBankQuestionIdAndBank_BankId(questionId, bankId)
                .orElseThrow(() -> new CourseActionException(HttpStatus.NOT_FOUND, "Không tìm thấy câu hỏi trong ngân hàng này."));
        org.hibernate.Hibernate.initialize(q.getOptions());
        if (q.getCategory() != null) org.hibernate.Hibernate.initialize(q.getCategory());
        return q;
    }

    @Transactional
    public BankQuestion addQuestion(Integer bankId, Integer instructorId, BankQuestionForm form) {
        QuestionBank bank = getBank(bankId, instructorId);
        Users instructor = bank.getInstructor();

        BankQuestion q = new BankQuestion();
        q.setBank(bank);
        q.setCreatedBy(instructor);
        applyQuestionForm(q, form, bankId);

        BankQuestion saved = questionRepository.save(q);
        saveOptions(saved, form);
        return saved;
    }

    @Transactional
    public void updateQuestion(Integer bankId, Integer questionId, Integer instructorId, BankQuestionForm form) {
        BankQuestion q = getQuestion(bankId, questionId, instructorId);
        applyQuestionForm(q, form, bankId);
        questionRepository.save(q);

        // Cập nhật các đáp án lựa chọn
        optionRepository.deleteByBankQuestion_BankQuestionId(questionId);
        saveOptions(q, form);
    }

    @Transactional
    public void deleteQuestion(Integer bankId, Integer questionId, Integer instructorId) {
        getBank(bankId, instructorId); // Verify ownership
        // 1. Gỡ liên kết câu hỏi này khỏi bất kỳ Quiz nào đã sao chép/tạo từ nó
        quizQuestionRepository.detachBankQuestion(questionId);
        // 2. Xóa các phương án lựa chọn A, B, C, D
        optionRepository.deleteOptionsByQuestionId(questionId);
        // 3. Xóa câu hỏi khỏi ngân hàng
        int rows = questionRepository.deleteByQuestionIdAndBankId(questionId, bankId);
        log.info("Xóa câu hỏi bankId={}, questionId={}, affectedRows={}", bankId, questionId, rows);
    }

    private void applyQuestionForm(BankQuestion q, BankQuestionForm form, Integer bankId) {
        q.setContent(form.getContent());
        q.setImageUrl(form.getImageUrl() != null && !form.getImageUrl().isBlank() ? form.getImageUrl().trim() : null);
        q.setVideoUrl(form.getVideoUrl() != null && !form.getVideoUrl().isBlank() ? form.getVideoUrl().trim() : null);
        q.setType(form.getType() != null ? form.getType() : "SINGLE_CHOICE");
        q.setDifficultyLevel(form.getDifficultyLevel() != null ? form.getDifficultyLevel() : "MEDIUM");
        q.setDefaultScore(form.getDefaultScore() != null ? form.getDefaultScore() : BigDecimal.valueOf(1.0));
        q.setExplanation(form.getExplanation());
        q.setSampleEssayAnswer(form.getSampleEssayAnswer());
        q.setCorrectAnswer(form.getCorrectAnswer());
        q.setTags(form.getTags());

        if (form.getCategoryId() != null && form.getCategoryId() > 0) {
            BankCategory cat = categoryRepository.findByCategoryIdAndBank_BankId(form.getCategoryId(), bankId).orElse(null);
            q.setCategory(cat);
        } else {
            q.setCategory(null);
        }
    }

    private void saveOptions(BankQuestion q, BankQuestionForm form) {
        if ("ESSAY".equals(q.getType()) || "SHORT_ANSWER".equals(q.getType())) {
            return; // Câu tự luận không lưu answer_options
        }

        List<BankAnswerOption> options = new ArrayList<>();
        List<String> texts = form.getOptionTexts();
        List<Boolean> corrects = form.getOptionCorrects();
        Integer singleIdx = form.getSingleCorrectIndex();

        for (int i = 0; i < texts.size(); i++) {
            String text = texts.get(i);
            if (text != null && !text.trim().isEmpty()) {
                BankAnswerOption opt = new BankAnswerOption();
                opt.setBankQuestion(q);
                opt.setContent(text.trim());
                opt.setOrderIndex(i + 1);

                if ("MULTIPLE_CHOICE".equals(q.getType())) {
                    opt.setCorrect(corrects != null && i < corrects.size() && Boolean.TRUE.equals(corrects.get(i)));
                } else {
                    opt.setCorrect(singleIdx != null && singleIdx == i);
                }
                options.add(opt);
            }
        }
        optionRepository.saveAll(options);
    }

    // ==========================================
    // IMPORT CÂU HỎI TỪ FILE (CSV, EXCEL, WORD)
    // ==========================================

    @Transactional
    public ImportResultDto importQuestionsFromFile(Integer bankId, Integer instructorId, Integer categoryId, String newCategoryName, MultipartFile file) {
        QuestionBank bank = getBank(bankId, instructorId);
        Users instructor = bank.getInstructor();

        BankCategory targetCategory = null;
        if (newCategoryName != null && !newCategoryName.trim().isEmpty()) {
            targetCategory = addCategory(bankId, instructorId, newCategoryName.trim(), null);
        } else if (categoryId != null && categoryId > 0) {
            targetCategory = categoryRepository.findByCategoryIdAndBank_BankId(categoryId, bankId).orElse(null);
        }

        ImportResultDto parsedResult = importService.parseFile(file);
        if (targetCategory != null) {
            parsedResult.setTargetCategoryId(targetCategory.getCategoryId());
        }
        List<ParsedQuestionDto> validQuestions = parsedResult.getValidQuestions();

        if (validQuestions.isEmpty()) {
            return parsedResult;
        }

        List<BankQuestion> questionsToSave = new ArrayList<>();
        List<BankAnswerOption> optionsToSave = new ArrayList<>();

        for (ParsedQuestionDto dto : validQuestions) {
            BankQuestion q = new BankQuestion();
            q.setBank(bank);
            q.setCreatedBy(instructor);
            q.setCategory(targetCategory);
            q.setContent(dto.getContent());
            q.setType(dto.getType());
            q.setDifficultyLevel(dto.getDifficultyLevel());
            q.setDefaultScore(dto.getDefaultScore());
            q.setExplanation(dto.getExplanation());
            q.setSampleEssayAnswer(dto.getSampleEssayAnswer());
            q.setCorrectAnswer(dto.getCorrectAnswer());
            q.setImageUrl(dto.getImageUrl());
            q.setVideoUrl(dto.getVideoUrl());

            questionsToSave.add(q);
        }

        // Batch save câu hỏi
        List<BankQuestion> savedQuestions = questionRepository.saveAll(questionsToSave);

        // Lưu các options cho từng câu hỏi
        for (int i = 0; i < savedQuestions.size(); i++) {
            BankQuestion savedQ = savedQuestions.get(i);
            ParsedQuestionDto dto = validQuestions.get(i);

            if (!"ESSAY".equals(savedQ.getType()) && !"SHORT_ANSWER".equals(savedQ.getType())) {
                for (ParsedOptionDto optDto : dto.getOptions()) {
                    BankAnswerOption opt = new BankAnswerOption();
                    opt.setBankQuestion(savedQ);
                    opt.setContent(optDto.getContent());
                    opt.setCorrect(optDto.isCorrect());
                    opt.setOrderIndex(optDto.getOrderIndex());
                    optionsToSave.add(opt);
                }
            }
        }

        if (!optionsToSave.isEmpty()) {
            optionRepository.saveAll(optionsToSave);
        }

        return parsedResult;
    }

    @Transactional
    public ImportResultDto importQuestionsFromFile(Integer bankId, Integer instructorId, MultipartFile file) {
        return importQuestionsFromFile(bankId, instructorId, null, null, file);
    }

    // ==========================================
    // CHUYÊN ĐỀ (CATEGORIES)
    // ==========================================

    @Transactional(readOnly = true)
    public List<BankCategory> listCategories(Integer bankId, Integer instructorId) {
        getBank(bankId, instructorId);
        return categoryRepository.findByBank_BankIdOrderByOrderIndexAsc(bankId);
    }

    @Transactional
    public BankCategory addCategory(Integer bankId, Integer instructorId, String name, String desc) {
        QuestionBank bank = getBank(bankId, instructorId);
        BankCategory cat = new BankCategory();
        cat.setBank(bank);
        cat.setName(name);
        cat.setDescription(desc);
        return categoryRepository.save(cat);
    }

    // ==========================================
    // BỐC CÂU HỎI NGẪU NHIÊN CHO QUIZ
    // ==========================================

    @Transactional(readOnly = true)
    public List<BankQuestion> getRandomQuestions(Integer bankId, Integer instructorId, Integer categoryId, int count) {
        getBank(bankId, instructorId); // Verify ownership
        List<BankQuestion> list;
        if (categoryId != null && categoryId > 0) {
            list = questionRepository.findRandomByBankAndCategory(bankId, categoryId, count);
        } else {
            list = questionRepository.findRandomByBank(bankId, count);
        }
        for (BankQuestion q : list) {
            org.hibernate.Hibernate.initialize(q.getOptions());
        }
        return list;
    }
}

