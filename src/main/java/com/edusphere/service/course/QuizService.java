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
import com.edusphere.entity.course.Lesson;
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
        if (q.getLesson() != null) {
            q.getLesson().getLessonId();
            q.getLesson().getTitle();
        }
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

        q.setContent(form.getContent().trim());
        q.setType(form.getType());
        q.setScore(form.getScore());
        q.setCorrectAnswer(form.getCorrectAnswer());
        q.setExplanation(form.getExplanation());
        q.setImageUrl(form.getImageUrl() != null && !form.getImageUrl().isBlank() ? form.getImageUrl().trim() : null);
        q.setVideoUrl(form.getVideoUrl() != null && !form.getVideoUrl().isBlank() ? form.getVideoUrl().trim() : null);
        q.setSampleEssayAnswer(form.getSampleEssayAnswer());

        // Rebuild options (delete old, add new)
        List<Integer> oldOptionIds = q.getOptions().stream()
                .map(AnswerOption::getOptionId)
                .filter(java.util.Objects::nonNull)
                .toList();
        if (!oldOptionIds.isEmpty()) {
            answerOptionLinks.deleteByOption_OptionIdIn(oldOptionIds);
            answerOptionLinks.flush();
        }
        answerOptions.deleteAll(q.getOptions());
        q.getOptions().clear();
        answerOptions.flush();

        if (Set.of("SINGLE_CHOICE", "MULTIPLE_CHOICE").contains(form.getType())) {
            List<String> contents = form.getOptionContents();
            List<Boolean> corrects = form.getOptionCorrects();
            int idx = 1;
            for (int i = 0; i < contents.size(); i++) {
                String c = contents.get(i);
                if (c == null || c.isBlank()) continue;
                AnswerOption opt = new AnswerOption();
                opt.setQuestion(q);
                opt.setContent(c.trim());
                opt.setCorrect(corrects != null && i < corrects.size() && Boolean.TRUE.equals(corrects.get(i)));
                opt.setOrderIndex(idx++);
                answerOptions.save(opt);
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
        // Re-index remaining questions
        List<Question> remaining = questions.findByQuiz_QuizIdOrderByOrderIndexAsc(quizId);
        int idx = 1;
        for (Question r : remaining) {
            r.setOrderIndex(idx++);
            questions.save(r);
        }
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
        int tmp = a.getOrderIndex();
        a.setOrderIndex(b.getOrderIndex());
        b.setOrderIndex(tmp);
        questions.save(a); questions.save(b);
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
        if (!"SCORED".equals(attempt.getStatus()))
            throw conflict("Chỉ công bố được khi bài làm đã chấm xong toàn bộ câu hỏi.");
        if ("PUBLISHED".equals(attempt.getResultStatus()))
            throw conflict("Kết quả đã được công bố.");
        attempt.setResultStatus("PUBLISHED");
        attempt.setPublishedBy(user(instructorId));
        attempt.setPublishedAt(LocalDateTime.now());
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
        return quiz;
    }

    @Transactional
    public Integer startAttempt(Integer courseId, Integer quizId, Integer studentId) {
        Quiz quiz = getQuizForStudent(courseId, quizId, studentId);

        // ── Backend gate: kiểm tra điều kiện xem video tối thiểu 80% để mở khóa Quiz ──
        Lesson quizLesson = quiz.getLesson();
        if (quizLesson != null && isVideoLesson(quizLesson)) {
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
    public QuizAttempt getAttemptForStudent(Integer attemptId, Integer studentId) {
        QuizAttempt attempt = attempts.findByAttemptIdAndStudent_UserId(attemptId, studentId)
                .orElseThrow(() -> notFound("Không tìm thấy lần làm quiz."));
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
    public void submitAttempt(Integer attemptId, Integer studentId,
                              Map<Integer, List<String>> questionAnswers) {
        QuizAttempt attempt = getAttemptForStudent(attemptId, studentId);
        if (!"IN_PROGRESS".equals(attempt.getStatus()))
            throw conflict("Lần làm quiz này không ở trạng thái đang làm.");

        // Check deadline
        LocalDateTime now = LocalDateTime.now();
        if (attempt.getDeadlineAt() != null && now.isAfter(attempt.getDeadlineAt()))
            throw conflict("Đã hết thời gian làm quiz.");

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
        if (!hasManual) {
            attempt.setStatus("SCORED");
        }
        attempts.save(attempt);

        // Ghi lại lịch sử hoạt động nộp bài quiz (UC38)
        if (learningProgressService != null) {
            Quiz quiz = attempt.getQuiz();
            learningProgressService.recordActivity(attempt.getStudent(), quiz.getCourse(),
                    "QUIZ_SUBMITTED", quiz.getLesson(), null, quiz, "Đã làm bài kiểm tra: " + quiz.getTitle());
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
        if (allGraded) attempt.setStatus("SCORED");
    }

    private void applyForm(Quiz quiz, QuizForm form) {
        quiz.setTitle(form.getTitle().trim());
        quiz.setDescription(form.getDescription());
        quiz.setTimeLimitMinutes(form.getTimeLimitMinutes());
        quiz.setMaxAttempts(form.getMaxAttempts() != null ? form.getMaxAttempts() : 1);
        quiz.setStartTime(parseDateTime(form.getStartTime()));
        quiz.setDueDate(null);
        quiz.setEndTime(null);
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
        enrollments.findByStudent_UserIdAndCourse_CourseId(studentId, courseId)
                .filter(e -> "ACTIVE".equals(e.getStatus()) || "COMPLETED".equals(e.getStatus()))
                .orElseThrow(() -> new CourseActionException(HttpStatus.FORBIDDEN, "Bạn chưa ghi danh khóa học này."));
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

    /** Initialize tất cả lazy association của QuizAttempt trong khi session còn mở */
    private void initAttempt(QuizAttempt a) {
        org.hibernate.Hibernate.initialize(a.getQuiz());
        org.hibernate.Hibernate.initialize(a.getStudent());
        org.hibernate.Hibernate.initialize(a.getCourse());
        if (a.getQuiz() != null) {
            org.hibernate.Hibernate.initialize(a.getQuiz().getLesson());
        }
        if (a.getPublishedBy() != null) {
            org.hibernate.Hibernate.initialize(a.getPublishedBy());
        }
    }

    private CourseActionException notFound(String msg) {
        return new CourseActionException(HttpStatus.NOT_FOUND, msg);
    }

    private CourseActionException conflict(String msg) {
        return new CourseActionException(HttpStatus.CONFLICT, msg);
    }
}
