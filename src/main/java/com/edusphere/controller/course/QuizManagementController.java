package com.edusphere.controller.course;

import com.edusphere.dto.quiz.QuestionForm;
import com.edusphere.dto.quiz.QuizForm;
import com.edusphere.security.CustomUserDetails;
import com.edusphere.service.course.CourseActionException;
import com.edusphere.service.course.QuizService;

import jakarta.servlet.http.HttpServletResponse;
import jakarta.validation.Valid;

import java.math.BigDecimal;

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

    public QuizManagementController(QuizService service) {
        this.service = service;
    }

    @GetMapping
    public String list(@PathVariable Integer courseId,
                       @AuthenticationPrincipal CustomUserDetails user, Model model) {
        model.addAttribute("quizzes", service.listForCourse(courseId, user.getUserId()));
        model.addAttribute("courseId", courseId);
        return "quizzes/instructor-list";
    }

    @GetMapping("/new")
    public String newForm(@PathVariable Integer courseId, Model model) {
        model.addAttribute("quizForm", new QuizForm());
        model.addAttribute("courseId", courseId);
        return "quizzes/quiz-form";
    }

    @PostMapping
    public String create(@PathVariable Integer courseId,
                         @Valid @ModelAttribute("quizForm") QuizForm form, BindingResult errors,
                         @AuthenticationPrincipal CustomUserDetails user,
                         Model model, RedirectAttributes flash) {
        if (errors.hasErrors()) {
            model.addAttribute("courseId", courseId);
            return "quizzes/quiz-form";
        }
        Integer quizId = service.create(courseId, user.getUserId(), form);
        flash.addFlashAttribute("success", "Đã tạo quiz thành công.");
        return "redirect:/instructor/courses/" + courseId + "/quizzes/" + quizId;
    }

    @GetMapping("/{quizId}")
    public String detail(@PathVariable Integer courseId, @PathVariable Integer quizId,
                         @AuthenticationPrincipal CustomUserDetails user, Model model) {
        model.addAttribute("quiz", service.getQuizForInstructor(courseId, quizId, user.getUserId()));
        model.addAttribute("questions", service.getQuestionsForInstructor(courseId, quizId, user.getUserId()));
        model.addAttribute("courseId", courseId);
        model.addAttribute("quizId", quizId);
        return "quizzes/instructor-detail";
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
