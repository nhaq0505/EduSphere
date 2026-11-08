package com.edusphere.service.course;

import com.edusphere.dto.quiz.QuestionForm;
import com.edusphere.dto.quiz.QuizAttemptView;
import com.edusphere.dto.quiz.QuizForm;
import com.edusphere.dto.quiz.QuizView;
import com.edusphere.entity.account.Users;
import com.edusphere.entity.course.AnswerOption;
import com.edusphere.entity.course.BankAnswerOption;
import com.edusphere.entity.course.BankQuestion;
import com.edusphere.entity.course.Course;
import com.edusphere.entity.course.Enrollment;
import com.edusphere.entity.course.Lesson;
import com.edusphere.entity.course.LessonCompletion;
import com.edusphere.entity.course.Question;
import com.edusphere.entity.course.QuestionBank;
import com.edusphere.entity.course.Quiz;
import com.edusphere.entity.course.QuizAnswer;
import com.edusphere.entity.course.QuizAnswerOption;
import com.edusphere.entity.course.QuizAnswerOptionPK;
import com.edusphere.entity.course.QuizAttempt;
import com.edusphere.repository.account.UserRepository;
import com.edusphere.repository.course.AnswerOptionRepository;
import com.edusphere.repository.course.BankQuestionRepository;
import com.edusphere.repository.course.CourseRepository;
import com.edusphere.repository.course.EnrollmentRepository;
import com.edusphere.entity.course.LessonWatchProgress;
import com.edusphere.repository.course.LessonRepository;
import com.edusphere.repository.course.QuestionBankRepository;
import com.edusphere.repository.course.LessonCompletionRepository;
import com.edusphere.repository.course.LessonWatchProgressRepository;
import com.edusphere.repository.course.QuestionRepository;
import com.edusphere.repository.course.QuizAnswerOptionRepository;
import com.edusphere.repository.course.QuizAnswerRepository;
import com.edusphere.repository.course.QuizAttemptRepository;
import com.edusphere.repository.course.QuizRepository;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Optional;
import java.util.Set;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class QuizService {

    private static final DateTimeFormatter DT_FMT = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm");

    private final QuizRepository quizzes;
    private final QuestionRepository questions;
    private final AnswerOptionRepository answerOptions;
    private final QuizAttemptRepository attempts;
    private final QuizAnswerRepository answers;
    private final QuizAnswerOptionRepository answerOptionLinks;
    private final CourseRepository courses;
    private final LessonRepository lessons;
    private final EnrollmentRepository enrollments;
    private final UserRepository users;
    private final LearningProgressService learningProgressService;
    private final QuestionBankRepository questionBanks;
    private final BankQuestionRepository bankQuestions;
    private final LessonCompletionRepository lessonCompletions;
    private final LessonWatchProgressRepository watchProgress;

    public QuizService(QuizRepository quizzes, QuestionRepository questions,
                       AnswerOptionRepository answerOptions, QuizAttemptRepository attempts,
                       QuizAnswerRepository answers, QuizAnswerOptionRepository answerOptionLinks,
                       CourseRepository courses, LessonRepository lessons,
                       EnrollmentRepository enrollments, UserRepository users) {
        this(quizzes, questions, answerOptions, attempts, answers, answerOptionLinks,
                courses, lessons, enrollments, users, null, null, null, null, null);
    }

    public QuizService(QuizRepository quizzes, QuestionRepository questions,
                       AnswerOptionRepository answerOptions, QuizAttemptRepository attempts,
                       QuizAnswerRepository answers, QuizAnswerOptionRepository answerOptionLinks,
                       CourseRepository courses, LessonRepository lessons,
                       EnrollmentRepository enrollments, UserRepository users,
                       LearningProgressService learningProgressService) {
        this(quizzes, questions, answerOptions, attempts, answers, answerOptionLinks,
                courses, lessons, enrollments, users, learningProgressService, null, null, null, null);
    }

    @Autowired
    public QuizService(QuizRepository quizzes, QuestionRepository questions,
                       AnswerOptionRepository answerOptions, QuizAttemptRepository attempts,
                       QuizAnswerRepository answers, QuizAnswerOptionRepository answerOptionLinks,
                       CourseRepository courses, LessonRepository lessons,
                       EnrollmentRepository enrollments, UserRepository users,
                       LearningProgressService learningProgressService,
                       QuestionBankRepository questionBanks,
                       BankQuestionRepository bankQuestions,
                       LessonCompletionRepository lessonCompletions,
                       LessonWatchProgressRepository watchProgress) {
        this.quizzes = quizzes;
        this.questions = questions;
        this.answerOptions = answerOptions;
        this.attempts = attempts;
        this.answers = answers;
        this.answerOptionLinks = answerOptionLinks;
        this.courses = courses;
        this.lessons = lessons;
        this.enrollments = enrollments;
        this.users = users;
        this.learningProgressService = learningProgressService;
        this.questionBanks = questionBanks;
        this.bankQuestions = bankQuestions;
        this.lessonCompletions = lessonCompletions;
        this.watchProgress = watchProgress;
    }

    // ===================== INSTRUCTOR OPERATIONS =====================

    @Transactional(readOnly = true)
    public List<QuizView> listForCourse(Integer courseId, Integer instructorId) {
        ownedCourse(courseId, instructorId);
        return quizzes.findByCourse_CourseIdOrderByCreatedAtDesc(courseId).stream()
                .peek(q -> {
                    if (q.getLesson() != null) {
                        q.getLesson().getLessonId();
                        q.getLesson().getTitle();
                    }
                })
                .map(this::toView).toList();
    }

    @Transactional(readOnly = true)
    public List<QuizView> listForInstructor(Integer courseId, Integer instructorId) {
        return listForCourse(courseId, instructorId);
    }

    @Transactional
    public Integer create(Integer courseId, Integer instructorId, QuizForm form) {
        Course course = ownedCourse(courseId, instructorId);
        Quiz quiz = new Quiz();
        quiz.setCourse(course);
        quiz.setCreatedBy(user(instructorId));
        applyForm(quiz, form);
        return quizzes.save(quiz).getQuizId();
    }

    @Transactional(readOnly = true)
    public Quiz getQuizForInstructor(Integer courseId, Integer quizId, Integer instructorId) {
        ownedCourse(courseId, instructorId);
        Quiz q = quizzes.findByQuizIdAndCourse_CourseId(quizId, courseId)
                .orElseThrow(() -> notFound("Không tìm thấy bài quiz."));
        initQuiz(q);
        return q;
    }

    @Transactional(readOnly = true)
    public Quiz getForInstructor(Integer courseId, Integer quizId, Integer instructorId) {
        return getQuizForInstructor(courseId, quizId, instructorId);
    }

    @Transactional(readOnly = true)
    public List<Question> getQuestionsForInstructor(Integer courseId, Integer quizId, Integer instructorId) {
        getQuizForInstructor(courseId, quizId, instructorId);
        return questions.findByQuiz_QuizIdOrderByOrderIndexAsc(quizId);
    }

    /** Lấy quiz + questions kèm options — dùng cho trang quiz builder */
    @Transactional(readOnly = true)
    public Quiz getQuizWithQuestions(Integer courseId, Integer quizId, Integer instructorId) {
        Quiz quiz = getQuizForInstructor(courseId, quizId, instructorId);
        // Eagerly initialize options for each question
        List<Question> qList = questions.findByQuiz_QuizIdOrderByOrderIndexAsc(quizId);
        qList.forEach(q -> org.hibernate.Hibernate.initialize(q.getOptions()));
        return quiz;
    }

    /** Lấy danh sách câu hỏi kèm options cho builder */
    @Transactional(readOnly = true)
    public List<Question> getQuestionsWithOptions(Integer courseId, Integer quizId, Integer instructorId) {
        getQuizForInstructor(courseId, quizId, instructorId);
        List<Question> qList = questions.findByQuiz_QuizIdOrderByOrderIndexAsc(quizId);
        qList.forEach(q -> org.hibernate.Hibernate.initialize(q.getOptions()));
        return qList;
    }

    @Transactional
    public void addQuestion(Integer courseId, Integer quizId, Integer instructorId, QuestionForm form) {
        Quiz quiz = getQuizForInstructor(courseId, quizId, instructorId);
        if (form.getScore() == null || form.getScore().compareTo(BigDecimal.ZERO) <= 0) {
            throw new CourseActionException(HttpStatus.BAD_REQUEST, "Điểm câu hỏi phải lớn hơn 0.");
        }
        long nextIndex = questions.countByQuiz_QuizId(quizId) + 1;

        Question q = new Question();
        q.setQuiz(quiz);
        q.setContent(form.getContent().trim());
        q.setType(form.getType());
        q.setScore(form.getScore());
        q.setOrderIndex((int) nextIndex);
        q.setCorrectAnswer(form.getCorrectAnswer());
        q.setExplanation(form.getExplanation());
        q.setImageUrl(form.getImageUrl() != null && !form.getImageUrl().isBlank() ? form.getImageUrl().trim() : null);
        q.setVideoUrl(form.getVideoUrl() != null && !form.getVideoUrl().isBlank() ? form.getVideoUrl().trim() : null);
        q.setSampleEssayAnswer(form.getSampleEssayAnswer());
        q = questions.save(q);

        // Save options for choice-type questions
        if (Set.of("SINGLE_CHOICE", "MULTIPLE_CHOICE").contains(form.getType())) {
            List<String> contents = form.getOptionContents();
            List<Boolean> corrects = form.getOptionCorrects();
            for (int i = 0; i < contents.size(); i++) {
                String c = contents.get(i);
                if (c == null || c.isBlank()) continue;
                AnswerOption opt = new AnswerOption();
                opt.setQuestion(q);
                opt.setContent(c.trim());
                opt.setCorrect(corrects != null && i < corrects.size() && Boolean.TRUE.equals(corrects.get(i)));
                opt.setOrderIndex(i + 1);
                answerOptions.save(opt);
            }
        }
    }

    @Transactional
    public void updateQuiz(Integer courseId, Integer quizId, Integer instructorId, QuizForm form) {
        Quiz quiz = getQuizForInstructor(courseId, quizId, instructorId);
        applyForm(quiz, form);
    }

    @Transactional
    public void updateQuestion(Integer courseId, Integer quizId, Integer questionId,
                               Integer instructorId, QuestionForm form) {
        getQuizForInstructor(courseId, quizId, instructorId);
        Question q = questions.findById(questionId)
                .orElseThrow(() -> notFound("Không tìm thấy câu hỏi."));
        if (!q.getQuiz().getQuizId().equals(quizId))
            throw notFound("Câu hỏi không thuộc quiz này.");

        if (form.getScore() == null || form.getScore().compareTo(BigDecimal.ZERO) <= 0) {
            throw new CourseActionException(HttpStatus.BAD_REQUEST, "Điểm câu hỏi phải lớn hơn 0.");
        }

        q.setContent(form.getContent().trim());
        q.setType(form.getType());
        q.setScore(form.getScore());
        q.setCorrectAnswer(form.getCorrectAnswer());
        q.setExplanation(form.getExplanation());
        q.setImageUrl(form.getImageUrl() != null && !form.getImageUrl().isBlank() ? form.getImageUrl().trim() : null);
        q.setVideoUrl(form.getVideoUrl() != null && !form.getVideoUrl().isBlank() ? form.getVideoUrl().trim() : null);
        q.setSampleEssayAnswer(form.getSampleEssayAnswer());

        // In-place update of options preserving student quiz_answers history
        if (Set.of("SINGLE_CHOICE", "MULTIPLE_CHOICE").contains(form.getType())) {
            List<String> contents = form.getOptionContents();
            List<Boolean> corrects = form.getOptionCorrects();
            List<String> validContents = new java.util.ArrayList<>();
            List<Boolean> validCorrects = new java.util.ArrayList<>();
            if (contents != null) {
                for (int i = 0; i < contents.size(); i++) {
                    String c = contents.get(i);
                    if (c != null && !c.isBlank()) {
                        validContents.add(c.trim());
                        validCorrects.add(corrects != null && i < corrects.size() && Boolean.TRUE.equals(corrects.get(i)));
                    }
                }
            }

            List<AnswerOption> existingOpts = answerOptions.findByQuestion_QuestionIdOrderByOrderIndexAsc(questionId);
            int existingCount = existingOpts.size();
            int newCount = validContents.size();

            // 1. Update existing options in-place
            for (int i = 0; i < Math.min(existingCount, newCount); i++) {
                AnswerOption opt = existingOpts.get(i);
                opt.setContent(validContents.get(i));
                opt.setCorrect(validCorrects.get(i));
                opt.setOrderIndex(i + 1);
                answerOptions.save(opt);
            }

            // 2. Add extra new options if any
            if (newCount > existingCount) {
                for (int i = existingCount; i < newCount; i++) {
                    AnswerOption opt = new AnswerOption();
                    opt.setQuestion(q);
                    opt.setContent(validContents.get(i));
                    opt.setCorrect(validCorrects.get(i));
                    opt.setOrderIndex(i + 1);
                    answerOptions.save(opt);
                }
            }

            // 3. Remove surplus options if fewer options now (only remove links for removed options)
            if (existingCount > newCount) {
                List<AnswerOption> toRemove = existingOpts.subList(newCount, existingCount);
                List<Integer> removeIds = toRemove.stream().map(AnswerOption::getOptionId).toList();
                if (!removeIds.isEmpty()) {
                    answerOptionLinks.deleteByOption_OptionIdIn(removeIds);
                    answerOptionLinks.flush();
                    answerOptions.deleteAll(toRemove);
                    answerOptions.flush();
                }
            }
        } else {
            // Non-choice question: clean up options only if options exist
            List<AnswerOption> existingOpts = answerOptions.findByQuestion_QuestionIdOrderByOrderIndexAsc(questionId);
            if (!existingOpts.isEmpty()) {
                List<Integer> removeIds = existingOpts.stream().map(AnswerOption::getOptionId).toList();
                answerOptionLinks.deleteByOption_OptionIdIn(removeIds);
                answerOptionLinks.flush();
                answerOptions.deleteAll(existingOpts);
                answerOptions.flush();
            }
        }
        questions.save(q);
    }

    /** Xóa toàn bộ câu hỏi trong quiz (dùng khi sinh lại đề từ đầu) */
    private void clearQuizQuestions(Integer quizId) {
        List<Question> existing = questions.findByQuiz_QuizIdOrderByOrderIndexAsc(quizId);
        for (Question q : existing) {
            List<Integer> optionIds = q.getOptions().stream()
                    .map(AnswerOption::getOptionId)
                    .filter(java.util.Objects::nonNull)
                    .toList();
            if (!optionIds.isEmpty()) {
                answerOptionLinks.deleteByOption_OptionIdIn(optionIds);
            }
            if (!q.getOptions().isEmpty()) {
                answerOptions.deleteAll(q.getOptions());
                q.getOptions().clear();
            }
            questions.delete(q);
        }
        answerOptions.flush();
        questions.flush();
    }

    /**
     * Tự động bốc ngẫu nhiên N câu hỏi từ ngân hàng vào bài quiz.
     */
    @Transactional
    public int autoGenerateFromBank(Integer courseId, Integer quizId, Integer instructorId,
                                    Integer bankId, Integer categoryId, int count,
                                    BigDecimal defaultScore, boolean replaceExisting) {
        Quiz quiz = getQuizForInstructor(courseId, quizId, instructorId);
        QuestionBank bank = questionBanks.findByBankIdAndInstructor_UserId(bankId, instructorId)
                .orElseThrow(() -> notFound("Không tìm thấy ngân hàng câu hỏi."));

        if (replaceExisting) {
            long attemptCount = attempts.countByQuiz_QuizId(quizId);
            if (attemptCount > 0) {
                throw conflict("Quiz đã có học viên làm bài, không thể xóa và sinh lại toàn bộ câu hỏi.");
            }
            clearQuizQuestions(quizId);
        }

        List<BankQuestion> sampled;
        if (categoryId != null && categoryId > 0) {
            sampled = bankQuestions.findRandomByBankAndCategory(bankId, categoryId, count);
        } else {
            sampled = bankQuestions.findRandomByBank(bankId, count);
        }

        if (sampled.isEmpty()) {
            throw conflict("Ngân hàng câu hỏi không có câu hỏi nào để bốc ngẫu nhiên.");
        }

        int currentCount = (int) questions.countByQuiz_QuizId(quizId);
        for (BankQuestion bq : sampled) {
            currentCount++;
            Question q = new Question();
            q.setQuiz(quiz);
            q.setBankQuestion(bq);
            q.setContent(bq.getContent());
            q.setType(bq.getType());
            q.setScore(bq.getDefaultScore() != null ? bq.getDefaultScore() : (defaultScore != null ? defaultScore : BigDecimal.ONE));
            q.setOrderIndex(currentCount);
            q.setCorrectAnswer(bq.getCorrectAnswer());
            q.setExplanation(bq.getExplanation());
            q.setImageUrl(bq.getImageUrl());
            q.setVideoUrl(bq.getVideoUrl());
            q.setSampleEssayAnswer(bq.getSampleEssayAnswer());
            Question savedQ = questions.save(q);

            if (Set.of("SINGLE_CHOICE", "MULTIPLE_CHOICE").contains(bq.getType())) {
                List<BankAnswerOption> bOptions = bq.getOptions();
                if (bOptions != null && !bOptions.isEmpty()) {
                    for (BankAnswerOption bo : bOptions) {
                        AnswerOption opt = new AnswerOption();
                        opt.setQuestion(savedQ);
                        opt.setContent(bo.getContent());
                        opt.setCorrect(bo.isCorrect());
                        opt.setOrderIndex(bo.getOrderIndex());
                        answerOptions.save(opt);
                    }
                }
            }
        }

        quiz.setBank(bank);
        quizzes.save(quiz);
        return sampled.size();
    }

    /**
     * Chọn danh sách câu hỏi cụ thể từ ngân hàng để thêm vào bài quiz.
     */
    @Transactional
    public int importQuestionsFromBank(Integer courseId, Integer quizId, Integer instructorId,
                                       Integer bankId, List<Integer> bankQuestionIds) {
        Quiz quiz = getQuizForInstructor(courseId, quizId, instructorId);
        QuestionBank bank = questionBanks.findByBankIdAndInstructor_UserId(bankId, instructorId)
                .orElseThrow(() -> notFound("Không tìm thấy ngân hàng câu hỏi."));

        if (bankQuestionIds == null || bankQuestionIds.isEmpty()) return 0;

        int currentCount = (int) questions.countByQuiz_QuizId(quizId);
        int added = 0;
        for (Integer bqId : bankQuestionIds) {
            BankQuestion bq = bankQuestions.findByBankQuestionIdAndBank_BankId(bqId, bankId).orElse(null);
            if (bq == null) continue;

            currentCount++;
            added++;
            Question q = new Question();
            q.setQuiz(quiz);
            q.setBankQuestion(bq);
            q.setContent(bq.getContent());
            q.setType(bq.getType());
            q.setScore(bq.getDefaultScore() != null ? bq.getDefaultScore() : BigDecimal.ONE);
            q.setOrderIndex(currentCount);
            q.setCorrectAnswer(bq.getCorrectAnswer());
            q.setExplanation(bq.getExplanation());
            q.setImageUrl(bq.getImageUrl());
            q.setVideoUrl(bq.getVideoUrl());
            q.setSampleEssayAnswer(bq.getSampleEssayAnswer());
            Question savedQ = questions.save(q);

            if (Set.of("SINGLE_CHOICE", "MULTIPLE_CHOICE").contains(bq.getType())) {
                List<BankAnswerOption> bOptions = bq.getOptions();
                if (bOptions != null && !bOptions.isEmpty()) {
                    for (BankAnswerOption bo : bOptions) {
                        AnswerOption opt = new AnswerOption();
                        opt.setQuestion(savedQ);
                        opt.setContent(bo.getContent());
                        opt.setCorrect(bo.isCorrect());
                        opt.setOrderIndex(bo.getOrderIndex());
                        answerOptions.save(opt);
                    }
                }
            }
        }
        quiz.setBank(bank);
        quizzes.save(quiz);
        return added;
    }

    @Transactional
    public void deleteQuestion(Integer courseId, Integer quizId, Integer questionId, Integer instructorId) {
        getQuizForInstructor(courseId, quizId, instructorId);
        Question q = questions.findById(questionId)
                .orElseThrow(() -> notFound("Không tìm thấy câu hỏi."));
        if (!q.getQuiz().getQuizId().equals(quizId))
            throw notFound("Câu hỏi không thuộc quiz này.");

        List<Integer> optionIds = q.getOptions().stream()
                .map(AnswerOption::getOptionId)
                .filter(java.util.Objects::nonNull)
                .toList();
        if (!optionIds.isEmpty()) {
            answerOptionLinks.deleteByOption_OptionIdIn(optionIds);
        }
        List<QuizAnswer> qAnswers = answers.findByQuestion_QuestionId(questionId);
        if (qAnswers != null && !qAnswers.isEmpty()) {
            for (QuizAnswer qa : qAnswers) {
                if (qa.getSelectedOptions() != null && !qa.getSelectedOptions().isEmpty()) {
                    answerOptionLinks.deleteAll(qa.getSelectedOptions());
                    qa.getSelectedOptions().clear();
                }
            }
            answerOptionLinks.flush();
            answers.deleteByQuestion_QuestionId(questionId);
            answers.flush();
        } else if (!optionIds.isEmpty()) {
            answerOptionLinks.flush();
        }
        if (!q.getOptions().isEmpty()) {
            answerOptions.deleteAll(q.getOptions());
            q.getOptions().clear();
            answerOptions.flush();
        }
        questions.delete(q);
        questions.flush();

        // Re-index remaining questions with 2-pass buffering to prevent UQ_questions_order clash
        List<Question> remaining = questions.findByQuiz_QuizIdOrderByOrderIndexAsc(quizId);
        for (int i = 0; i < remaining.size(); i++) {
            remaining.get(i).setOrderIndex(10000 + (i + 1));
        }
        questions.saveAllAndFlush(remaining);
        for (int i = 0; i < remaining.size(); i++) {
            remaining.get(i).setOrderIndex(i + 1);
        }
        questions.saveAllAndFlush(remaining);
    }

    @Transactional
    public void moveQuestion(Integer courseId, Integer quizId, Integer questionId,
                             String direction, Integer instructorId) {
        getQuizForInstructor(courseId, quizId, instructorId);
        List<Question> qList = questions.findByQuiz_QuizIdOrderByOrderIndexAsc(quizId);
        int idx = -1;
        for (int i = 0; i < qList.size(); i++) {
            if (qList.get(i).getQuestionId().equals(questionId)) { idx = i; break; }
        }
        if (idx < 0) throw notFound("Không tìm thấy câu hỏi.");
        int swapIdx = "up".equals(direction) ? idx - 1 : idx + 1;
        if (swapIdx < 0 || swapIdx >= qList.size()) return;
        Question a = qList.get(idx), b = qList.get(swapIdx);
        int orderA = a.getOrderIndex();
        int orderB = b.getOrderIndex();

        // Step 1: Move a to temporary buffer to avoid UQ_questions_order violation
        a.setOrderIndex(10000 + orderA);
        questions.saveAndFlush(a);

        // Step 2: Move b to orderA
        b.setOrderIndex(orderA);
        questions.saveAndFlush(b);

        // Step 3: Move a to orderB
        a.setOrderIndex(orderB);
        questions.saveAndFlush(a);
    }

    @Transactional
    public void publish(Integer courseId, Integer quizId, Integer instructorId) {
        Quiz quiz = getQuizForInstructor(courseId, quizId, instructorId);
        if (!"DRAFT".equals(quiz.getStatus()))
            throw conflict("Chỉ có thể công bố quiz ở trạng thái Bản nháp.");
        if (questions.countByQuiz_QuizId(quizId) == 0)
            throw conflict("Quiz phải có ít nhất một câu hỏi trước khi công bố.");
        quiz.setStatus("PUBLISHED");
    }

    /** Khôi phục quiz từ ARCHIVED về PUBLISHED */
    @Transactional
    public void restore(Integer courseId, Integer quizId, Integer instructorId) {
        Quiz quiz = getQuizForInstructor(courseId, quizId, instructorId);
        if (!"ARCHIVED".equals(quiz.getStatus()))
            throw conflict("Chỉ có thể khôi phục quiz đã lưu trữ.");
        quiz.setStatus("PUBLISHED");
    }

    @Transactional
    public void archive(Integer courseId, Integer quizId, Integer instructorId) {
        Quiz quiz = getQuizForInstructor(courseId, quizId, instructorId);
        if (!"PUBLISHED".equals(quiz.getStatus()))
            throw conflict("Chỉ có thể lưu trữ quiz đã công bố.");
        quiz.setStatus("ARCHIVED");
    }

    @Transactional(readOnly = true)
    public List<QuizAttemptView> listAttempts(Integer courseId, Integer quizId, Integer instructorId) {
        getQuizForInstructor(courseId, quizId, instructorId);
        return attempts.findByQuizIdOrderByStudentAndAttempt(quizId).stream()
                .peek(this::initAttempt)
                .map(this::toAttemptView).toList();
    }

    @Transactional(readOnly = true)
    public QuizAttempt getAttemptForInstructor(Integer courseId, Integer quizId, Integer attemptId,
                                               Integer instructorId) {
        getQuizForInstructor(courseId, quizId, instructorId);
        QuizAttempt attempt = attempts.findById(attemptId)
                .orElseThrow(() -> notFound("Không tìm thấy lần làm quiz."));
        if (attempt.getQuiz() == null || !attempt.getQuiz().getQuizId().equals(quizId)
                || attempt.getCourse() == null || !attempt.getCourse().getCourseId().equals(courseId)) {
            throw notFound("Không tìm thấy lần làm quiz.");
        }
        initAttempt(attempt);
        return attempt;
    }

    @Transactional(readOnly = true)
    public List<QuizAnswer> getAnswersForAttempt(Integer attemptId) {
        List<QuizAnswer> list = answers.findByAttempt_AttemptIdOrderByQuestion_OrderIndexAsc(attemptId);
        list.forEach(a -> {
            org.hibernate.Hibernate.initialize(a.getQuestion());
            if (a.getQuestion() != null) org.hibernate.Hibernate.initialize(a.getQuestion().getOptions());
            org.hibernate.Hibernate.initialize(a.getSelectedOptions());
        });
        return list;
    }

    @Transactional
    public void gradeEssay(Integer courseId, Integer quizId, Integer attemptId, Integer answerId,
                           Integer instructorId, BigDecimal score) {
        QuizAttempt attempt = getAttemptForInstructor(courseId, quizId, attemptId, instructorId);
        QuizAnswer answer = answers.findById(answerId)
                .orElseThrow(() -> notFound("Không tìm thấy câu trả lời."));
        if (!answer.getAttempt().getAttemptId().equals(attemptId))
            throw notFound("Câu trả lời không thuộc lần làm này.");
        if (score.compareTo(answer.getMaxScore()) > 0)
            throw conflict("Điểm chấm không được vượt quá điểm tối đa (" + answer.getMaxScore() + ").");

        answer.setAwardedScore(score);
        answer.setGradedBy(user(instructorId));
        answer.setGradedAt(LocalDateTime.now());

        // Recalculate attempt total score
        recalculateAttemptScore(attempt);
    }

    @Transactional
    public void publishAttemptResult(Integer courseId, Integer quizId, Integer attemptId, Integer instructorId) {
        QuizAttempt attempt = getAttemptForInstructor(courseId, quizId, attemptId, instructorId);
        if ("PUBLISHED".equals(attempt.getResultStatus())) {
            return;
        }
        if (!"SCORED".equals(attempt.getStatus()))
            throw conflict("Chỉ công bố được khi bài làm đã chấm xong toàn bộ câu hỏi.");
        attempt.setResultStatus("PUBLISHED");
        attempt.setPublishedBy(user(instructorId));
        LocalDateTime pAt = LocalDateTime.now();
        if (attempt.getSubmittedAt() != null && pAt.isBefore(attempt.getSubmittedAt())) {
            pAt = attempt.getSubmittedAt();
        }
        attempt.setPublishedAt(pAt);
        attempts.save(attempt);
    }

    // ===================== STUDENT OPERATIONS =====================

    @Transactional(readOnly = true)
    public List<QuizView> listPublished(Integer courseId, Integer studentId) {
        verifyEnrolled(courseId, studentId);
        return quizzes.findByCourse_CourseIdAndStatus(courseId, "PUBLISHED").stream()
                .map(this::toView).toList();
    }

    @Transactional(readOnly = true)
    public Quiz getQuizForStudent(Integer courseId, Integer quizId, Integer studentId) {
        verifyEnrolled(courseId, studentId);
        Quiz quiz = quizzes.findByQuizIdAndCourse_CourseId(quizId, courseId)
                .orElseThrow(() -> notFound("Không tìm thấy bài quiz."));
        if (!"PUBLISHED".equals(quiz.getStatus()))
            throw notFound("Bài quiz chưa được công bố.");
        initQuiz(quiz);
        return quiz;
    }

    @Transactional
    public Integer startAttempt(Integer courseId, Integer quizId, Integer studentId) {
        Quiz quiz = getQuizForStudent(courseId, quizId, studentId);

        // ── Backend gate: kiểm tra điều kiện xem video tối thiểu 80% để mở khóa Quiz ──
        Lesson quizLesson = quiz.getLesson();
        Course course = quiz.getCourse();
        boolean isOwner = course != null && course.getInstructor() != null && Objects.equals(course.getInstructor().getUserId(), studentId);
        Users u = users.findById(studentId).orElse(null);
        boolean isAdmin = u != null && u.getUserRolesCollection() != null
                && u.getUserRolesCollection().stream()
                .anyMatch(ur -> ur.getRoles() != null && "ADMINISTRATOR".equalsIgnoreCase(ur.getRoles().getRoleName()));

        if (!isOwner && !isAdmin && quizLesson != null && isVideoLesson(quizLesson)) {
            int minPct = (quizLesson.getMinWatchPercent() != null && quizLesson.getMinWatchPercent() > 0)
                    ? quizLesson.getMinWatchPercent()
                    : 80;
            boolean isUnlocked = false;
            if (watchProgress != null) {
                isUnlocked = watchProgress
                        .findByStudent_UserIdAndLesson_LessonId(studentId, quizLesson.getLessonId())
                        .map(wp -> Boolean.TRUE.equals(wp.getQuizUnlocked()) || (wp.getWatchPercent() != null && wp.getWatchPercent() >= minPct))
                        .orElse(false);
            }
            if (!isUnlocked) {
                throw conflict("Bạn cần xem ít nhất " + minPct + "% video bài học để mở khóa bài kiểm tra này.");
            }
        }

        // Check existing IN_PROGRESS attempt
        attempts.findFirstByQuiz_QuizIdAndStudent_UserIdAndStatus(quizId, studentId, "IN_PROGRESS")
                .ifPresent(a -> {
                    throw conflict("Bạn đang có lần làm quiz chưa hoàn thành. Vui lòng tiếp tục.");
                });

        int attemptCount = attempts.countByQuiz_QuizIdAndStudent_UserId(quizId, studentId);
        if (attemptCount >= quiz.getMaxAttempts())
            throw conflict("Bạn đã đạt số lần làm tối đa (" + quiz.getMaxAttempts() + ").");

        // Check timing
        LocalDateTime now = LocalDateTime.now();
        if (quiz.getStartTime() != null && now.isBefore(quiz.getStartTime()))
            throw conflict("Quiz chưa đến giờ bắt đầu.");
        if (quiz.getEndTime() != null && now.isAfter(quiz.getEndTime()))
            throw conflict("Quiz đã kết thúc.");

        // Calculate max score
        List<Question> qList = questions.findByQuiz_QuizIdOrderByOrderIndexAsc(quizId);
        BigDecimal maxScore = qList.stream()
                .map(Question::getScore)
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        QuizAttempt attempt = new QuizAttempt();
        attempt.setQuiz(quiz);
        attempt.setStudent(user(studentId));
        attempt.setCourse(quiz.getCourse());
        attempt.setAttemptNumber(attemptCount + 1);
        attempt.setStartedAt(now);
        attempt.setMaxScore(maxScore);
        attempt.setStatus("IN_PROGRESS");
        attempt.setResultStatus("UNPUBLISHED");
        if (quiz.getTimeLimitMinutes() != null) {
            attempt.setDeadlineAt(now.plusMinutes(quiz.getTimeLimitMinutes()));
        }
        attempt = attempts.save(attempt);
        return attempt.getAttemptId();
    }

    @Transactional(readOnly = true)
    public QuizAttempt getAttemptForStudent(Integer courseId, Integer quizId, Integer attemptId, Integer studentId) {
        verifyEnrolled(courseId, studentId);
        QuizAttempt attempt = attempts.findByAttemptIdAndStudent_UserId(attemptId, studentId)
                .orElseThrow(() -> notFound("Không tìm thấy lần làm quiz."));
        if (attempt.getQuiz() == null || !attempt.getQuiz().getQuizId().equals(quizId)
                || attempt.getCourse() == null || !attempt.getCourse().getCourseId().equals(courseId)) {
            throw notFound("Không tìm thấy lần làm quiz trong bài kiểm tra hoặc khóa học này.");
        }
        initAttempt(attempt);
        return attempt;
    }

    @Transactional(readOnly = true)
    public QuizAttempt getAttemptForStudent(Integer attemptId, Integer studentId) {
        QuizAttempt attempt = attempts.findByAttemptIdAndStudent_UserId(attemptId, studentId)
                .orElseThrow(() -> notFound("Không tìm thấy lần làm quiz."));
        if (attempt.getCourse() != null) {
            verifyEnrolled(attempt.getCourse().getCourseId(), studentId);
        }
        initAttempt(attempt);
        return attempt;
    }

    @Transactional(readOnly = true)
    public List<Question> getQuestionsForAttempt(Integer courseId, Integer quizId, Integer studentId) {
        Quiz quiz = getQuizForStudent(courseId, quizId, studentId);
        Integer attemptId = attempts.findFirstByQuiz_QuizIdAndStudent_UserIdAndStatus(quizId, studentId, "IN_PROGRESS")
                .map(QuizAttempt::getAttemptId)
                .orElse(0);
        return shuffleQuestionsAndOptions(quiz, attemptId);
    }

    @Transactional(readOnly = true)
    public List<Question> getQuestionsForAttempt(Integer attemptId, Integer studentId) {
        QuizAttempt attempt = getAttemptForStudent(attemptId, studentId);
        Quiz quiz = attempt.getQuiz();
        return shuffleQuestionsAndOptions(quiz, attemptId);
    }

    private List<Question> shuffleQuestionsAndOptions(Quiz quiz, Integer attemptId) {
        long seed = attemptId != null ? attemptId.longValue() : 0L;
        List<Question> qs = new java.util.ArrayList<>(questions.findByQuiz_QuizIdOrderByOrderIndexAsc(quiz.getQuizId()));
        if (Boolean.TRUE.equals(quiz.isShuffleQuestions())) {
            java.util.Collections.shuffle(qs, new java.util.Random(seed));
        }
        for (Question q : qs) {
            q.getOptions().size();
            if (Boolean.TRUE.equals(quiz.isShuffleOptions()) && q.getOptions().size() > 1) {
                long optSeed = seed * 31L + (q.getQuestionId() != null ? q.getQuestionId() : 0);
                java.util.Collections.shuffle(q.getOptions(), new java.util.Random(optSeed));
            }
        }
        return qs;
    }

    @Transactional
    public void submitAttempt(Integer courseId, Integer quizId, Integer attemptId, Integer studentId,
                              Map<Integer, List<String>> questionAnswers) {
        QuizAttempt attempt = getAttemptForStudent(courseId, quizId, attemptId, studentId);
        doSubmitAttempt(attempt, questionAnswers);
    }

    @Transactional
    public void submitAttempt(Integer attemptId, Integer studentId,
                              Map<Integer, List<String>> questionAnswers) {
        QuizAttempt attempt = getAttemptForStudent(attemptId, studentId);
        doSubmitAttempt(attempt, questionAnswers);
    }

    private void doSubmitAttempt(QuizAttempt attempt, Map<Integer, List<String>> questionAnswers) {
        if (!"IN_PROGRESS".equals(attempt.getStatus()))
            throw conflict("Lần làm quiz này không ở trạng thái đang làm.");

        LocalDateTime now = LocalDateTime.now();
        // Do not throw rollback exception if overdue/timeout; gracefully finish and score the attempt

        List<Question> qList = questions.findByQuiz_QuizIdOrderByOrderIndexAsc(attempt.getQuiz().getQuizId());

        BigDecimal totalScore = BigDecimal.ZERO;

        for (Question q : qList) {
            List<String> studentAnswers = questionAnswers.getOrDefault(q.getQuestionId(), List.of());

            QuizAnswer qa = new QuizAnswer();
            qa.setAttempt(attempt);
            qa.setQuiz(attempt.getQuiz());
            qa.setQuestion(q);
            qa.setQuestionContentSnapshot(q.getContent());
            qa.setQuestionTypeSnapshot(q.getType());
            qa.setMaxScore(q.getScore());

            switch (q.getType()) {
                case "SINGLE_CHOICE" -> {
                    String selected = studentAnswers.isEmpty() ? null : studentAnswers.get(0);
                    qa.setAnswerText(selected);
                    // Auto-grade: find correct option
                    List<AnswerOption> opts = answerOptions.findByQuestion_QuestionIdOrderByOrderIndexAsc(q.getQuestionId());
                    AnswerOption correct = opts.stream().filter(AnswerOption::isCorrect).findFirst().orElse(null);
                    if (selected != null && correct != null && selected.equals(String.valueOf(correct.getOptionId()))) {
                        qa.setAwardedScore(q.getScore());
                        totalScore = totalScore.add(q.getScore());
                    } else {
                        qa.setAwardedScore(BigDecimal.ZERO);
                    }
                    qa = answers.save(qa);
                    // Save selected options
                    if (selected != null) {
                        saveSelectedOption(qa, q, selected, opts);
                    }
                }
                case "MULTIPLE_CHOICE" -> {
                    List<AnswerOption> opts = answerOptions.findByQuestion_QuestionIdOrderByOrderIndexAsc(q.getQuestionId());
                    Set<Integer> correctIds = opts.stream().filter(AnswerOption::isCorrect)
                            .map(AnswerOption::getOptionId).collect(Collectors.toSet());
                    Set<Integer> selectedIds = studentAnswers.stream()
                            .map(s -> { try { return Integer.parseInt(s); } catch (Exception e) { return -1; } })
                            .collect(Collectors.toSet());
                    boolean correct2 = selectedIds.equals(correctIds);
                    qa.setAnswerText(String.join(",", studentAnswers));
                    qa.setAwardedScore(correct2 ? q.getScore() : BigDecimal.ZERO);
                    if (correct2) totalScore = totalScore.add(q.getScore());
                    qa = answers.save(qa);
                    // Save selected options
                    for (String sid : studentAnswers) {
                        saveSelectedOption(qa, q, sid, opts);
                    }
                }
                case "TRUE_FALSE" -> {
                    String ans = studentAnswers.isEmpty() ? null : studentAnswers.get(0);
                    qa.setAnswerText(ans);
                    boolean correct3 = ans != null && ans.equalsIgnoreCase(q.getCorrectAnswer());
                    qa.setAwardedScore(correct3 ? q.getScore() : BigDecimal.ZERO);
                    if (correct3) totalScore = totalScore.add(q.getScore());
                    answers.save(qa);
                }
                case "SHORT_ANSWER", "ESSAY" -> {
                    String ans = studentAnswers.isEmpty() ? null : studentAnswers.get(0);
                    qa.setAnswerText(ans);
                    qa.setAwardedScore(null); // Manual grading
                    answers.save(qa);
                }
                default -> answers.save(qa);
            }
        }

        attempt.setSubmittedAt(now);
        attempt.setStatus("SUBMITTED");
        attempt.setScore(totalScore);

        // Check if all questions are auto-graded
        boolean hasManual = qList.stream()
                .anyMatch(q -> "SHORT_ANSWER".equals(q.getType()) || "ESSAY".equals(q.getType()));
        Users publisher = resolvePublisher(attempt);

        if (!hasManual && publisher != null) {
            attempt.setStatus("SCORED");
            attempt.setResultStatus("PUBLISHED");
            attempt.setPublishedAt(now);
            attempt.setPublishedBy(publisher);
        } else if (!hasManual) {
            attempt.setStatus("SCORED");
            attempt.setResultStatus("UNPUBLISHED");
            attempt.setPublishedAt(null);
            attempt.setPublishedBy(null);
        } else {
            attempt.setStatus("SUBMITTED");
            attempt.setResultStatus("UNPUBLISHED");
            attempt.setPublishedAt(null);
            attempt.setPublishedBy(null);
        }
        attempts.save(attempt);

        // Ghi lại lịch sử hoạt động nộp bài quiz (UC38)
        if (learningProgressService != null) {
            try {
                Quiz quiz = attempt.getQuiz();
                learningProgressService.recordActivity(attempt.getStudent(), quiz.getCourse(),
                        "QUIZ", null, null, quiz, "Đã làm bài kiểm tra: " + quiz.getTitle());
            } catch (Exception ignored) {}
        }

        // Tự động ghi nhận hoàn thành bài học khi học viên hoàn thành/đạt bài Quiz gắn với bài học (với quiz trắc nghiệm)
        if (!hasManual && lessonCompletions != null && attempt.getQuiz() != null && attempt.getQuiz().getLesson() != null) {
            Lesson quizLesson = attempt.getQuiz().getLesson();
            boolean passedQuiz = true;
            if (attempt.getQuiz().getPassingScore() != null && attempt.getMaxScore() != null
                    && attempt.getMaxScore().compareTo(BigDecimal.ZERO) > 0 && attempt.getScore() != null) {
                double pct = attempt.getScore().doubleValue() / attempt.getMaxScore().doubleValue() * 100.0;
                passedQuiz = pct >= attempt.getQuiz().getPassingScore().doubleValue();
            }
            Integer currentStudentId = attempt.getStudent() != null ? attempt.getStudent().getUserId() : null;
            if (passedQuiz && currentStudentId != null && !lessonCompletions.existsByStudent_UserIdAndLesson_LessonId(currentStudentId, quizLesson.getLessonId())) {
                try {
                    LessonCompletion lc = new LessonCompletion();
                    lc.setStudent(attempt.getStudent());
                    lc.setCourse(attempt.getQuiz().getCourse());
                    lc.setLesson(quizLesson);
                    lc.setCompletedAt(now);
                    lessonCompletions.save(lc);
                } catch (Exception ignored) {}
            }
        }
    }

    @Transactional(readOnly = true)
    public List<QuizAttemptView> getMyAttempts(Integer courseId, Integer quizId, Integer studentId) {
        getQuizForStudent(courseId, quizId, studentId);
        return attempts.findByQuiz_QuizIdAndStudent_UserIdOrderByAttemptNumberDesc(quizId, studentId)
                .stream()
                .peek(this::initAttempt)
                .map(this::toAttemptView).toList();
    }

    // ===================== HELPERS =====================

    public boolean isVideoLesson(Lesson lesson) {
        if (lesson == null) return false;
        return "VIDEO".equalsIgnoreCase(lesson.getLessonType())
                || (lesson.getVideoUrl() != null && !lesson.getVideoUrl().isBlank())
                || (lesson.getBunnyVideoId() != null && !lesson.getBunnyVideoId().isBlank())
                || Boolean.TRUE.equals(lesson.getQuizRequiresVideo());
    }

    public Optional<LessonWatchProgress> getLessonWatchProgress(Integer studentId, Integer lessonId) {
        return watchProgress != null
                ? watchProgress.findByStudent_UserIdAndLesson_LessonId(studentId, lessonId)
                : Optional.empty();
    }

    private void saveSelectedOption(QuizAnswer qa, Question q, String optionIdStr, List<AnswerOption> opts) {
        try {
            int optId = Integer.parseInt(optionIdStr);
            opts.stream().filter(o -> o.getOptionId().equals(optId)).findFirst().ifPresent(opt -> {
                QuizAnswerOption link = new QuizAnswerOption();
                link.setId(new QuizAnswerOptionPK(qa.getAnswerId(), opt.getOptionId()));
                link.setAnswer(qa);
                link.setQuestion(q);
                link.setOption(opt);
                link.setOptionContentSnapshot(opt.getContent());
                answerOptionLinks.save(link);
            });
        } catch (NumberFormatException ignored) {
        }
    }

    private void recalculateAttemptScore(QuizAttempt attempt) {
        List<QuizAnswer> allAnswers = answers.findByAttempt_AttemptIdOrderByQuestion_OrderIndexAsc(
                attempt.getAttemptId());
        BigDecimal total = allAnswers.stream()
                .filter(a -> a.getAwardedScore() != null)
                .map(QuizAnswer::getAwardedScore)
                .reduce(BigDecimal.ZERO, BigDecimal::add);
        attempt.setScore(total);
        boolean allGraded = allAnswers.stream().noneMatch(a -> a.getAwardedScore() == null);
        if (allGraded) {
            attempt.setStatus("SCORED");
            Users publisher = resolvePublisher(attempt);
            if (publisher != null) {
                attempt.setResultStatus("PUBLISHED");
                LocalDateTime pAt = LocalDateTime.now();
                if (attempt.getSubmittedAt() != null && pAt.isBefore(attempt.getSubmittedAt())) {
                    pAt = attempt.getSubmittedAt();
                }
                attempt.setPublishedAt(pAt);
                attempt.setPublishedBy(publisher);
            } else {
                attempt.setResultStatus("UNPUBLISHED");
            }
        }
        attempts.save(attempt);

        // Khi giảng viên chấm xong toàn bộ câu tự luận và học viên đạt điểm yêu cầu -> tự động ghi nhận hoàn thành bài học (nếu có gắn lesson)
        if (allGraded && lessonCompletions != null && attempt.getQuiz() != null && attempt.getQuiz().getLesson() != null) {
            Lesson quizLesson = attempt.getQuiz().getLesson();
            boolean passedQuiz = true;
            if (attempt.getQuiz().getPassingScore() != null && attempt.getMaxScore() != null
                    && attempt.getMaxScore().compareTo(BigDecimal.ZERO) > 0 && attempt.getScore() != null) {
                double pct = attempt.getScore().doubleValue() / attempt.getMaxScore().doubleValue() * 100.0;
                passedQuiz = pct >= attempt.getQuiz().getPassingScore().doubleValue();
            }
            if (passedQuiz && !lessonCompletions.existsByStudent_UserIdAndLesson_LessonId(attempt.getStudent().getUserId(), quizLesson.getLessonId())) {
                try {
                    LessonCompletion lc = new LessonCompletion();
                    lc.setStudent(attempt.getStudent());
                    lc.setCourse(attempt.getQuiz().getCourse());
                    lc.setLesson(quizLesson);
                    lc.setCompletedAt(LocalDateTime.now());
                    lessonCompletions.save(lc);
                } catch (Exception ignored) {}
            }
        }
    }

    private void applyForm(Quiz quiz, QuizForm form) {
        LocalDateTime start = parseDateTime(form.getStartTime());
        LocalDateTime due = parseDateTime(form.getDueDate());
        LocalDateTime end = parseDateTime(form.getEndTime());

        // Validate CK_quizzes_dates / CK_quizzes_window:
        // (start IS NULL OR due IS NULL OR start <= due) AND
        // (due IS NULL OR end IS NULL OR due <= end) AND
        // (start IS NULL OR end IS NULL OR start < end)
        if (start != null && end != null && !start.isBefore(end)) {
            throw new CourseActionException(HttpStatus.BAD_REQUEST, "Thời gian bắt đầu phải trước thời gian kết thúc.");
        }
        if (start != null && due != null && start.isAfter(due)) {
            throw new CourseActionException(HttpStatus.BAD_REQUEST, "Thời gian bắt đầu phải trước hoặc bằng hạn nộp.");
        }
        if (due != null && end != null && due.isAfter(end)) {
            throw new CourseActionException(HttpStatus.BAD_REQUEST, "Hạn nộp phải trước hoặc bằng thời gian kết thúc.");
        }
        if (form.getTimeLimitMinutes() != null && form.getTimeLimitMinutes() <= 0) {
            throw new CourseActionException(HttpStatus.BAD_REQUEST, "Thời gian làm bài phải lớn hơn 0 phút.");
        }
        if (form.getMaxAttempts() != null && form.getMaxAttempts() < 1) {
            throw new CourseActionException(HttpStatus.BAD_REQUEST, "Số lần làm tối đa phải ít nhất là 1.");
        }

        quiz.setTitle(form.getTitle().trim());
        quiz.setDescription(form.getDescription());
        quiz.setTimeLimitMinutes(form.getTimeLimitMinutes());
        quiz.setMaxAttempts(form.getMaxAttempts() != null ? form.getMaxAttempts() : 1);
        quiz.setStartTime(start);
        quiz.setDueDate(due);
        quiz.setEndTime(end);
        quiz.setRules(form.getRules());
        quiz.setPassingScore(form.getPassingScore());
        quiz.setShuffleQuestions(form.isShuffleQuestions());
        quiz.setShuffleOptions(form.isShuffleOptions());
        if (form.getLessonId() != null && form.getLessonId() > 0) {
            Lesson lesson = lessons.findById(form.getLessonId()).orElse(null);
            if (lesson != null) {
                Integer courseId = quiz.getCourse() != null ? quiz.getCourse().getCourseId() : null;
                if (courseId != null && (lesson.getCourse() == null || !lesson.getCourse().getCourseId().equals(courseId))) {
                    throw new CourseActionException(HttpStatus.BAD_REQUEST, "Bài học không thuộc khóa học này.");
                }
            }
            quiz.setLesson(lesson); // null-safe: nếu không tìm thấy thì không gắn
        } else {
            quiz.setLesson(null);
        }
    }

    private LocalDateTime parseDateTime(String value) {
        if (value == null || value.isBlank()) return null;
        try { return LocalDateTime.parse(value, DT_FMT); } catch (Exception e) { return null; }
    }

    private Course ownedCourse(Integer courseId, Integer instructorId) {
        Course course = courses.findById(courseId)
                .orElseThrow(() -> notFound("Không tìm thấy khóa học."));
        if (!course.getInstructor().getUserId().equals(instructorId))
            throw notFound("Không tìm thấy khóa học của bạn.");
        return course;
    }

    private void verifyEnrolled(Integer courseId, Integer studentId) {
        boolean enrolled = enrollments.findByStudent_UserIdAndCourse_CourseId(studentId, courseId)
                .filter(e -> "ACTIVE".equals(e.getStatus()) || "COMPLETED".equals(e.getStatus()))
                .isPresent();
        if (enrolled) return;

        Course course = courses.findById(courseId).orElse(null);
        if (course != null) {
            boolean isOwner = course.getInstructor() != null && Objects.equals(course.getInstructor().getUserId(), studentId);
            if (isOwner) return;

            Users u = users.findById(studentId).orElse(null);
            if (u != null && u.getUserRolesCollection() != null) {
                boolean isAdmin = u.getUserRolesCollection().stream()
                        .anyMatch(ur -> ur.getRoles() != null && "ADMINISTRATOR".equalsIgnoreCase(ur.getRoles().getRoleName()));
                if (isAdmin) return;
            }

            boolean isFree = course.getPrice() == null || course.getPrice().signum() == 0;
            if (isFree && u != null) {
                try {
                    Enrollment autoEnroll = new Enrollment();
                    autoEnroll.setCourse(course);
                    autoEnroll.setStudent(u);
                    autoEnroll.setStatus("ACTIVE");
                    autoEnroll.setEnrolledAt(LocalDateTime.now());
                    enrollments.save(autoEnroll);
                    return;
                } catch (Exception ignored) {
                    return;
                }
            }
        }
        throw new CourseActionException(HttpStatus.FORBIDDEN, "Bạn chưa ghi danh khóa học này.");
    }

    private Users user(Integer id) {
        return users.findById(id)
                .orElseThrow(() -> new CourseActionException(HttpStatus.UNAUTHORIZED, "Vui lòng đăng nhập lại."));
    }

    private QuizView toView(Quiz quiz) {
        long qCount = questions.countByQuiz_QuizId(quiz.getQuizId());
        List<Question> qList = questions.findByQuiz_QuizIdOrderByOrderIndexAsc(quiz.getQuizId());
        BigDecimal maxScore = qList.stream()
                .map(Question::getScore).reduce(BigDecimal.ZERO, BigDecimal::add);
        return new QuizView(quiz.getQuizId(), quiz.getTitle(), quiz.getStatus(),
                qCount, maxScore, quiz.getDueDate(), quiz.getTimeLimitMinutes(), quiz.getMaxAttempts(),
                0, quiz.getPassingScore(), null);
    }

    private QuizAttemptView toAttemptView(QuizAttempt a) {
        return new QuizAttemptView(a.getAttemptId(), a.getQuiz().getQuizId(), a.getQuiz().getTitle(),
                a.getStudent().getFullName(), a.getScore(), a.getMaxScore(),
                a.getStatus(), a.getResultStatus(), a.getSubmittedAt(), a.getAttemptNumber());
    }

    /** Initialize tất cả lazy association của Quiz trong khi session còn mở */
    public void initQuiz(Quiz quiz) {
        if (quiz == null) return;
        org.hibernate.Hibernate.initialize(quiz.getCourse());
        if (quiz.getLesson() != null) {
            org.hibernate.Hibernate.initialize(quiz.getLesson());
        }
        if (quiz.getCreatedBy() != null) {
            org.hibernate.Hibernate.initialize(quiz.getCreatedBy());
        }
    }

    /** Initialize tất cả lazy association của QuizAttempt trong khi session còn mở */
    private void initAttempt(QuizAttempt a) {
        if (a == null) return;
        org.hibernate.Hibernate.initialize(a.getQuiz());
        org.hibernate.Hibernate.initialize(a.getStudent());
        org.hibernate.Hibernate.initialize(a.getCourse());
        if (a.getCourse() != null) {
            org.hibernate.Hibernate.initialize(a.getCourse().getInstructor());
        }
        if (a.getQuiz() != null) {
            org.hibernate.Hibernate.initialize(a.getQuiz().getCourse());
            if (a.getQuiz().getCourse() != null) {
                org.hibernate.Hibernate.initialize(a.getQuiz().getCourse().getInstructor());
            }
            if (a.getQuiz().getCreatedBy() != null) {
                org.hibernate.Hibernate.initialize(a.getQuiz().getCreatedBy());
            }
            org.hibernate.Hibernate.initialize(a.getQuiz().getLesson());
        }
        if (a.getPublishedBy() != null) {
            org.hibernate.Hibernate.initialize(a.getPublishedBy());
        }
    }

    private Users resolvePublisher(QuizAttempt a) {
        if (a == null) return null;
        if (a.getQuiz() != null && a.getQuiz().getCreatedBy() != null) {
            return a.getQuiz().getCreatedBy();
        }
        if (a.getCourse() != null && a.getCourse().getInstructor() != null) {
            return a.getCourse().getInstructor();
        }
        if (a.getQuiz() != null && a.getQuiz().getCourse() != null && a.getQuiz().getCourse().getInstructor() != null) {
            return a.getQuiz().getCourse().getInstructor();
        }
        if (a.getStudent() != null) {
            return a.getStudent();
        }
        return null;
    }

    private CourseActionException notFound(String msg) {
        return new CourseActionException(HttpStatus.NOT_FOUND, msg);
    }

    private CourseActionException conflict(String msg) {
        return new CourseActionException(HttpStatus.CONFLICT, msg);
    }
}
