package com.edusphere.controller.course;

import com.edusphere.dto.quiz.QuestionForm;
import com.edusphere.dto.quiz.QuizForm;
import com.edusphere.entity.course.Quiz;
import com.edusphere.repository.course.LessonRepository;
import com.edusphere.security.CustomUserDetails;
import com.edusphere.service.course.CourseActionException;
import com.edusphere.service.course.QuestionBankService;
import com.edusphere.service.course.QuizService;

import jakarta.servlet.http.HttpServletResponse;
import jakarta.validation.Valid;

import java.math.BigDecimal;
import java.util.List;

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
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

@Controller
@RequestMapping("/instructor/courses/{courseId}/quizzes")
public class QuizManagementController {

    private final QuizService service;
    private final LessonRepository lessonRepository;
    private final QuestionBankService questionBankService;

    public QuizManagementController(QuizService service, LessonRepository lessonRepository, QuestionBankService questionBankService) {
        this.service = service;
        this.lessonRepository = lessonRepository;
        this.questionBankService = questionBankService;
    }

    @GetMapping
    public String list(@PathVariable Integer courseId,
                       @RequestParam(required = false) Integer lessonId,
                       @AuthenticationPrincipal CustomUserDetails user, Model model) {
        model.addAttribute("quizzes", service.listForCourse(courseId, user.getUserId()));
        model.addAttribute("courseId", courseId);
        model.addAttribute("selectedLessonId", lessonId);
        return "quizzes/instructor-list";
    }

    @GetMapping("/new")
    public String newForm(@PathVariable Integer courseId,
                          @RequestParam(required = false) Integer lessonId,
                          @AuthenticationPrincipal CustomUserDetails user,
                          Model model) {
        service.listForCourse(courseId, user.getUserId());
        QuizForm form = new QuizForm();
        if (lessonId != null) form.setLessonId(lessonId);
        model.addAttribute("quizForm", form);
        model.addAttribute("courseId", courseId);
        model.addAttribute("lessons", lessonRepository.findByCourse_CourseIdOrderByOrderIndexAsc(courseId));
        return "quizzes/quiz-form";
    }

    @PostMapping
    public String create(@PathVariable Integer courseId,
                         @Valid @ModelAttribute("quizForm") QuizForm form, BindingResult errors,
                         @AuthenticationPrincipal CustomUserDetails user,
                         Model model, RedirectAttributes flash) {
        if (errors.hasErrors()) {
            model.addAttribute("courseId", courseId);
            model.addAttribute("lessons", lessonRepository.findByCourse_CourseIdOrderByOrderIndexAsc(courseId));
            return "quizzes/quiz-form";
        }
        Integer quizId = service.create(courseId, user.getUserId(), form);
        flash.addFlashAttribute("success", "Đã tạo quiz thành công.");
        return "redirect:/instructor/courses/" + courseId + "/quizzes/" + quizId;
    }

    @GetMapping("/{quizId}")
    public String detail(@PathVariable Integer courseId, @PathVariable Integer quizId,
                         @AuthenticationPrincipal CustomUserDetails user, Model model) {
        model.addAttribute("quiz", service.getQuizWithQuestions(courseId, quizId, user.getUserId()));
        model.addAttribute("questions", service.getQuestionsWithOptions(courseId, quizId, user.getUserId()));
        model.addAttribute("lessons", lessonRepository.findByCourse_CourseIdOrderByOrderIndexAsc(courseId));
        model.addAttribute("questionBanks", questionBankService.listBanksForInstructor(user.getUserId()));
        model.addAttribute("courseId", courseId);
        model.addAttribute("quizId", quizId);
        return "quizzes/quiz-builder";
    }

    // ── Auto-generate questions from Question Bank ──
    @PostMapping("/{quizId}/auto-generate")
    public String autoGenerate(@PathVariable Integer courseId, @PathVariable Integer quizId,
                               @RequestParam Integer bankId,
                               @RequestParam(required = false) Integer categoryId,
                               @RequestParam(defaultValue = "10") int count,
                               @RequestParam(defaultValue = "false") boolean replaceExisting,
                               @RequestParam(required = false) BigDecimal defaultScore,
                               @AuthenticationPrincipal CustomUserDetails user,
                               RedirectAttributes flash) {
        try {
            int generated = service.autoGenerateFromBank(courseId, quizId, user.getUserId(), bankId, categoryId, count, defaultScore, replaceExisting);
            flash.addFlashAttribute("success", "Đã tự động bốc thành công " + generated + " câu hỏi từ ngân hàng vào bài quiz!");
        } catch (CourseActionException ex) {
            flash.addFlashAttribute("error", ex.getMessage());
        }
        return "redirect:/instructor/courses/" + courseId + "/quizzes/" + quizId;
    }

