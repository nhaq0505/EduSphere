package com.edusphere.service.course;

import com.edusphere.dto.course.CertificateView;
import com.edusphere.entity.account.Users;
import com.edusphere.entity.course.Certificate;
import com.edusphere.entity.course.Course;
import com.edusphere.entity.course.Enrollment;
import com.edusphere.entity.course.Lesson;
import com.edusphere.entity.course.Quiz;
import com.edusphere.entity.course.QuizAttempt;
import com.edusphere.repository.account.UserRepository;
import com.edusphere.repository.course.CertificateRepository;
import com.edusphere.repository.course.CourseCommentRepository;
import com.edusphere.repository.course.CourseRepository;
import com.edusphere.repository.course.EnrollmentRepository;
import com.edusphere.repository.course.LessonCompletionRepository;
import com.edusphere.repository.course.LessonRepository;
import com.edusphere.repository.course.QuizAttemptRepository;
import com.edusphere.repository.course.QuizRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Optional;
import java.util.Set;
import java.util.UUID;

@Service
public class CertificateService {

    private static final String PUBLISHED = "PUBLISHED";
    private static final String VALID = "VALID";

    private final CertificateRepository certificateRepository;
    private final EnrollmentRepository enrollmentRepository;
    private final CourseRepository courseRepository;
    private final LessonRepository lessonRepository;
    private final LessonCompletionRepository lessonCompletionRepository;
    private final QuizRepository quizRepository;
    private final QuizAttemptRepository quizAttemptRepository;
    private final UserRepository userRepository;
    private final LearningProgressService learningProgressService;
    private final CourseCommentRepository courseCommentRepository;

    @Autowired
    public CertificateService(CertificateRepository certificateRepository,
                              EnrollmentRepository enrollmentRepository,
                              CourseRepository courseRepository,
                              LessonRepository lessonRepository,
                              LessonCompletionRepository lessonCompletionRepository,
                              QuizRepository quizRepository,
                              QuizAttemptRepository quizAttemptRepository,
                              UserRepository userRepository,
                              LearningProgressService learningProgressService,
                              CourseCommentRepository courseCommentRepository) {
        this.certificateRepository = certificateRepository;
        this.enrollmentRepository = enrollmentRepository;
        this.courseRepository = courseRepository;
        this.lessonRepository = lessonRepository;
        this.lessonCompletionRepository = lessonCompletionRepository;
        this.quizRepository = quizRepository;
        this.quizAttemptRepository = quizAttemptRepository;
        this.userRepository = userRepository;
        this.learningProgressService = learningProgressService;
        this.courseCommentRepository = courseCommentRepository;
    }

