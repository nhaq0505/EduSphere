package com.edusphere.service.course;

import com.edusphere.dto.assignment.AssignmentForm;
import com.edusphere.dto.assignment.AssignmentView;
import com.edusphere.dto.assignment.GradeForm;
import com.edusphere.dto.assignment.SubmissionForm;
import com.edusphere.entity.account.Users;
import com.edusphere.entity.course.Assignment;
import com.edusphere.entity.course.Course;
import com.edusphere.entity.course.Grade;
import com.edusphere.entity.course.Lesson;
import com.edusphere.entity.course.Submission;
import com.edusphere.repository.account.UserRepository;
import com.edusphere.repository.course.AssignmentRepository;
import com.edusphere.repository.course.CourseRepository;
import com.edusphere.repository.course.EnrollmentRepository;
import com.edusphere.repository.course.GradeRepository;
import com.edusphere.repository.course.LessonCompletionRepository;
import com.edusphere.repository.course.LessonRepository;
import com.edusphere.repository.course.SubmissionRepository;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class AssignmentService {

    private static final DateTimeFormatter DT_FMT = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm");

    private final AssignmentRepository assignments;
    private final SubmissionRepository submissions;
    private final GradeRepository grades;
    private final CourseRepository courses;
    private final LessonRepository lessons;
    private final EnrollmentRepository enrollments;
    private final UserRepository users;
    private final LearningProgressService learningProgressService;
    private final LessonCompletionRepository lessonCompletions;

    public AssignmentService(AssignmentRepository assignments, SubmissionRepository submissions,
                             GradeRepository grades, CourseRepository courses,
                             LessonRepository lessons, EnrollmentRepository enrollments,
                             UserRepository users) {
        this(assignments, submissions, grades, courses, lessons, enrollments, users, null);
    }

    @Autowired
    public AssignmentService(AssignmentRepository assignments, SubmissionRepository submissions,
                             GradeRepository grades, CourseRepository courses,
                             LessonRepository lessons, EnrollmentRepository enrollments,
                             UserRepository users,
                             LearningProgressService learningProgressService) {
        this.assignments = assignments;
        this.submissions = submissions;
        this.grades = grades;
        this.courses = courses;
        this.lessons = lessons;
        this.enrollments = enrollments;
        this.users = users;
        this.learningProgressService = learningProgressService;
        this.lessonCompletions = null;
    }

    // ===================== INSTRUCTOR OPERATIONS =====================

    @Transactional(readOnly = true)
    public List<AssignmentView> listForCourse(Integer courseId, Integer instructorId) {
        Course course = ownedCourse(courseId, instructorId);
        return assignments.findByCourse_CourseIdOrderByCreatedAtDesc(course.getCourseId())
                .stream().map(this::toView).toList();
    }

    @Transactional
    public Integer create(Integer courseId, Integer instructorId, AssignmentForm form) {
        Course course = ownedCourse(courseId, instructorId);
        Assignment a = new Assignment();
        a.setCourse(course);
        a.setCreatedBy(user(instructorId));
        applyForm(a, form);
        return assignments.save(a).getAssignmentId();
    }

    @Transactional
    public void update(Integer courseId, Integer assignmentId, Integer instructorId, AssignmentForm form) {
        Assignment a = ownedAssignment(courseId, assignmentId, instructorId);
        applyForm(a, form);
    }

    @Transactional
    public void publish(Integer courseId, Integer assignmentId, Integer instructorId) {
        Assignment a = ownedAssignment(courseId, assignmentId, instructorId);
        if (!"DRAFT".equals(a.getStatus()))
            throw conflict("Chỉ có thể công bố bài tập ở trạng thái Bản nháp.");
        a.setStatus("PUBLISHED");
        a.setUpdatedAt(LocalDateTime.now());
    }

    @Transactional
    public void archive(Integer courseId, Integer assignmentId, Integer instructorId) {
        Assignment a = ownedAssignment(courseId, assignmentId, instructorId);
        if (!"PUBLISHED".equals(a.getStatus()))
            throw conflict("Chỉ có thể lưu trữ bài tập đã công bố.");
        a.setStatus("ARCHIVED");
        a.setUpdatedAt(LocalDateTime.now());
    }

    @Transactional(readOnly = true)
    public List<Submission> listSubmissions(Integer courseId, Integer assignmentId, Integer instructorId) {
        ownedAssignment(courseId, assignmentId, instructorId);
        return submissions.findByAssignment_AssignmentIdOrderBySubmittedAtDesc(assignmentId);
    }

    @Transactional(readOnly = true)
    public Submission getSubmission(Integer courseId, Integer assignmentId, Integer submissionId, Integer instructorId) {
        ownedAssignment(courseId, assignmentId, instructorId);
        Submission sub = submissions.findById(submissionId)
                .orElseThrow(() -> notFound("Không tìm thấy bài nộp."));
        if (!sub.getAssignment().getAssignmentId().equals(assignmentId))
            throw notFound("Không tìm thấy bài nộp.");
        return sub;
    }

    @Transactional
    public void gradeSubmission(Integer courseId, Integer assignmentId, Integer submissionId,
                                Integer instructorId, GradeForm form) {
        Submission sub = getSubmission(courseId, assignmentId, submissionId, instructorId);
        Assignment assignment = sub.getAssignment();
        if (form.getScore().compareTo(assignment.getMaxScore()) > 0)
            throw conflict("Điểm chấm không được vượt quá điểm tối đa (" + assignment.getMaxScore() + ").");

        Grade grade = grades.findBySubmission_SubmissionId(submissionId).orElse(new Grade());
        grade.setSubmission(sub);
        grade.setScore(form.getScore());
        grade.setMaxScore(assignment.getMaxScore());
        grade.setFeedback(form.getFeedback());
        grade.setGradedBy(user(instructorId));
        grade.setGradedAt(LocalDateTime.now());
        if (grade.getResultStatus() == null) grade.setResultStatus("UNPUBLISHED");
        grades.save(grade);

        sub.setStatus("GRADED");
    }

    @Transactional
    public void publishGrade(Integer courseId, Integer assignmentId, Integer submissionId, Integer instructorId) {
        getSubmission(courseId, assignmentId, submissionId, instructorId);
        Grade grade = grades.findBySubmission_SubmissionId(submissionId)
                .orElseThrow(() -> conflict("Bài nộp chưa được chấm điểm."));
        if ("PUBLISHED".equals(grade.getResultStatus()))
            throw conflict("Kết quả đã được công bố.");
        grade.setResultStatus("PUBLISHED");
        grade.setPublishedBy(user(instructorId));
        grade.setPublishedAt(LocalDateTime.now());
    }

    @Transactional(readOnly = true)
    public Optional<Grade> getGradeForSubmission(Integer submissionId) {
        return grades.findBySubmission_SubmissionId(submissionId);
    }

    @Transactional(readOnly = true)
    public Assignment getAssignmentForInstructor(Integer courseId, Integer assignmentId, Integer instructorId) {
        return ownedAssignment(courseId, assignmentId, instructorId);
    }

    // ===================== STUDENT OPERATIONS =====================

    @Transactional(readOnly = true)
    public List<AssignmentView> listPublished(Integer courseId, Integer studentId) {
        verifyEnrolled(courseId, studentId);
        return assignments.findByCourse_CourseIdAndStatusOrderByDueDateAsc(courseId, "PUBLISHED")
                .stream().map(this::toView).toList();
    }

    @Transactional(readOnly = true)
    public Assignment getAssignmentForStudent(Integer courseId, Integer assignmentId, Integer studentId) {
        verifyEnrolled(courseId, studentId);
        Assignment a = assignments.findByAssignmentIdAndCourse_CourseId(assignmentId, courseId)
                .orElseThrow(() -> notFound("Không tìm thấy bài tập."));
        if (!"PUBLISHED".equals(a.getStatus()))
            throw notFound("Bài tập chưa được công bố.");
        return a;
    }

    @Transactional(readOnly = true)
    public List<Submission> getMySubmissions(Integer courseId, Integer assignmentId, Integer studentId) {
        getAssignmentForStudent(courseId, assignmentId, studentId);
        return submissions.findByAssignment_AssignmentIdAndStudent_UserId(assignmentId, studentId);
    }

    @Transactional
    public void submit(Integer courseId, Integer assignmentId, Integer studentId, SubmissionForm form) {
        Assignment a = getAssignmentForStudent(courseId, assignmentId, studentId);

        // Gate: nếu assignment gắn với lesson cụ thể, học viên phải hoàn thành lesson đó trước
        if (a.getLesson() != null && lessonCompletions != null) {
            boolean lessonDone = lessonCompletions.existsByStudent_UserIdAndLesson_LessonId(
                    studentId, a.getLesson().getLessonId());
            if (!lessonDone) {
                throw conflict("Bạn cần hoàn thành bài học «" + a.getLesson().getTitle()
                        + "» trước khi nộp bài tập này.");
            }
        }

        if (form.getAnswerText() == null || form.getAnswerText().isBlank()) {
            if (form.getFileUrl() == null || form.getFileUrl().isBlank())
                throw conflict("Bạn phải nhập nội dung trả lời hoặc URL file đính kèm.");
        }

        int attemptCount = submissions.countByAssignment_AssignmentIdAndStudent_UserId(assignmentId, studentId);
        if (attemptCount > 0 && !a.isAllowResubmit())
            throw conflict("Bài tập này không cho phép nộp lại.");
        if (attemptCount >= a.getMaxAttempts())
            throw conflict("Bạn đã đạt số lần nộp tối đa (" + a.getMaxAttempts() + ").");

        // Check lock/due
        LocalDateTime now = LocalDateTime.now();
        if (a.getLockAt() != null && now.isAfter(a.getLockAt()))
            throw conflict("Bài tập đã bị khóa, không thể nộp.");

        Users student = user(studentId);
        Submission sub = new Submission();
        sub.setAssignment(a);
        sub.setStudent(student);
        sub.setCourse(a.getCourse());
        sub.setAnswerText(form.getAnswerText());
        sub.setFileUrl(form.getFileUrl());
        sub.setAttemptNumber(attemptCount + 1);
        sub.setSubmittedAt(now);
        sub.setLate(a.getDueDate() != null && now.isAfter(a.getDueDate()));
        sub.setStatus("SUBMITTED");
        submissions.save(sub);

        // Ghi lại lịch sử hoạt động nộp bài tập (UC38)
        if (learningProgressService != null) {
            learningProgressService.recordActivity(student, a.getCourse(),
                    "ASSIGNMENT_SUBMITTED", a.getLesson(), a, null, "Đã nộp bài tập: " + a.getTitle());
        }
    }

    @Transactional(readOnly = true)
    public Optional<Grade> getMyGrade(Integer courseId, Integer assignmentId, Integer studentId) {
        verifyEnrolled(courseId, studentId);
        Optional<Submission> latestSub = submissions
                .findTopByAssignment_AssignmentIdAndStudent_UserIdOrderByAttemptNumberDesc(assignmentId, studentId);
        if (latestSub.isEmpty()) return Optional.empty();
        return grades.findBySubmission_SubmissionId(latestSub.get().getSubmissionId())
                .filter(g -> "PUBLISHED".equals(g.getResultStatus()));
    }

    // ===================== HELPERS =====================

    private void applyForm(Assignment a, AssignmentForm form) {
        a.setTitle(form.getTitle().trim());
        a.setDescription(form.getDescription());
        a.setMaxScore(form.getMaxScore());
        a.setAllowResubmit(form.isAllowResubmit());
        a.setMaxAttempts(form.getMaxAttempts() != null ? form.getMaxAttempts() : 1);
        a.setDueDate(parseDateTime(form.getDueDate()));
        a.setUnlockAt(parseDateTime(form.getUnlockAt()));
        a.setLockAt(parseDateTime(form.getLockAt()));
        if (form.getLessonId() != null) {
            Lesson lesson = lessons.findById(form.getLessonId())
                    .orElseThrow(() -> conflict("Bài học không tồn tại."));
            a.setLesson(lesson);
        } else {
            a.setLesson(null);
        }
    }

    private LocalDateTime parseDateTime(String value) {
        if (value == null || value.isBlank()) return null;
        try {
            return LocalDateTime.parse(value, DT_FMT);
        } catch (Exception e) {
            return null;
        }
    }

    private Course ownedCourse(Integer courseId, Integer instructorId) {
        Course course = courses.findById(courseId)
                .orElseThrow(() -> notFound("Không tìm thấy khóa học."));
        if (!course.getInstructor().getUserId().equals(instructorId))
            throw notFound("Không tìm thấy khóa học của bạn.");
        return course;
    }

    private Assignment ownedAssignment(Integer courseId, Integer assignmentId, Integer instructorId) {
        ownedCourse(courseId, instructorId);
        return assignments.findByAssignmentIdAndCourse_CourseId(assignmentId, courseId)
                .orElseThrow(() -> notFound("Không tìm thấy bài tập."));
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

    private AssignmentView toView(Assignment a) {
        long count = submissions.findByAssignment_AssignmentIdOrderBySubmittedAtDesc(a.getAssignmentId()).size();
        String lessonTitle = a.getLesson() != null ? a.getLesson().getTitle() : null;
        Integer lessonId = a.getLesson() != null ? a.getLesson().getLessonId() : null;
        return new AssignmentView(a.getAssignmentId(), a.getTitle(), a.getDescription(),
                a.getDueDate(), a.getMaxScore(), a.getStatus(), count, lessonTitle,
                a.isAllowResubmit(), a.getMaxAttempts(), a.getUnlockAt(), a.getLockAt(),
                lessonId, false, 0);
    }

    private CourseActionException notFound(String msg) {
        return new CourseActionException(HttpStatus.NOT_FOUND, msg);
    }

    private CourseActionException conflict(String msg) {
        return new CourseActionException(HttpStatus.CONFLICT, msg);
    }
}
