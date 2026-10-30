package com.edusphere.service.course;

import com.edusphere.dto.result.ResultRow;
import com.edusphere.dto.result.StudentResultsView;
import com.edusphere.entity.course.Course;
import com.edusphere.entity.course.Grade;
import com.edusphere.entity.course.QuizAttempt;
import com.edusphere.entity.course.Submission;
import com.edusphere.repository.course.CourseRepository;
import com.edusphere.repository.course.EnrollmentRepository;
import com.edusphere.repository.course.GradeRepository;
import com.edusphere.repository.course.QuizAttemptRepository;
import com.edusphere.repository.course.SubmissionRepository;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;

import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * UC32 Publish Learning Results (Instructor) và UC33 View Learning Results (Student).
 * Tổng hợp điểm bài tập + quiz; việc công bố từng mục dùng lại AssignmentService / QuizService.
 */
@Service
public class LearningResultService {

    private static final String NOT_GRADED = "NOT_GRADED";
    private static final String READY = "READY";
    private static final String PUBLISHED = "PUBLISHED";

    private final CourseRepository courses;
    private final EnrollmentRepository enrollments;
    private final SubmissionRepository submissions;
    private final GradeRepository grades;
    private final QuizAttemptRepository attempts;
    private final AssignmentService assignmentService;
    private final QuizService quizService;

    public LearningResultService(CourseRepository courses, EnrollmentRepository enrollments,
                                 SubmissionRepository submissions, GradeRepository grades,
                                 QuizAttemptRepository attempts,
                                 AssignmentService assignmentService, QuizService quizService) {
        this.courses = courses;
        this.enrollments = enrollments;
        this.submissions = submissions;
        this.grades = grades;
        this.attempts = attempts;
        this.assignmentService = assignmentService;
        this.quizService = quizService;
    }

    // ===================== UC32 — INSTRUCTOR =====================

    @Transactional(readOnly = true)
    public Course ownedCourse(Integer courseId, Integer instructorId) {
        Course course = courses.findById(courseId)
                .orElseThrow(() -> new CourseActionException(HttpStatus.NOT_FOUND, "Không tìm thấy khóa học."));
        if (!course.getInstructor().getUserId().equals(instructorId))
            throw new CourseActionException(HttpStatus.NOT_FOUND, "Không tìm thấy khóa học của bạn.");
        return course;
    }

    /** Toàn bộ kết quả của khóa học (mọi học viên), kèm trạng thái để giảng viên kiểm tra trước khi công bố. */
    @Transactional(readOnly = true)
    public List<ResultRow> instructorOverview(Integer courseId, Integer instructorId) {
        ownedCourse(courseId, instructorId);
        List<ResultRow> rows = new ArrayList<>();
        for (Submission s : submissions.findByCourse_CourseIdOrderBySubmittedAtDesc(courseId)) {
            rows.add(assignmentRow(s, grades.findBySubmission_SubmissionId(s.getSubmissionId()).orElse(null), true));
        }
        for (QuizAttempt a : attempts.findByCourse_CourseIdAndStatusInOrderBySubmittedAtDesc(
                courseId, List.of("SUBMITTED", "SCORED"))) {
            rows.add(quizRow(a, true));
        }
        rows.sort(Comparator.comparing(ResultRow::getSubmittedAt,
                Comparator.nullsLast(Comparator.reverseOrder())));
        return rows;
    }

    @Transactional
    public void publishAssignment(Integer courseId, Integer assignmentId, Integer submissionId, Integer instructorId) {
        assignmentService.publishGrade(courseId, assignmentId, submissionId, instructorId);
    }

    @Transactional
    public void publishQuiz(Integer courseId, Integer quizId, Integer attemptId, Integer instructorId) {
        quizService.publishAttemptResult(courseId, quizId, attemptId, instructorId);
    }