    /**
     * Kiểm tra điều kiện hoàn thành khóa học và tự động cấp chứng chỉ + tín chỉ nếu đủ điều kiện.
     */
    @Transactional
    public Optional<Certificate> issueCertificateIfEligible(Integer studentId, Integer courseId) {
        if (studentId == null || courseId == null) {
            return Optional.empty();
        }

        Optional<Enrollment> optEnrollment = enrollmentRepository.findByStudent_UserIdAndCourse_CourseId(studentId, courseId);
        if (optEnrollment.isEmpty()) {
            return Optional.empty();
        }
        Enrollment enrollment = optEnrollment.get();
        if ("DROPPED".equalsIgnoreCase(enrollment.getStatus())) {
            return Optional.empty();
        }

        List<Lesson> publishedLessons = lessonRepository.findByCourse_CourseIdAndStatusOrderByOrderIndexAsc(courseId, PUBLISHED);
        long totalLessons = publishedLessons.size();
        long completedLessons = lessonCompletionRepository.countByStudent_UserIdAndCourse_CourseId(studentId, courseId);

        boolean allLessonsDone = totalLessons > 0 && completedLessons >= totalLessons;
        boolean alreadyMarkedCompleted = "COMPLETED".equalsIgnoreCase(enrollment.getStatus());

        if (!allLessonsDone && !alreadyMarkedCompleted) {
            return Optional.empty();
        }

        // Nếu đã hoàn thành hết bài học nhưng trạng thái Enrollment chưa là COMPLETED thì cập nhật ngay
        if (!alreadyMarkedCompleted) {
            enrollment.setStatus("COMPLETED");
            enrollment.setCompletedAt(LocalDateTime.now());
            enrollmentRepository.save(enrollment);
            if (learningProgressService != null) {
                try {
                    learningProgressService.recordActivity(
                            enrollment.getStudent(),
                            enrollment.getCourse(),
                            "COURSE_COMPLETED",
                            null, null, null,
                            "Đã hoàn thành 100% các bài học trong khóa học!"
                    );
                } catch (Exception ignored) {
                }
            }
        }

        // Kiểm tra chứng chỉ đã tồn tại chưa
        Optional<Certificate> existingOpt = certificateRepository.findByStudent_UserIdAndCourse_CourseId(studentId, courseId);
        if (existingOpt.isPresent()) {
            Certificate existing = existingOpt.get();
            boolean updated = false;
            if (!VALID.equalsIgnoreCase(existing.getStatus())) {
                existing.setStatus(VALID);
                updated = true;
            }
            Course course = enrollment.getCourse();
            int expectedCredits = (course.getCredits() != null && course.getCredits() > 0) ? course.getCredits() : 3;
            if (existing.getCreditsEarned() == null || existing.getCreditsEarned() <= 0) {
                existing.setCreditsEarned(expectedCredits);
                updated = true;
            }
            if (existing.getGradePercent() == null || existing.getGradePercent() <= 0) {
                existing.setGradePercent(calculateGradePercent(studentId, courseId));
                updated = true;
            }
            if (existing.getTotalHours() == null || existing.getTotalHours() <= 0) {
                existing.setTotalHours(calculateTotalHours(course, publishedLessons, expectedCredits));
                updated = true;
            }
            if (updated) {
                existing = certificateRepository.save(existing);
            }
            return Optional.of(existing);
        }

        Course course = enrollment.getCourse();
        Users student = enrollment.getStudent() != null
                ? enrollment.getStudent()
                : userRepository.findById(studentId).orElse(null);
        if (student == null || course == null) {
            return Optional.empty();
        }

        int credits = (course.getCredits() != null && course.getCredits() > 0) ? course.getCredits() : 3;
        int gradePercent = calculateGradePercent(studentId, courseId);
        int totalHours = calculateTotalHours(course, publishedLessons, credits);

        Certificate cert = new Certificate();
        cert.setStudent(student);
        cert.setCourse(course);
        cert.setCreditsEarned(credits);
        cert.setGradePercent(gradePercent);
        cert.setTotalHours(totalHours);
        cert.setStatus(VALID);
        cert.setIssuedAt(enrollment.getCompletedAt() != null ? enrollment.getCompletedAt() : LocalDateTime.now());
        cert.setVerificationCode(generateUniqueVerificationCode());

        Certificate saved = certificateRepository.save(cert);

        if (learningProgressService != null) {
            try {
                learningProgressService.recordActivity(
                        student,
                        course,
                        "CERTIFICATE_EARNED",
                        null, null, null,
                        "Nhận chứng chỉ & " + credits + " tín chỉ khóa học: " + course.getTitle()
                );
            } catch (Exception ignored) {
            }
        }

        return Optional.of(saved);
    }

    /**
     * Học viên bấm nút nhận chứng chỉ / xem chứng chỉ của khóa học.
     */
    @Transactional
    public CertificateView claimOrGetCertificate(Integer studentId, Integer courseId) {
        Optional<Certificate> certOpt = issueCertificateIfEligible(studentId, courseId);
        if (certOpt.isEmpty()) {
            throw new CourseActionException(HttpStatus.BAD_REQUEST,
                    "Bạn cần hoàn thành 100% bài học trong khóa học trước khi nhận chứng chỉ và tín chỉ.");
        }
        return toView(certOpt.get());
    }

    /**
     * Đồng bộ tất cả các khóa học đã hoàn thành của học viên và trả về danh sách chứng chỉ.
     */
    @Transactional
    public List<CertificateView> syncAndGetMyCertificates(Integer studentId) {
        if (studentId == null) {
            return List.of();
        }
        List<Enrollment> enrollments = enrollmentRepository.findByStudent_UserIdOrderByEnrolledAtDesc(studentId);
        for (Enrollment enrollment : enrollments) {
            if (enrollment.getCourse() != null && !"DROPPED".equalsIgnoreCase(enrollment.getStatus())) {
                try {
                    issueCertificateIfEligible(studentId, enrollment.getCourse().getCourseId());
                } catch (Exception ignored) {
                }
            }
        }
        return certificateRepository.findByStudent_UserIdAndStatusOrderByIssuedAtDesc(studentId, VALID)
                .stream()
                .map(this::toView)
                .toList();
    }

    @Transactional(readOnly = true)
    public Optional<Certificate> findExistingCertificate(Integer studentId, Integer courseId) {
        if (studentId == null || courseId == null) {
            return Optional.empty();
        }
        return certificateRepository.findByStudent_UserIdAndCourse_CourseId(studentId, courseId)
                .filter(c -> VALID.equalsIgnoreCase(c.getStatus()));
    }