    // ── Import selected questions from Question Bank ──
    @PostMapping("/{quizId}/import-bank-questions")
    public String importBankQuestions(@PathVariable Integer courseId, @PathVariable Integer quizId,
                                      @RequestParam Integer bankId,
                                      @RequestParam(value = "bankQuestionIds", required = false) List<Integer> bankQuestionIds,
                                      @AuthenticationPrincipal CustomUserDetails user,
                                      RedirectAttributes flash) {
        if (bankQuestionIds == null || bankQuestionIds.isEmpty()) {
            flash.addFlashAttribute("error", "Chưa chọn câu hỏi nào từ ngân hàng.");
            return "redirect:/instructor/courses/" + courseId + "/quizzes/" + quizId;
        }
        try {
            int added = service.importQuestionsFromBank(courseId, quizId, user.getUserId(), bankId, bankQuestionIds);
            flash.addFlashAttribute("success", "Đã thêm thành công " + added + " câu hỏi từ ngân hàng vào bài quiz!");
        } catch (CourseActionException ex) {
            flash.addFlashAttribute("error", ex.getMessage());
        }
        return "redirect:/instructor/courses/" + courseId + "/quizzes/" + quizId;
    }

    // ── Edit quiz settings ──
    @GetMapping("/{quizId}/edit")
    public String editForm(@PathVariable Integer courseId, @PathVariable Integer quizId,
                           @AuthenticationPrincipal CustomUserDetails user, Model model) {
        Quiz quiz = service.getQuizForInstructor(courseId, quizId, user.getUserId());
        QuizForm form = new QuizForm();
        form.setTitle(quiz.getTitle());
        form.setDescription(quiz.getDescription());
        form.setTimeLimitMinutes(quiz.getTimeLimitMinutes());
        form.setMaxAttempts(quiz.getMaxAttempts());
        form.setStartTime(quiz.getStartTime() != null ? quiz.getStartTime().format(java.time.format.DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm")) : null);
        form.setRules(quiz.getRules());
        form.setLessonId(quiz.getLesson() != null ? quiz.getLesson().getLessonId() : null);
        form.setPassingScore(quiz.getPassingScore());
        form.setShuffleQuestions(quiz.isShuffleQuestions());
        form.setShuffleOptions(quiz.isShuffleOptions());
        model.addAttribute("quizForm", form);
        model.addAttribute("courseId", courseId);
        model.addAttribute("quizId", quizId);
        model.addAttribute("lessons", lessonRepository.findByCourse_CourseIdOrderByOrderIndexAsc(courseId));
        return "quizzes/quiz-form";
    }

    @PostMapping("/{quizId}/edit")
    public String update(@PathVariable Integer courseId, @PathVariable Integer quizId,
                         @Valid @ModelAttribute("quizForm") QuizForm form, BindingResult errors,
                         @AuthenticationPrincipal CustomUserDetails user,
                         Model model, RedirectAttributes flash) {
        if (errors.hasErrors()) {
            model.addAttribute("courseId", courseId);
            model.addAttribute("quizId", quizId);
            model.addAttribute("lessons", lessonRepository.findByCourse_CourseIdOrderByOrderIndexAsc(courseId));
            return "quizzes/quiz-form";
        }
        service.updateQuiz(courseId, quizId, user.getUserId(), form);
        flash.addFlashAttribute("success", "Đã cập nhật cài đặt quiz.");
        return "redirect:/instructor/courses/" + courseId + "/quizzes/" + quizId;
    }

    // ── Edit / Delete question ──
    @GetMapping("/{quizId}/questions/{questionId}/edit")
    public String editQuestionForm(@PathVariable Integer courseId, @PathVariable Integer quizId,
                                   @PathVariable Integer questionId,
                                   @AuthenticationPrincipal CustomUserDetails user, Model model) {
        var qList = service.getQuestionsWithOptions(courseId, quizId, user.getUserId());
        var q = qList.stream().filter(x -> x.getQuestionId().equals(questionId))
                .findFirst().orElseThrow(() -> new com.edusphere.service.course.CourseActionException(
                        org.springframework.http.HttpStatus.NOT_FOUND, "Không tìm thấy câu hỏi."));
        QuestionForm form = new QuestionForm();
        form.setContent(q.getContent());
        form.setType(q.getType());
        form.setScore(q.getScore());
        form.setCorrectAnswer(q.getCorrectAnswer());
        form.setExplanation(q.getExplanation());
        form.setImageUrl(q.getImageUrl());
        form.setVideoUrl(q.getVideoUrl());
        form.setSampleEssayAnswer(q.getSampleEssayAnswer());
        var optContents = new java.util.ArrayList<String>();
        var optCorrects = new java.util.ArrayList<Boolean>();
        for (var opt : q.getOptions()) {
            optContents.add(opt.getContent());
            optCorrects.add(opt.isCorrect());
        }
        // Pad to 6 slots
        while (optContents.size() < 6) { optContents.add(""); optCorrects.add(false); }
        form.setOptionContents(optContents);
        form.setOptionCorrects(optCorrects);
        model.addAttribute("questionForm", form);
        model.addAttribute("courseId", courseId);
        model.addAttribute("quizId", quizId);
        model.addAttribute("questionId", questionId);
        return "quizzes/question-form";
    }

    @PostMapping("/{quizId}/questions/{questionId}/edit")
    public String updateQuestion(@PathVariable Integer courseId, @PathVariable Integer quizId,
                                 @PathVariable Integer questionId,
                                 @Valid @ModelAttribute("questionForm") QuestionForm form, BindingResult errors,
                                 @AuthenticationPrincipal CustomUserDetails user,
                                 Model model, RedirectAttributes flash) {
        if (errors.hasErrors()) {
            model.addAttribute("courseId", courseId);
            model.addAttribute("quizId", quizId);
            model.addAttribute("questionId", questionId);
            return "quizzes/question-form";
        }
        service.updateQuestion(courseId, quizId, questionId, user.getUserId(), form);
        flash.addFlashAttribute("success", "Đã cập nhật câu hỏi.");
        return "redirect:/instructor/courses/" + courseId + "/quizzes/" + quizId;
    }

    @PostMapping("/{quizId}/questions/{questionId}/delete")
    public String deleteQuestion(@PathVariable Integer courseId, @PathVariable Integer quizId,
                                 @PathVariable Integer questionId,
                                 @AuthenticationPrincipal CustomUserDetails user, RedirectAttributes flash) {
        service.deleteQuestion(courseId, quizId, questionId, user.getUserId());
        flash.addFlashAttribute("success", "Đã xóa câu hỏi.");
        return "redirect:/instructor/courses/" + courseId + "/quizzes/" + quizId;
    }

    @PostMapping("/{quizId}/questions/{questionId}/move")
    public String moveQuestion(@PathVariable Integer courseId, @PathVariable Integer quizId,
                               @PathVariable Integer questionId,
                               @RequestParam String direction,
                               @AuthenticationPrincipal CustomUserDetails user, RedirectAttributes flash) {
        service.moveQuestion(courseId, quizId, questionId, direction, user.getUserId());
        return "redirect:/instructor/courses/" + courseId + "/quizzes/" + quizId;
    }

    @GetMapping("/{quizId}/questions/new")
    public String newQuestion(@PathVariable Integer courseId, @PathVariable Integer quizId,
                              @AuthenticationPrincipal CustomUserDetails user, Model model) {
        service.getQuizForInstructor(courseId, quizId, user.getUserId()); // verify ownership
        model.addAttribute("questionForm", new QuestionForm());
        model.addAttribute("courseId", courseId);
        model.addAttribute("quizId", quizId);
        return "quizzes/question-form";
    }

    @PostMapping("/{quizId}/questions")
    public String addQuestion(@PathVariable Integer courseId, @PathVariable Integer quizId,
                              @Valid @ModelAttribute("questionForm") QuestionForm form, BindingResult errors,
                              @AuthenticationPrincipal CustomUserDetails user,
                              Model model, RedirectAttributes flash) {
        if (errors.hasErrors()) {
            model.addAttribute("courseId", courseId);
            model.addAttribute("quizId", quizId);
            return "quizzes/question-form";
        }
        service.addQuestion(courseId, quizId, user.getUserId(), form);
        flash.addFlashAttribute("success", "Đã thêm câu hỏi.");
        return "redirect:/instructor/courses/" + courseId + "/quizzes/" + quizId;
    }

    @PostMapping("/{quizId}/publish")
    public String publish(@PathVariable Integer courseId, @PathVariable Integer quizId,
                          @AuthenticationPrincipal CustomUserDetails user, RedirectAttributes flash) {
        service.publish(courseId, quizId, user.getUserId());
        flash.addFlashAttribute("success", "Đã công bố quiz.");
        return "redirect:/instructor/courses/" + courseId + "/quizzes/" + quizId;
    }

    @PostMapping("/{quizId}/archive")
    public String archive(@PathVariable Integer courseId, @PathVariable Integer quizId,
                          @AuthenticationPrincipal CustomUserDetails user, RedirectAttributes flash) {
        service.archive(courseId, quizId, user.getUserId());
        flash.addFlashAttribute("success", "Đã lưu trữ quiz.");
        return "redirect:/instructor/courses/" + courseId + "/quizzes/" + quizId;
    }

    @PostMapping("/{quizId}/restore")
    public String restore(@PathVariable Integer courseId, @PathVariable Integer quizId,
                          @AuthenticationPrincipal CustomUserDetails user, RedirectAttributes flash) {
        service.restore(courseId, quizId, user.getUserId());
        flash.addFlashAttribute("success", "Đã khôi phục quiz. Học viên có thể làm bài trở lại.");
        return "redirect:/instructor/courses/" + courseId + "/quizzes/" + quizId;
    }

    @GetMapping("/{quizId}/attempts")
    public String listAttempts(@PathVariable Integer courseId, @PathVariable Integer quizId,
                               @AuthenticationPrincipal CustomUserDetails user, Model model) {
        model.addAttribute("attempts", service.listAttempts(courseId, quizId, user.getUserId()));
        model.addAttribute("quiz", service.getQuizForInstructor(courseId, quizId, user.getUserId()));
        model.addAttribute("courseId", courseId);
        model.addAttribute("quizId", quizId);
        return "quizzes/attempt-list";
    }

    @GetMapping("/{quizId}/attempts/{attemptId}")
    public String attemptDetail(@PathVariable Integer courseId, @PathVariable Integer quizId,
                                @PathVariable Integer attemptId,
                                @AuthenticationPrincipal CustomUserDetails user, Model model) {
        var attempt = service.getAttemptForInstructor(courseId, quizId, attemptId, user.getUserId());
        model.addAttribute("attempt", attempt);
        model.addAttribute("answers", service.getAnswersForAttempt(attemptId));
        model.addAttribute("courseId", courseId);
        model.addAttribute("quizId", quizId);
        return "quizzes/attempt-detail";
    }

    @PostMapping("/{quizId}/attempts/{attemptId}/answers/{answerId}/grade")
    public String gradeEssay(@PathVariable Integer courseId, @PathVariable Integer quizId,
                             @PathVariable Integer attemptId, @PathVariable Integer answerId,
                             @RequestParam BigDecimal score,
                             @AuthenticationPrincipal CustomUserDetails user, RedirectAttributes flash) {
        service.gradeEssay(courseId, quizId, attemptId, answerId, user.getUserId(), score);
        flash.addFlashAttribute("success", "Đã chấm điểm câu hỏi.");
        return "redirect:/instructor/courses/" + courseId + "/quizzes/" + quizId + "/attempts/" + attemptId;
    }

    @PostMapping("/{quizId}/attempts/{attemptId}/publish")
    public String publishResult(@PathVariable Integer courseId, @PathVariable Integer quizId,
                                @PathVariable Integer attemptId,
                                @AuthenticationPrincipal CustomUserDetails user, RedirectAttributes flash) {
        service.publishAttemptResult(courseId, quizId, attemptId, user.getUserId());
        flash.addFlashAttribute("success", "Đã công bố kết quả quiz.");
        return "redirect:/instructor/courses/" + courseId + "/quizzes/" + quizId + "/attempts/" + attemptId;
    }

    @ExceptionHandler(CourseActionException.class)
    public String handleError(CourseActionException ex, HttpServletResponse response, Model model) {
        response.setStatus(ex.getStatus().value());
        model.addAttribute("errorMessage", ex.getMessage());
        return "courses/action-error";
    }
}
