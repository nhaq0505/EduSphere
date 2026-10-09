package com.edusphere.service;

import com.edusphere.dto.CourseForm;
import com.edusphere.dto.EnrolledCourseView;
import com.edusphere.dto.ManagedCourseView;
import com.edusphere.entity.Category;
import com.edusphere.entity.Course;
import com.edusphere.entity.CourseReview;
import com.edusphere.entity.Enrollment;
import com.edusphere.entity.Users;
import com.edusphere.repository.CategoryRepository;
import com.edusphere.repository.CourseRepository;
import com.edusphere.repository.CourseReviewRepository;
import com.edusphere.repository.EnrollmentRepository;
import com.edusphere.repository.UserRepository;
import org.springframework.http.HttpStatus;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Set;

@Service
public class CourseManagementService {

    private static final Set<String> LEVELS = Set.of("ALL_LEVELS", "BEGINNER", "INTERMEDIATE", "ADVANCED");
    private final CourseRepository courses;
    private final CourseReviewRepository reviews;
    private final EnrollmentRepository enrollments;
    private final CategoryRepository categories;
    private final UserRepository users;
    private final JdbcTemplate jdbc;

    public CourseManagementService(CourseRepository courses, CourseReviewRepository reviews,
                                   EnrollmentRepository enrollments, CategoryRepository categories,
                                   UserRepository users, JdbcTemplate jdbc) {
        this.courses = courses;
        this.reviews = reviews;
        this.enrollments = enrollments;
        this.categories = categories;
        this.users = users;
        this.jdbc = jdbc;
    }

    @Transactional(readOnly = true)
    public List<ManagedCourseView> instructorCourses(Integer instructorId) {
        return courses.findByInstructor_UserIdOrderByCreatedAtDesc(instructorId).stream().map(this::view).toList();
    }

    @Transactional(readOnly = true)
    public ManagedCourseView instructorCourse(Integer id, Integer instructorId) {
        return view(ownedCourse(id, instructorId));
    }

    @Transactional(readOnly = true)
    public CourseForm editForm(Integer id, Integer instructorId) {
        Course course = ownedCourse(id, instructorId);
        if (!canEdit(course)) throw conflict("Khóa học đang được duyệt hoặc đã công bố, không thể chỉnh sửa.");
        CourseForm form = new CourseForm();
        form.setTitle(course.getTitle());
        form.setDescription(course.getDescription());
        form.setCategoryId(course.getCategory() == null ? null : course.getCategory().getCategoryId());
        form.setLevel(course.getLevel());
        form.setPrice(course.getPrice());
        return form;
    }

    @Transactional(readOnly = true)
    public List<Category> activeCategories() {
        return categories.findByStatusOrderByNameAsc("ACTIVE");
    }

    @Transactional
    public Integer create(Integer instructorId, CourseForm form) {
        Course course = new Course();
        course.setInstructor(user(instructorId));
        applyForm(course, form);
        return courses.save(course).getCourseId();
    }

    @Transactional
    public void edit(Integer id, Integer instructorId, CourseForm form) {
        Course course = lockedOwnedCourse(id, instructorId);
        if (!canEdit(course)) throw conflict("Khóa học đang được duyệt hoặc đã công bố, không thể chỉnh sửa.");
        applyForm(course, form);
        course.setVersionNo(course.getVersionNo() + 1);
        course.setStatus("DRAFT");
        course.setSubmittedAt(null);
        course.setApprovedAt(null);
        course.setUpdatedAt(LocalDateTime.now());
    }

    @Transactional
    public void submit(Integer id, Integer instructorId) {
        Course course = lockedOwnedCourse(id, instructorId);
        if (!canEdit(course)) throw conflict("Chỉ có thể gửi khóa học nháp hoặc bị từ chối.");
        if (course.getDescription() == null || course.getDescription().isBlank())
            throw conflict("Hãy thêm mô tả trước khi gửi duyệt.");
        course.setStatus("SUBMITTED");
        course.setSubmittedAt(LocalDateTime.now());
        course.setUpdatedAt(LocalDateTime.now());
    }

