package com.edusphere.controller.course;

import com.edusphere.security.CustomUserDetails;
import com.edusphere.service.course.CourseActionException;
import com.edusphere.service.course.QuizService;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

@Controller
@RequestMapping("/courses/{courseId}/quizzes")
public class QuizStudentController {

    private final QuizService service;

    public QuizStudentController(QuizService service) {
        this.service = service;
    }

    @GetMapping
    public String list(@PathVariable Integer courseId,
                       @AuthenticationPrincipal CustomUserDetails user, Model model) {
        model.addAttribute("quizzes", service.listPublished(courseId, user.getUserId()));
        model.addAttribute("courseId", courseId);
        return "quizzes/student-list";
    }

    @GetMapping("/{quizId}")
    public String info(@PathVariable Integer courseId, @PathVariable Integer quizId,
                       @AuthenticationPrincipal CustomUserDetails user, Model model) {
        model.addAttribute("quiz", service.getQuizForStudent(courseId, quizId, user.getUserId()));
        model.addAttribute("myAttempts", service.getMyAttempts(courseId, quizId, user.getUserId()));
        model.addAttribute("courseId", courseId);
        model.addAttribute("quizId", quizId);
        return "quizzes/student-info";
    }

    @PostMapping("/{quizId}/start")
    public String start(@PathVariable Integer courseId, @PathVariable Integer quizId,
                        @AuthenticationPrincipal CustomUserDetails user, RedirectAttributes flash) {
        Integer attemptId = service.startAttempt(courseId, quizId, user.getUserId());
        return "redirect:/courses/" + courseId + "/quizzes/" + quizId + "/attempts/" + attemptId;
    }

    @GetMapping("/{quizId}/attempts/{attemptId}")
    public String takeQuiz(@PathVariable Integer courseId, @PathVariable Integer quizId,
                           @PathVariable Integer attemptId,
                           @AuthenticationPrincipal CustomUserDetails user, Model model) {
        var attempt = service.getAttemptForStudent(courseId, quizId, attemptId, user.getUserId());
        if (!"IN_PROGRESS".equals(attempt.getStatus())) {
            return "redirect:/courses/" + courseId + "/quizzes/" + quizId + "/attempts/" + attemptId + "/result";
        }
        model.addAttribute("attempt", attempt);
        model.addAttribute("questions", service.getQuestionsForAttempt(courseId, quizId, user.getUserId()));
        model.addAttribute("courseId", courseId);
        model.addAttribute("quizId", quizId);
        model.addAttribute("attemptId", attemptId);
        return "quizzes/take";
    }

    @PostMapping("/{quizId}/attempts/{attemptId}/submit")
    public String submitQuiz(@PathVariable Integer courseId, @PathVariable Integer quizId,
                             @PathVariable Integer attemptId,
                             HttpServletRequest request,
                             @AuthenticationPrincipal CustomUserDetails user, RedirectAttributes flash) {
        // Parse answers from request parameters: answer_<questionId> = list of values
        Map<Integer, List<String>> questionAnswers = new HashMap<>();
        Map<String, String[]> params = request.getParameterMap();
        for (Map.Entry<String, String[]> entry : params.entrySet()) {
            String key = entry.getKey();
            if (key.startsWith("answer_")) {
                try {
                    Integer qId = Integer.parseInt(key.substring(7));
                    List<String> values = new ArrayList<>(Arrays.asList(entry.getValue()));
                    questionAnswers.put(qId, values);
                } catch (NumberFormatException ignored) {
                }
            }
        }
        service.submitAttempt(courseId, quizId, attemptId, user.getUserId(), questionAnswers);
        flash.addFlashAttribute("success", "Đã nộp bài quiz!");
        return "redirect:/courses/" + courseId + "/quizzes/" + quizId + "/attempts/" + attemptId + "/result";
    }

    @GetMapping("/{quizId}/attempts/{attemptId}/result")
    public String result(@PathVariable Integer courseId, @PathVariable Integer quizId,
                         @PathVariable Integer attemptId,
                         @AuthenticationPrincipal CustomUserDetails user, Model model) {
        var attempt = service.getAttemptForStudent(courseId, quizId, attemptId, user.getUserId());
        model.addAttribute("attempt", attempt);
        model.addAttribute("answers", service.getAnswersForAttempt(attemptId));
        model.addAttribute("courseId", courseId);
        model.addAttribute("quizId", quizId);
        return "quizzes/result";
    }

    @ExceptionHandler(CourseActionException.class)
    public String handleError(CourseActionException ex, HttpServletResponse response, Model model) {
        response.setStatus(ex.getStatus().value());
        model.addAttribute("errorMessage", ex.getMessage());
        return "courses/action-error";
    }
}