    /** Công bố tất cả kết quả đã chấm xong nhưng chưa công bố. Trả về số mục đã công bố. */
    @Transactional
    public int publishAllReady(Integer courseId, Integer instructorId) {
        int count = 0;
        for (ResultRow row : instructorOverview(courseId, instructorId)) {
            if (!READY.equals(row.getState())) continue;
            if ("ASSIGNMENT".equals(row.getKind()))
                assignmentService.publishGrade(courseId, row.getParentId(), row.getRefId(), instructorId);
            else
                quizService.publishAttemptResult(courseId, row.getParentId(), row.getRefId(), instructorId);
            count++;
        }
        return count;
    }

    // ===================== UC33 — STUDENT =====================

    @Transactional(readOnly = true)
    public StudentResultsView studentResults(Integer courseId, Integer studentId) {
        var enrollment = enrollments.findByStudent_UserIdAndCourse_CourseId(studentId, courseId)
                .filter(e -> "ACTIVE".equals(e.getStatus()) || "COMPLETED".equals(e.getStatus()))
                .orElseThrow(() -> new CourseActionException(HttpStatus.FORBIDDEN, "Bạn chưa ghi danh khóa học này."));

        List<ResultRow> rows = new ArrayList<>();
        for (Submission s : submissions.findByCourse_CourseIdAndStudent_UserIdOrderBySubmittedAtDesc(courseId, studentId)) {
            rows.add(assignmentRow(s, grades.findBySubmission_SubmissionId(s.getSubmissionId()).orElse(null), false));
        }
        for (QuizAttempt a : attempts.findByCourse_CourseIdAndStudent_UserIdAndStatusInOrderBySubmittedAtDesc(
                courseId, studentId, List.of("SUBMITTED", "SCORED"))) {
            rows.add(quizRow(a, false));
        }
        rows.sort(Comparator.comparing(ResultRow::getSubmittedAt,
                Comparator.nullsLast(Comparator.reverseOrder())));

        long published = rows.stream().filter(r -> PUBLISHED.equals(r.getState())).count();
        BigDecimal average = null;
        if (published > 0) {
            BigDecimal sum = BigDecimal.ZERO;
            for (ResultRow r : rows) {
                if (PUBLISHED.equals(r.getState()) && r.getMaxScore() != null
                        && r.getMaxScore().signum() > 0 && r.getScore() != null) {
                    sum = sum.add(r.getScore().multiply(BigDecimal.valueOf(100))
                            .divide(r.getMaxScore(), 4, RoundingMode.HALF_UP));
                }
            }
            average = sum.divide(BigDecimal.valueOf(published), 1, RoundingMode.HALF_UP);
        }
        return new StudentResultsView(enrollment.getCourse().getTitle(), rows, published, average);
    }

    // ===================== helpers =====================

    /** includeHidden=true (giảng viên): luôn thấy điểm; false (học viên): chỉ thấy điểm khi đã công bố. */
    private ResultRow assignmentRow(Submission s, Grade g, boolean includeHidden) {
        String state = g == null ? NOT_GRADED : ("PUBLISHED".equals(g.getResultStatus()) ? PUBLISHED : READY);
        boolean visible = includeHidden || PUBLISHED.equals(state);
        return new ResultRow("ASSIGNMENT", s.getAssignment().getAssignmentId(), s.getSubmissionId(),
                s.getAssignment().getTitle(), s.getStudent().getFullName(), s.getAttemptNumber(),
                visible && g != null ? g.getScore() : null,
                s.getAssignment().getMaxScore(),
                visible && g != null ? g.getFeedback() : null,
                state, s.getSubmittedAt(), g != null ? g.getPublishedAt() : null);
    }

    private ResultRow quizRow(QuizAttempt a, boolean includeHidden) {
        String state;
        if ("PUBLISHED".equals(a.getResultStatus())) state = PUBLISHED;
        else if ("SCORED".equals(a.getStatus())) state = READY;
        else state = NOT_GRADED;
        boolean visible = includeHidden || PUBLISHED.equals(state);
        return new ResultRow("QUIZ", a.getQuiz().getQuizId(), a.getAttemptId(),
                a.getQuiz().getTitle(), a.getStudent().getFullName(), a.getAttemptNumber(),
                visible ? a.getScore() : null, a.getMaxScore(), null,
                state, a.getSubmittedAt(), a.getPublishedAt());
    }
}