    @Transactional(readOnly = true)
    public List<ManagedCourseView> pendingCourses() {
        return courses.findByStatusOrderBySubmittedAtAsc("SUBMITTED").stream().map(this::view).toList();
    }

    @Transactional
    public void review(Integer id, Integer adminId, String decision, String comment) {
        Course course = lockedCourse(id);
        if (!"SUBMITTED".equals(course.getStatus())) throw conflict("Khóa học không ở trạng thái chờ duyệt.");
        if (!Set.of("APPROVED", "REJECTED").contains(decision)) throw conflict("Quyết định không hợp lệ.");
        String reason = comment == null ? "" : comment.trim();
        if ("REJECTED".equals(decision) && reason.isEmpty()) throw conflict("Cần nhập lý do từ chối.");
        if (reason.length() > 2000) throw conflict("Nhận xét tối đa 2000 ký tự.");
        CourseReview review = new CourseReview();
        review.setCourse(course);
        review.setCourseVersion(course.getVersionNo());
        review.setAdmin(user(adminId));
        review.setDecision(decision);
        review.setComment(reason.isEmpty() ? null : reason);
        reviews.save(review);
        course.setStatus(decision);
        course.setApprovedAt("APPROVED".equals(decision) ? LocalDateTime.now() : null);
        course.setUpdatedAt(LocalDateTime.now());
    }

    @Transactional
    public void publish(Integer id, Integer instructorId) {
        Course course = lockedOwnedCourse(id, instructorId);
        if (!"APPROVED".equals(course.getStatus()) || course.getApprovedAt() == null)
            throw conflict("Khóa học phải được quản trị viên phê duyệt trước khi công bố.");
        course.setStatus("PUBLISHED");
        course.setPublishedAt(LocalDateTime.now());
        course.setUpdatedAt(LocalDateTime.now());
    }

    @Transactional
    public void archive(Integer id, Integer instructorId) {
        Course course = lockedOwnedCourse(id, instructorId);
        if (!"PUBLISHED".equals(course.getStatus())) throw conflict("Chỉ có thể lưu trữ khóa học đã công bố.");
        course.setStatus("ARCHIVED");
        course.setArchivedAt(LocalDateTime.now());
        course.setUpdatedAt(LocalDateTime.now());
    }

    @Transactional
    public void enroll(Integer courseId, Integer studentId) {
        Course course = lockedCourse(courseId);
        if (!"PUBLISHED".equals(course.getStatus())) throw new CourseActionException(HttpStatus.NOT_FOUND, "Không tìm thấy khóa học công khai.");
        Enrollment existing = enrollments.findByStudent_UserIdAndCourse_CourseId(studentId, courseId).orElse(null);
        if (existing != null && !"DROPPED".equals(existing.getStatus())) throw conflict("Bạn đã ghi danh khóa học này.");

        Integer paymentId = null;
        if (course.getPrice().compareTo(BigDecimal.ZERO) > 0) {
            // UC45 xử lý thanh toán riêng. Ở đây chỉ chấp nhận quyền truy cập từ giao dịch đã thành công.
            List<Integer> payments = jdbc.queryForList(
                    "SELECT payment_id FROM dbo.payments WHERE student_id = ? AND course_id = ? " +
                    "AND status = 'SUCCEEDED' AND amount >= ? AND currency = ? ORDER BY completed_at DESC",
                    Integer.class, studentId, courseId, course.getPrice(), course.getCurrency());
            if (payments.isEmpty()) throw conflict("Khóa học có phí cần thanh toán thành công trước khi ghi danh.");
            paymentId = payments.get(0);
        }

        if (existing == null) {
            Enrollment enrollment = new Enrollment();
            enrollment.setStudent(user(studentId));
            enrollment.setCourse(course);
            enrollment.setPaymentId(paymentId);
            enrollments.save(enrollment);
        } else {
            existing.setStatus("ACTIVE");
            existing.setDroppedAt(null);
            existing.setEnrolledAt(LocalDateTime.now());
            existing.setPaymentId(paymentId);
        }
    }