    @Transactional(readOnly = true)
    public CertificateView getCertificateById(Integer certificateId) {
        Certificate cert = certificateRepository.findById(certificateId)
                .filter(c -> VALID.equalsIgnoreCase(c.getStatus()))
                .orElseThrow(() -> new CourseActionException(HttpStatus.NOT_FOUND, "Không tìm thấy chứng chỉ hoặc chứng chỉ đã bị thu hồi."));
        return toView(cert);
    }

    @Transactional(readOnly = true)
    public CertificateView getCertificateByVerificationCode(String verificationCode) {
        if (verificationCode == null || verificationCode.isBlank()) {
            throw new CourseActionException(HttpStatus.NOT_FOUND, "Mã xác thực chứng chỉ không hợp lệ.");
        }
        Certificate cert = certificateRepository.findByVerificationCode(verificationCode.trim())
                .filter(c -> VALID.equalsIgnoreCase(c.getStatus()))
                .orElseThrow(() -> new CourseActionException(HttpStatus.NOT_FOUND, "Không tìm thấy chứng chỉ với mã xác thực: " + verificationCode));
        return toView(cert);
    }

    private CertificateView toView(Certificate cert) {
        Course course = cert.getCourse();
        Users student = cert.getStudent();
        Users instructor = course.getInstructor();
        String categoryName = course.getCategory() != null ? course.getCategory().getName() : "Chuyên ngành";
        int lessonCount = (int) lessonRepository.countByCourse_CourseIdAndStatus(course.getCourseId(), PUBLISHED);

        int activeCount = enrollmentRepository.findByCourse_CourseIdAndStatus(course.getCourseId(), "ACTIVE").size();
        int completedCount = enrollmentRepository.findByCourse_CourseIdAndStatus(course.getCourseId(), "COMPLETED").size();
        long enrolledCount = Math.max(1, activeCount + completedCount);

        Double avgRating = courseCommentRepository != null
                ? courseCommentRepository.findAverageRatingByCourseId(course.getCourseId())
                : null;
        long ratingCount = courseCommentRepository != null
                ? courseCommentRepository.countRatingsByCourseId(course.getCourseId())
                : 0L;
        double finalAvgRating = avgRating != null && avgRating > 0 ? Math.round(avgRating * 10.0) / 10.0 : 4.8;
        int finalRatingCount = ratingCount > 0 ? (int) ratingCount : Math.max(1, (int) enrolledCount);

        return CertificateView.builder()
                .certificateId(cert.getCertificateId())
                .verificationCode(cert.getVerificationCode())
                .issuedAt(cert.getIssuedAt())
                .creditsEarned(cert.getCreditsEarned() != null ? cert.getCreditsEarned() : 3)
                .gradePercent(cert.getGradePercent() != null ? cert.getGradePercent() : 100)
                .totalHours(cert.getTotalHours() != null ? cert.getTotalHours() : 18)
                .status(cert.getStatus())
                .studentId(student.getUserId())
                .studentName(student.getFullName())
                .studentEmail(student.getEmail())
                .studentAvatarUrl(student.getAvatarUrl())
                .courseId(course.getCourseId())
                .courseTitle(course.getTitle())
                .courseDescription(course.getDescription())
                .courseThumbnailUrl(course.getThumbnailUrl())
                .categoryName(categoryName)
                .levelLabel(levelLabel(course.getLevel()))
                .instructorName(instructor != null ? instructor.getFullName() : "EduSphere Instructor")
                .instructorTitle("Giảng viên Hướng dẫn & Chuyên gia Đào tạo")
                .lessonCount(lessonCount)
                .enrolledCount(enrolledCount)
                .averageRating(finalAvgRating)
                .ratingCount(finalRatingCount)
                .objectivesList(extractObjectives(course))
                .skillsList(extractSkills(course, categoryName))
                .build();
    }

    private int calculateGradePercent(Integer studentId, Integer courseId) {
        if (quizRepository == null || quizAttemptRepository == null) {
            return 100;
        }
        List<Quiz> quizzes = quizRepository.findByCourse_CourseIdAndStatus(courseId, PUBLISHED);
        if (quizzes == null || quizzes.isEmpty()) {
            return 100;
        }
        double sumPct = 0.0;
        int counted = 0;
        for (Quiz quiz : quizzes) {
            List<QuizAttempt> attempts = quizAttemptRepository
                    .findByQuiz_QuizIdAndStudent_UserIdOrderByAttemptNumberDesc(quiz.getQuizId(), studentId);
            double bestPct = -1;
            for (QuizAttempt att : attempts) {
                if (("SCORED".equalsIgnoreCase(att.getStatus()) || "SUBMITTED".equalsIgnoreCase(att.getStatus()))
                        && att.getScore() != null && att.getMaxScore() != null
                        && att.getMaxScore().compareTo(BigDecimal.ZERO) > 0) {
                    double pct = att.getScore().doubleValue() * 100.0 / att.getMaxScore().doubleValue();
                    if (pct > bestPct) {
                        bestPct = pct;
                    }
                }
            }
            if (bestPct >= 0) {
                sumPct += bestPct;
                counted++;
            }
        }
        if (counted == 0) {
            return 100;
        }
        return Math.min(100, Math.max(80, (int) Math.round(sumPct / counted)));
    }

