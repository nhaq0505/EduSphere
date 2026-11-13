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

import javax.imageio.ImageIO;
import java.awt.BasicStroke;
import java.awt.Color;
import java.awt.Font;
import java.awt.FontMetrics;
import java.awt.GradientPaint;
import java.awt.Graphics2D;
import java.awt.Polygon;
import java.awt.RenderingHints;
import java.awt.geom.Ellipse2D;
import java.awt.image.BufferedImage;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
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
            list.add("Hoàn thành đầy đủ chuẩn đầu ra khóa học trên hệ thống EduSphere");
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

    /**
     * Render chứng chỉ hoàn thành khóa học thành file ảnh PNG độ phân giải cao (1800 x 1260 px)
     * để học viên tải trực tiếp về máy từ Kho chứng chỉ hoặc trang chi tiết chứng chỉ.
     */
    public byte[] renderCertificatePng(CertificateView cert, String verifyBaseUrl) {
        final int width = 1800;
        final int height = 1260;

        BufferedImage image = new BufferedImage(width, height, BufferedImage.TYPE_INT_RGB);
        Graphics2D g = image.createGraphics();
        try {
            g.setRenderingHint(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON);
            g.setRenderingHint(RenderingHints.KEY_TEXT_ANTIALIASING, RenderingHints.VALUE_TEXT_ANTIALIAS_LCD_HRGB);
            g.setRenderingHint(RenderingHints.KEY_RENDERING, RenderingHints.VALUE_RENDER_QUALITY);
            g.setRenderingHint(RenderingHints.KEY_FRACTIONALMETRICS, RenderingHints.VALUE_FRACTIONALMETRICS_ON);

            // 1. Nền ngoài & Khung viền kép trang trọng
            g.setColor(Color.WHITE);
            g.fillRect(0, 0, width, height);

            g.setColor(new Color(0xFF, 0xFD, 0xF9));
            g.fillRect(42, 42, width - 84, height - 84);

            // Họa tiết nền nhẹ bên phải
            g.setColor(new Color(219, 234, 254, 70));
            g.fill(new Ellipse2D.Double(980, 180, 680, 680));

            // Viền ngoài (#9ca3af) & Viền trong (#cbd5e1)
            g.setColor(new Color(0x9C, 0xA3, 0xAF));
            g.setStroke(new BasicStroke(6f));
            g.drawRect(24, 24, width - 48, height - 48);

            g.setColor(new Color(0xCB, 0xD5, 0xE1));
            g.setStroke(new BasicStroke(3f));
            g.drawRect(42, 42, width - 84, height - 84);

            // Viền chỉ vàng trang trí góc trong
            g.setColor(new Color(0xE2, 0xE8, 0xF0));
            g.setStroke(new BasicStroke(1.5f));
            g.drawRect(56, 56, width - 112, height - 112);

            // 2. Dải ruy-băng dọc bên phải (Ribbon) + Con dấu tròn (Seal)
            int ribX = 1320;
            int ribY = 44;
            int ribW = 280;
            int ribH = 820;
            Polygon ribbonPoly = new Polygon(
                    new int[]{ribX, ribX + ribW, ribX + ribW, ribX + ribW / 2, ribX},
                    new int[]{ribY, ribY, ribY + ribH, ribY + ribH - 105, ribY + ribH},
                    5
            );
            GradientPaint ribGrad = new GradientPaint(
                    ribX, ribY, new Color(0xE5, 0xE7, 0xEB),
                    ribX, ribY + ribH, new Color(0xF3, 0xF4, 0xF6)
            );
            g.setPaint(ribGrad);
            g.fillPolygon(ribbonPoly);

            g.setColor(new Color(0xD1, 0xD5, 0xDB));
            g.setStroke(new BasicStroke(2f));
            g.drawPolygon(ribbonPoly);

            // Chữ COURSE CERTIFICATE trên Ribbon
            g.setColor(new Color(0x37, 0x41, 0x51));
            g.setFont(new Font(Font.SANS_SERIF, Font.BOLD, 24));
            drawCenteredString(g, "COURSE", ribX + ribW / 2, ribY + 96);
            drawCenteredString(g, "CERTIFICATE", ribX + ribW / 2, ribY + 132);

            // Con dấu tròn (Circular Seal)
            int sealR = 112;
            int sealCx = ribX + ribW / 2;
            int sealCy = ribY + 320;
            g.setColor(Color.WHITE);
            g.fillOval(sealCx - sealR, sealCy - sealR, sealR * 2, sealR * 2);

            g.setColor(new Color(0x37, 0x41, 0x51));
            g.setStroke(new BasicStroke(4f));
            g.drawOval(sealCx - sealR, sealCy - sealR, sealR * 2, sealR * 2);

            g.setColor(new Color(0x6B, 0x72, 0x80));
            g.setStroke(new BasicStroke(1.8f));
            g.drawOval(sealCx - sealR + 10, sealCy - sealR + 10, (sealR - 10) * 2, (sealR - 10) * 2);

            g.setColor(new Color(0x4B, 0x55, 0x63));
            g.setFont(new Font(Font.SANS_SERIF, Font.BOLD, 11));
            drawCenteredString(g, "EDUCATION FOR EVERYONE", sealCx, sealCy - 36);

            g.setColor(new Color(0x9C, 0xA3, 0xAF));
            g.setStroke(new BasicStroke(1.5f));
            g.drawLine(sealCx - 78, sealCy - 20, sealCx + 78, sealCy - 20);
            g.drawLine(sealCx - 78, sealCy + 22, sealCx + 78, sealCy + 22);

            g.setColor(new Color(0x0F, 0x7D, 0xD8));
            g.setFont(new Font(Font.SANS_SERIF, Font.BOLD, 28));
            drawCenteredString(g, "EduSphere", sealCx, sealCy + 10);

            g.setColor(new Color(0x4B, 0x55, 0x63));
            g.setFont(new Font(Font.SANS_SERIF, Font.BOLD, 11));
            drawCenteredString(g, "COURSE CERTIFICATE", sealCx, sealCy + 44);

            // 3. Nội dung chính bên trái (65% chiều ngang)
            int leftX = 115;
            int maxContentW = 1130;

            // Thương hiệu EduSphere đồng bộ với Logo website (#E8F4FD nền + mũ tốt nghiệp + chữ #0F7DD8)
            g.setColor(new Color(0xE8, 0xF4, 0xFD));
            g.fillRoundRect(leftX, 115, 76, 76, 18, 18);
            g.setColor(new Color(0xCF, 0xE8, 0xFC));
            g.setStroke(new BasicStroke(2f));
            g.drawRoundRect(leftX, 115, 76, 76, 18, 18);

            // Vẽ biểu tượng mũ tốt nghiệp (🎓) bên trong ô logo
            int capCx = leftX + 38;
            int capCy = 150;
            Polygon capTop = new Polygon(
                    new int[]{capCx, capCx + 24, capCx, capCx - 24},
                    new int[]{capCy - 14, capCy - 3, capCy + 8, capCy - 3},
                    4
            );
            g.setColor(new Color(0x1E, 0x29, 0x3B));
            g.fillPolygon(capTop);
            Polygon capBase = new Polygon(
                    new int[]{capCx - 13, capCx + 13, capCx + 11, capCx, capCx - 11},
                    new int[]{capCy + 4, capCy + 4, capCy + 16, capCy + 20, capCy + 16},
                    5
            );
            g.setColor(new Color(0x33, 0x41, 0x55));
            g.fillPolygon(capBase);
            g.setColor(new Color(0xF5, 0x9E, 0x0B));
            g.setStroke(new BasicStroke(2.5f));
            g.drawLine(capCx + 18, capCy, capCx + 18, capCy + 15);
            g.fillOval(capCx + 15, capCy + 14, 6, 6);

            g.setColor(new Color(0x0F, 0x7D, 0xD8));
            g.setFont(new Font(Font.SANS_SERIF, Font.BOLD, 34));
            g.drawString("EduSphere", leftX + 96, 150);

            String catUpper = (cert.getCategoryName() != null ? cert.getCategoryName() : "CHUYÊN NGÀNH").toUpperCase();
            g.setColor(new Color(0x64, 0x74, 0x8B));
            g.setFont(new Font(Font.SANS_SERIF, Font.BOLD, 17));
            g.drawString(catUpper + " • ONLINE EDUCATION PLATFORM", leftX + 96, 178);

            // Ngày cấp
            g.setColor(new Color(0x6B, 0x72, 0x80));
            g.setFont(new Font(Font.SERIF, Font.ITALIC, 22));
            g.drawString("Issued on " + cert.getFormattedIssuedDateEn() + " (" + cert.getFormattedIssuedDateVi() + ")", leftX, 275);

            // Tên học viên
            String studentName = cert.getStudentName() != null && !cert.getStudentName().isBlank()
                    ? cert.getStudentName()
                    : "Học viên EduSphere";
            int nameFontSize = 58;
            Font nameFont = new Font(Font.SERIF, Font.BOLD, nameFontSize);
            while (nameFontSize > 34 && g.getFontMetrics(nameFont).stringWidth(studentName) > maxContentW) {
                nameFontSize -= 2;
                nameFont = new Font(Font.SERIF, Font.BOLD, nameFontSize);
            }
            g.setColor(new Color(0x1F, 0x29, 0x37));
            g.setFont(nameFont);
            g.drawString(studentName, leftX, 355);

            // Đường gạch trang trí dưới tên học viên
            g.setColor(new Color(0x00, 0x56, 0xD2));
            g.setStroke(new BasicStroke(3f));
            g.drawLine(leftX, 378, leftX + 180, 378);

            // Dòng xác nhận hoàn thành
            g.setColor(new Color(0x6B, 0x72, 0x80));
            g.setFont(new Font(Font.SERIF, Font.ITALIC, 24));
            g.drawString("has successfully completed the online course", leftX, 428);

            // Tên khóa học (tự động xuống dòng nếu dài)
            String courseTitle = cert.getCourseTitle() != null ? cert.getCourseTitle() : "Khóa học EduSphere";
            Font titleFont = new Font(Font.SERIF, Font.BOLD, 40);
            g.setFont(titleFont);
            g.setColor(new Color(0x11, 0x18, 0x27));
            List<String> titleLines = wrapText(courseTitle, g.getFontMetrics(titleFont), maxContentW, 3);
            int curY = 492;
            for (String line : titleLines) {
                g.drawString(line, leftX, curY);
                curY += 52;
            }

            // Đoạn mô tả chuẩn đầu ra & thông tin khóa học
            curY += 10;
            g.setColor(new Color(0x4B, 0x55, 0x63));
            g.setFont(new Font(Font.SANS_SERIF, Font.PLAIN, 21));
            String authText = "an online course (" + cert.getTotalHours() + " Hours • Grade Achieved: "
                    + cert.getGradePercent() + "%) authorized by EduSphere Academy and offered through EduSphere E-Learning Platform.";
            for (String line : wrapText(authText, g.getFontMetrics(), maxContentW, 3)) {
                g.drawString(line, leftX, curY);
                curY += 32;
            }

            // 4. Chữ ký giảng viên & Khu vực xác thực bên dưới
            int sigBaseY = 1015;
            String instructorName = cert.getInstructorName() != null ? cert.getInstructorName() : "EduSphere Instructor";

            g.setColor(new Color(0x1E, 0x29, 0x3B));
            g.setFont(new Font(Font.SERIF, Font.BOLD | Font.ITALIC, 38));
            g.drawString(instructorName, leftX + 6, sigBaseY - 18);

            g.setColor(new Color(0x37, 0x41, 0x51));
            g.setStroke(new BasicStroke(2f));
            g.drawLine(leftX, sigBaseY, leftX + 430, sigBaseY);

            g.setColor(new Color(0x1F, 0x29, 0x37));
            g.setFont(new Font(Font.SANS_SERIF, Font.BOLD, 21));
            g.drawString(instructorName, leftX, sigBaseY + 32);

            g.setColor(new Color(0x6B, 0x72, 0x80));
            g.setFont(new Font(Font.SANS_SERIF, Font.PLAIN, 18));
            g.drawString(cert.getInstructorTitle() != null ? cert.getInstructorTitle() : "Giảng viên Hướng dẫn", leftX, sigBaseY + 60);
            g.drawString("Faculty of " + (cert.getCategoryName() != null ? cert.getCategoryName() : "EduSphere") + ", EduSphere Academy", leftX, sigBaseY + 86);

            // Khu vực Verify bên phải dưới
            int rightEdgeX = width - 115;
            String baseUrl = (verifyBaseUrl != null && !verifyBaseUrl.isBlank()) ? verifyBaseUrl : "https://edusphere.vn";
            String verifyUrl = baseUrl + "/certificates/verify/" + cert.getVerificationCode();

            g.setColor(new Color(0x4B, 0x55, 0x63));
            g.setFont(new Font(Font.SANS_SERIF, Font.BOLD, 18));
            drawRightAlignedString(g, "Verify at / Xác thực chứng chỉ tại:", rightEdgeX, sigBaseY - 8);

            g.setColor(new Color(0x00, 0x56, 0xD2));
            g.setFont(new Font(Font.SANS_SERIF, Font.BOLD, 18));
            drawRightAlignedString(g, verifyUrl, rightEdgeX, sigBaseY + 20);

            g.setColor(new Color(0x11, 0x18, 0x27));
            g.setFont(new Font(Font.SANS_SERIF, Font.BOLD, 18));
            drawRightAlignedString(g, "Verification Code: " + cert.getVerificationCode(), rightEdgeX, sigBaseY + 48);

            g.setColor(new Color(0x6B, 0x72, 0x80));
            g.setFont(new Font(Font.SANS_SERIF, Font.PLAIN, 16));
            drawRightAlignedString(g, "EduSphere has confirmed the identity of this individual and", rightEdgeX, sigBaseY + 74);
            drawRightAlignedString(g, "their participation in the course.", rightEdgeX, sigBaseY + 96);

            // Đường kẻ chân trang & Disclaimer
            g.setColor(new Color(0xE2, 0xE8, 0xF0));
            g.setStroke(new BasicStroke(1.5f));
            g.drawLine(leftX, 1148, rightEdgeX, 1148);

            g.setColor(new Color(0x9C, 0xA3, 0xAF));
            g.setFont(new Font(Font.SANS_SERIF, Font.PLAIN, 16));
            drawCenteredString(
                    g,
                    "This certificate attests to the learner's completion of an online course delivered via EduSphere Academy.",
                    width / 2,
                    1180
            );
        } finally {
            g.dispose();
        }

        try (ByteArrayOutputStream baos = new ByteArrayOutputStream()) {
            ImageIO.write(image, "png", baos);
            return baos.toByteArray();
        } catch (IOException ex) {
            throw new CourseActionException(HttpStatus.INTERNAL_SERVER_ERROR, "Không thể tạo file ảnh chứng chỉ.");
        }
    }

    private void drawCenteredString(Graphics2D g, String text, int centerX, int y) {
        FontMetrics fm = g.getFontMetrics();
        int x = centerX - fm.stringWidth(text) / 2;
        g.drawString(text, x, y);
    }

    private void drawRightAlignedString(Graphics2D g, String text, int rightX, int y) {
        FontMetrics fm = g.getFontMetrics();
        int x = rightX - fm.stringWidth(text);
        g.drawString(text, x, y);
    }

    private List<String> wrapText(String text, FontMetrics fm, int maxWidth, int maxLines) {
        List<String> lines = new ArrayList<>();
        if (text == null || text.isBlank()) {
            return lines;
        }
        String[] words = text.trim().split("\\s+");
        StringBuilder currentLine = new StringBuilder();
        for (String word : words) {
            String candidate = currentLine.isEmpty() ? word : currentLine + " " + word;
            if (fm.stringWidth(candidate) <= maxWidth) {
                currentLine.setLength(0);
                currentLine.append(candidate);
            } else {
                if (!currentLine.isEmpty()) {
                    lines.add(currentLine.toString());
                    if (lines.size() >= maxLines) {
                        return lines;
                    }
                }
                currentLine.setLength(0);
                currentLine.append(word);
            }
        }
        if (!currentLine.isEmpty() && lines.size() < maxLines) {
            lines.add(currentLine.toString());
        }
        return lines;
    }
}