    @Transactional(readOnly = true)
    public List<EnrolledCourseView> enrolledCourses(Integer studentId) {
        return enrollments.findByStudent_UserIdOrderByEnrolledAtDesc(studentId).stream()
                .map(e -> new EnrolledCourseView(e.getCourse().getCourseId(), e.getCourse().getTitle(),
                        e.getCourse().getInstructor().getFullName(), e.getStatus(), e.getCourse().getStatus()))
                .toList();
    }

    private void applyForm(Course course, CourseForm form) {
        String level = form.getLevel() == null ? "" : form.getLevel().trim();
        if (!LEVELS.contains(level)) throw conflict("Trình độ không hợp lệ.");
        if (form.getPrice() == null || form.getPrice().compareTo(BigDecimal.ZERO) < 0
                || form.getPrice().precision() > 18 || form.getPrice().scale() > 2)
            throw conflict("Học phí phải từ 0 trở lên và có tối đa 2 chữ số thập phân.");
        course.setTitle(form.getTitle().trim());
        course.setDescription(form.getDescription() == null ? null : form.getDescription().trim());
        course.setLevel(level);
        course.setPrice(form.getPrice());
        Category category = form.getCategoryId() == null ? null : categories.findById(form.getCategoryId())
                .filter(c -> "ACTIVE".equals(c.getStatus()))
                .orElseThrow(() -> conflict("Danh mục không hợp lệ."));
        course.setCategory(category);
    }

    private boolean canEdit(Course course) {
        return "DRAFT".equals(course.getStatus()) || "REJECTED".equals(course.getStatus());
    }

    private Course ownedCourse(Integer id, Integer instructorId) {
        Course course = course(id);
        if (!course.getInstructor().getUserId().equals(instructorId))
            throw new CourseActionException(HttpStatus.NOT_FOUND, "Không tìm thấy khóa học của bạn.");
        return course;
    }

    private Course lockedOwnedCourse(Integer id, Integer instructorId) {
        Course course = lockedCourse(id);
        if (!course.getInstructor().getUserId().equals(instructorId))
            throw new CourseActionException(HttpStatus.NOT_FOUND, "Không tìm thấy khóa học của bạn.");
        return course;
    }

    private Course lockedCourse(Integer id) {
        return courses.findLockedById(id)
                .orElseThrow(() -> new CourseActionException(HttpStatus.NOT_FOUND, "Không tìm thấy khóa học."));
    }

    private Course course(Integer id) {
        return courses.findById(id).orElseThrow(() -> new CourseActionException(HttpStatus.NOT_FOUND, "Không tìm thấy khóa học."));
    }

    private Users user(Integer id) {
        return users.findById(id).orElseThrow(() -> new CourseActionException(HttpStatus.UNAUTHORIZED, "Vui lòng đăng nhập lại."));
    }

    private ManagedCourseView view(Course course) {
        String reviewComment = reviews.findFirstByCourse_CourseIdOrderByReviewedAtDescReviewIdDesc(course.getCourseId())
                .map(CourseReview::getComment).orElse(null);
        return new ManagedCourseView(course.getCourseId(), course.getTitle(), course.getDescription(),
                course.getCategory() == null ? "Chưa phân loại" : course.getCategory().getName(),
                course.getInstructor().getFullName(), course.getLevel(), course.getPrice(),
                course.getStatus(), course.getVersionNo(), reviewComment);
    }

    private CourseActionException conflict(String message) {
        return new CourseActionException(HttpStatus.CONFLICT, message);
    }
}