    private int calculateTotalHours(Course course, List<Lesson> publishedLessons, int credits) {
        int totalSeconds = 0;
        if (publishedLessons != null) {
            for (Lesson l : publishedLessons) {
                if (l.getVideoDuration() != null && l.getVideoDuration() > 0) {
                    int sec = l.getVideoDuration() > 60 ? l.getVideoDuration() : l.getVideoDuration() * 60;
                    totalSeconds += sec;
                }
            }
        }
        int fromVideoHours = (int) Math.ceil(totalSeconds / 3600.0);
        int creditBasedHours = Math.max(6, credits * 6);
        return Math.max(fromVideoHours, creditBasedHours);
    }

    private List<String> extractObjectives(Course course) {
        List<String> list = new ArrayList<>();
        if (course.getObjectives() != null && !course.getObjectives().isBlank()) {
            String[] lines = course.getObjectives().split("[\\r\\n;•]+");
            for (String line : lines) {
                String cleaned = line.replaceAll("^[-*✓✔\\d.\\s]+", "").trim();
                if (!cleaned.isEmpty()) {
                    list.add(cleaned);
                }
            }
        }
        if (list.isEmpty()) {
            String title = course.getTitle() != null ? course.getTitle() : "khóa học";
            list.add("Nắm vững kiến thức nền tảng và cốt lõi của " + title);
            list.add("Vận dụng kỹ năng thực hành vào bài tập và dự án thực tế");
            list.add("Phân tích, đánh giá và giải quyết bài toán chuyên môn một cách hệ thống");
            list.add("Hoàn thành đầy đủ chuẩn đầu ra học phần tích lũy tín chỉ EduSphere");
        }
        return list;
    }

    private List<String> extractSkills(Course course, String categoryName) {
        Set<String> skills = new LinkedHashSet<>();
        if (categoryName != null && !categoryName.isBlank() && !"Chưa phân loại".equalsIgnoreCase(categoryName)) {
            skills.add(categoryName);
        }
        String title = course.getTitle() != null ? course.getTitle().toLowerCase() : "";
        if (title.contains("java") || title.contains("spring")) {
            skills.addAll(Arrays.asList("Java Programming", "Spring Boot", "Object-Oriented Programming", "Backend Development", "SQL & Database"));
        } else if (title.contains("web") || title.contains("html") || title.contains("react") || title.contains("frontend")) {
            skills.addAll(Arrays.asList("Web Development", "HTML5 & CSS3", "JavaScript", "Responsive Design", "UI/UX Basics"));
        } else if (title.contains("ux") || title.contains("ui") || title.contains("design")) {
            skills.addAll(Arrays.asList("UI/UX Research", "User Experience Design", "Prototyping", "Ideation", "Usability Testing", "Design Thinking"));
        } else if (title.contains("python") || title.contains("data") || title.contains("ai") || title.contains("machine")) {
            skills.addAll(Arrays.asList("Python", "Data Analysis", "Problem Solving", "Algorithms", "Statistical Thinking"));
        } else if (title.contains("sql") || title.contains("database") || title.contains("cơ sở dữ liệu")) {
            skills.addAll(Arrays.asList("SQL Server", "Database Design", "Query Optimization", "Data Modeling"));
        }
        skills.addAll(Arrays.asList("Critical Thinking", "Practical Application", "Self-Directed Learning", "Project Execution"));
        return new ArrayList<>(skills);
    }

    private String generateUniqueVerificationCode() {
        for (int i = 0; i < 10; i++) {
            String raw = UUID.randomUUID().toString().replace("-", "").toUpperCase();
            String code = raw.substring(0, 12);
            if (!certificateRepository.existsByVerificationCode(code)) {
                return code;
            }
        }
        return UUID.randomUUID().toString().replace("-", "").substring(0, 16).toUpperCase();
    }

    private String levelLabel(String level) {
        if (level == null) return "Mọi trình độ";
        return switch (level.toUpperCase()) {
            case "BEGINNER" -> "Cơ bản";
            case "INTERMEDIATE" -> "Trung cấp";
            case "ADVANCED" -> "Nâng cao";
            default -> "Mọi trình độ";
        };
    }
}
