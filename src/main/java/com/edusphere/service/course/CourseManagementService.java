package com.edusphere.service.course;

import com.edusphere.dto.course.CourseForm;
import com.edusphere.dto.course.CourseSectionView;
import com.edusphere.dto.course.EnrolledCourseView;
import com.edusphere.dto.course.InstructorDashboardStats;
import com.edusphere.dto.course.ManagedCourseView;
import com.edusphere.entity.account.Users;
import com.edusphere.entity.course.Category;
import com.edusphere.entity.course.Course;
import com.edusphere.entity.course.CourseReview;
import com.edusphere.entity.course.CourseSection;
import com.edusphere.entity.course.Enrollment;
import com.edusphere.entity.course.Lesson;
import com.edusphere.repository.account.UserRepository;
import com.edusphere.repository.course.CategoryRepository;
import com.edusphere.repository.course.CourseRepository;
import com.edusphere.repository.course.CourseReviewRepository;
import com.edusphere.repository.course.CourseSectionRepository;
import com.edusphere.repository.course.EnrollmentRepository;
import com.edusphere.repository.course.LessonCompletionRepository;
import com.edusphere.repository.course.LessonRepository;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Set;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class CourseManagementService {
    private static final Set<String> LEVELS = Set.of("ALL_LEVELS", "BEGINNER", "INTERMEDIATE", "ADVANCED");

    private final CourseRepository courses;
    private final CourseReviewRepository reviews;
    private final EnrollmentRepository enrollments;
    private final LessonRepository lessons;
    private final CategoryRepository categories;
    private final UserRepository users;
    private final LearningProgressService learningProgressService;
    private final CourseSectionRepository sections;

    @Autowired(required = false)
    private LessonCompletionRepository lessonCompletions;

    @Autowired(required = false)
    private CertificateService certificateService;

    public CourseManagementService(CourseRepository courses, CourseReviewRepository reviews,
                                   EnrollmentRepository enrollments, CategoryRepository categories,
                                   UserRepository users, LessonRepository lessons) {
        this(courses, reviews, enrollments, categories, users, lessons, null, null);
    }

    public CourseManagementService(CourseRepository courses, CourseReviewRepository reviews,
                                   EnrollmentRepository enrollments, CategoryRepository categories,
                                   UserRepository users, LessonRepository lessons,
                                   LearningProgressService learningProgressService) {
        this(courses, reviews, enrollments, categories, users, lessons, learningProgressService, null);
    }

    @Autowired
    public CourseManagementService(CourseRepository courses, CourseReviewRepository reviews,
                                   EnrollmentRepository enrollments, CategoryRepository categories,
                                   UserRepository users, LessonRepository lessons,
                                   LearningProgressService learningProgressService,
                                   CourseSectionRepository sections) {
        this.courses = courses;
        this.reviews = reviews;
        this.enrollments = enrollments;
        this.lessons = lessons;
        this.categories = categories;
        this.users = users;
        this.learningProgressService = learningProgressService;
        this.sections = sections;
    }

    @Transactional(readOnly = true)
    public List<ManagedCourseView> instructorCourses(Integer instructorId) {
        return instructorCourses(instructorId, null);
    }

    @Transactional(readOnly = true)
    public List<ManagedCourseView> instructorCourses(Integer instructorId, String q) {
        List<Course> list = courses.findByInstructor_UserIdOrderByCreatedAtDesc(instructorId);
        if (q != null && !q.isBlank()) {
            String term = q.trim().toLowerCase();
            list = list.stream().filter(c ->
                    (c.getTitle() != null && c.getTitle().toLowerCase().contains(term)) ||
                    (c.getDescription() != null && c.getDescription().toLowerCase().contains(term))
            ).toList();
        }
        return list.stream().map(this::view).toList();
    }

    @Transactional(readOnly = true)
    public org.springframework.data.domain.Page<ManagedCourseView> searchInstructorCourses(
            Integer instructorId, String q, org.springframework.data.domain.Pageable pageable) {
        List<ManagedCourseView> filtered = instructorCourses(instructorId, q);
        if (pageable == null || pageable.isUnpaged()) {
            return new org.springframework.data.domain.PageImpl<>(filtered);
        }
        int start = (int) pageable.getOffset();
        int end = Math.min((start + pageable.getPageSize()), filtered.size());
        List<ManagedCourseView> subList = start > filtered.size() ? List.of() : filtered.subList(start, end);
        return new org.springframework.data.domain.PageImpl<>(subList, pageable, filtered.size());
    }

    @Transactional(readOnly = true)
    public InstructorDashboardStats instructorDashboard(Integer instructorId) {
        List<ManagedCourseView> all = instructorCourses(instructorId);
        int totalCourses    = all.size();
        int publishedCount  = (int) all.stream().filter(c -> "PUBLISHED".equals(c.getStatus())).count();
        int draftCount      = (int) all.stream().filter(c -> "DRAFT".equals(c.getStatus()) || "UPDATING".equals(c.getStatus())).count();
        int totalLessons    = all.stream().mapToInt(ManagedCourseView::getLessonCount).sum();

        // Đếm tổng học viên (active + completed) qua tất cả khóa học của giáo viên
        int totalStudents = courses.findByInstructor_UserIdOrderByCreatedAtDesc(instructorId).stream()
                .mapToInt(course -> {
                    long active    = enrollments.findByCourse_CourseIdAndStatus(course.getCourseId(), "ACTIVE").size();
                    long completed = enrollments.findByCourse_CourseIdAndStatus(course.getCourseId(), "COMPLETED").size();
                    return (int)(active + completed);
                }).sum();

        // Hiển thị tối đa 5 khóa học gần nhất trên dashboard
        List<ManagedCourseView> recent = all.stream().limit(5).toList();
        return new InstructorDashboardStats(totalCourses, publishedCount, draftCount,
                totalStudents, totalLessons, recent);
    }

    @Transactional(readOnly = true)
    public ManagedCourseView instructorCourse(Integer id, Integer instructorId) {
        return view(ownedCourse(id, instructorId));
    }

    @Transactional(readOnly = true)
    public CourseForm editForm(Integer id, Integer instructorId) {
        Course course = ownedCourse(id, instructorId);
        if (!canEdit(course)) throw conflict("Khóa học đang chờ duyệt hoặc đã lưu trữ, không thể chỉnh sửa.");
        CourseForm form = new CourseForm();
        form.setTitle(course.getTitle());
        form.setDescription(course.getDescription());
        form.setCategoryId(course.getCategory() == null ? null : course.getCategory().getCategoryId());
        form.setLevel(course.getLevel());
        form.setPrice(course.getPrice());
        form.setCredits(course.getCredits() != null && course.getCredits() > 0 ? course.getCredits() : 3);
        form.setThumbnailUrl(course.getThumbnailUrl());
        form.setPromoVideoUrl(course.getPromoVideoUrl());
        form.setObjectives(course.getObjectives());
        form.setRequirements(course.getRequirements());
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
        if (!canEdit(course)) throw conflict("Khóa học đang chờ duyệt hoặc đã lưu trữ, không thể chỉnh sửa.");
        applyForm(course, form);
        course.setVersionNo(course.getVersionNo() + 1);
        if ("PUBLISHED".equals(course.getStatus()) || "APPROVED".equals(course.getStatus())
                || "UPDATING".equals(course.getStatus())) {
            course.setStatus("UPDATING");
            course.setSubmittedAt(null);
        } else {
            course.setStatus("DRAFT");
            course.setSubmittedAt(null);
            course.setApprovedAt(null);
            course.setPublishedAt(null);
        }
        course.setUpdatedAt(LocalDateTime.now());
    }

    @Transactional
    public void updateCourse(Integer id, Integer instructorId, CourseForm form) {
        edit(id, instructorId, form);
    }

    @Transactional
    public void submit(Integer id, Integer instructorId) {
        Course course = lockedOwnedCourse(id, instructorId);
        if (!canSubmit(course)) throw conflict("Chỉ có thể gửi khóa học nháp, bị từ chối, hoặc đang cập nhật.");
        if (course.getDescription() == null || course.getDescription().isBlank())
            throw conflict("Hãy thêm mô tả trước khi gửi duyệt.");
        List<Lesson> courseLessons = lessons.findByCourse_CourseIdOrderByOrderIndexAsc(id);
        if (courseLessons.isEmpty())
            throw conflict("Khóa học phải có ít nhất một bài học trước khi gửi duyệt.");
        boolean hasIncompleteLesson = courseLessons.stream()
                .anyMatch(l -> !isLessonComplete(l));
        if (hasIncompleteLesson)
            throw conflict("Tất cả các bài học phải có tiêu đề và nội dung hoàn chỉnh trước khi gửi duyệt.");
        course.setStatus("SUBMITTED");
        course.setSubmittedAt(LocalDateTime.now());
        course.setUpdatedAt(LocalDateTime.now());
    }

    @Transactional
    public void submitWithNote(Integer id, Integer instructorId, String changeNote) {
        Course course = lockedOwnedCourse(id, instructorId);
        if (!canSubmit(course)) throw conflict("Chỉ có thể gửi khóa học nháp, bị từ chối, hoặc đang cập nhật.");
        if (course.getDescription() == null || course.getDescription().isBlank())
            throw conflict("Hãy thêm mô tả trước khi gửi duyệt.");
        List<Lesson> courseLessons = lessons.findByCourse_CourseIdOrderByOrderIndexAsc(id);
        if (courseLessons.isEmpty())
            throw conflict("Khóa học phải có ít nhất một bài học trước khi gửi duyệt.");
        boolean hasIncompleteLesson = courseLessons.stream()
                .anyMatch(l -> !isLessonComplete(l));
        if (hasIncompleteLesson)
            throw conflict("Tất cả các bài học phải có tiêu đề và nội dung hoàn chỉnh trước khi gửi duyệt.");
        String note = changeNote == null ? null : changeNote.trim();
        course.setChangeNote(note != null && !note.isEmpty() ? note : null);
        course.setStatus("SUBMITTED");
        course.setSubmittedAt(LocalDateTime.now());
        course.setUpdatedAt(LocalDateTime.now());
    }

    @Transactional(readOnly = true)
    public List<Lesson> courseLessons(Integer courseId, Integer instructorId) {
        ownedCourse(courseId, instructorId);
        return lessons.findByCourse_CourseIdOrderByOrderIndexAsc(courseId);
    }

    @Transactional(readOnly = true)
    public List<ManagedCourseView> pendingCourses() {
        return courses.findByStatusOrderBySubmittedAtAsc("SUBMITTED").stream().map(this::view).toList();
    }

    @Transactional(readOnly = true)
    public ManagedCourseView adminCourseDetail(Integer courseId) {
        Course course = course(courseId);
        if (!"SUBMITTED".equals(course.getStatus()))
            throw conflict("Khóa học không ở trạng thái chờ duyệt.");
        return view(course);
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
        lessons.findByCourse_CourseIdAndStatusOrderByOrderIndexAsc(id, "DRAFT")
                .forEach(lesson -> {
                    lesson.setStatus("PUBLISHED");
                    lesson.setUpdatedAt(LocalDateTime.now());
                });
        List<Enrollment> completed = enrollments.findByCourse_CourseIdAndStatus(id, "COMPLETED");
        if (completed != null) {
            completed.forEach(enrollment -> {
                enrollment.setStatus("ACTIVE");
                enrollment.setCompletedAt(null);
            });
        }
    }

    @Transactional
    public void republish(Integer id, Integer instructorId) {
        Course course = lockedOwnedCourse(id, instructorId);
        if (!"APPROVED".equals(course.getStatus()) || course.getApprovedAt() == null)
            throw conflict("Khóa học phải được quản trị viên phê duyệt trước khi tái công bố.");
        course.setStatus("PUBLISHED");
        course.setPublishedAt(LocalDateTime.now());
        course.setUpdatedAt(LocalDateTime.now());
        lessons.findByCourse_CourseIdAndStatusOrderByOrderIndexAsc(id, "DRAFT")
                .forEach(lesson -> {
                    lesson.setStatus("PUBLISHED");
                    lesson.setUpdatedAt(LocalDateTime.now());
                });
        List<Enrollment> completed = enrollments.findByCourse_CourseIdAndStatus(id, "COMPLETED");
        if (completed != null) {
            completed.forEach(enrollment -> {
                enrollment.setStatus("ACTIVE");
                enrollment.setCompletedAt(null);
            });
        }
    }

    @Transactional
    public void hide(Integer id, Integer instructorId) {
        Course course = lockedOwnedCourse(id, instructorId);
        if (!"PUBLISHED".equals(course.getStatus()))
            throw conflict("Chỉ có thể ẩn khóa học đang được công bố.");
        course.setStatus("APPROVED");
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
        boolean isPubliclyAvailable = "PUBLISHED".equals(course.getStatus())
                || "UPDATING".equals(course.getStatus())
                || ("SUBMITTED".equals(course.getStatus()) && course.getPublishedAt() != null);
        if (!isPubliclyAvailable)
            throw new CourseActionException(HttpStatus.NOT_FOUND, "Không tìm thấy khóa học công khai.");
        if (course.getPrice().signum() > 0)
            throw conflict("Khóa học có phí cần thanh toán trước khi ghi danh.");
        Enrollment existing = enrollments.findByStudent_UserIdAndCourse_CourseId(studentId, courseId).orElse(null);
        if (existing != null && !"DROPPED".equals(existing.getStatus())) {
            return;
        }

        Users student = user(studentId);
        if (existing == null) {
            Enrollment enrollment = new Enrollment();
            enrollment.setStudent(student);
            enrollment.setCourse(course);
            enrollments.save(enrollment);
        } else {
            existing.setStatus("ACTIVE");
            existing.setDroppedAt(null);
            existing.setEnrolledAt(LocalDateTime.now());
        }

        if (learningProgressService != null) {
            learningProgressService.recordActivity(student, course,
                    "COURSE_ENROLLED", null, null, null, "Đã ghi danh khóa học: " + course.getTitle());
        }
    }

    @Transactional
    public List<EnrolledCourseView> enrolledCourses(Integer studentId) {
        return enrollments.findByStudent_UserIdOrderByEnrolledAtDesc(studentId).stream()
                .map(this::toEnrolledView)
                .toList();
    }

    private EnrolledCourseView toEnrolledView(Enrollment e) {
        Course c = e.getCourse();
        Integer courseId = c.getCourseId();
        Integer studentId = e.getStudent() != null ? e.getStudent().getUserId() : null;

        int total = lessons != null ? (int) lessons.countByCourse_CourseIdAndStatus(courseId, "PUBLISHED") : 0;
        int completed = (lessonCompletions != null && studentId != null)
                ? (int) lessonCompletions.countByStudent_UserIdAndCourse_CourseId(studentId, courseId)
                : 0;
        if (total > 0 && completed > total) {
            completed = total;
        }
        int pct = total > 0 ? (int) Math.round((completed * 100.0) / total) : ("COMPLETED".equalsIgnoreCase(e.getStatus()) ? 100 : 0);

        String effectiveStatus = e.getStatus();
        if (total > 0 && completed >= total && !"COMPLETED".equalsIgnoreCase(effectiveStatus) && !"DROPPED".equalsIgnoreCase(effectiveStatus)) {
            effectiveStatus = "COMPLETED";
        }

        EnrolledCourseView v = new EnrolledCourseView(
                courseId,
                c.getTitle(),
                c.getInstructor() != null ? c.getInstructor().getFullName() : "",
                effectiveStatus,
                c.getStatus()
        );
        v.setCredits(c.getCredits() != null && c.getCredits() > 0 ? c.getCredits() : 3);
        v.setTotalLessons(total);
        v.setCompletedLessons(completed);
        v.setProgressPercent(pct);
        v.setThumbnailUrl(c.getThumbnailUrl());
        v.setCategoryName(c.getCategory() != null ? c.getCategory().getName() : "Chuyên ngành");
        v.setEnrolledAt(e.getEnrolledAt());
        v.setCompletedAt(e.getCompletedAt());

        if (certificateService != null && studentId != null && ("COMPLETED".equalsIgnoreCase(effectiveStatus) || pct >= 100)) {
            try {
                certificateService.issueCertificateIfEligible(studentId, courseId).ifPresent(cert -> {
                    v.setCertificateId(cert.getCertificateId());
                    v.setVerificationCode(cert.getVerificationCode());
                    v.setGradePercent(cert.getGradePercent());
                    if (v.getCompletedAt() == null) {
                        v.setCompletedAt(cert.getIssuedAt());
                    }
                });
            } catch (Exception ignored) {
            }
        }
        return v;
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
        course.setCredits(form.getCredits() != null && form.getCredits() > 0 ? form.getCredits() : 3);
        Category category = form.getCategoryId() == null ? null : categories.findById(form.getCategoryId())
                .filter(c -> "ACTIVE".equals(c.getStatus()))
                .orElseThrow(() -> conflict("Danh mục không hợp lệ."));
        course.setCategory(category);

        course.setThumbnailUrl(trimmed(form.getThumbnailUrl()));
        course.setPromoVideoUrl(trimmed(form.getPromoVideoUrl()));
        course.setObjectives(trimmed(form.getObjectives()));
        course.setRequirements(trimmed(form.getRequirements()));
    }

    private boolean canEdit(Course course) {
        return !"SUBMITTED".equals(course.getStatus()) && !"ARCHIVED".equals(course.getStatus());
    }

    private boolean canSubmit(Course course) {
        return "DRAFT".equals(course.getStatus()) || "REJECTED".equals(course.getStatus())
                || "UPDATING".equals(course.getStatus());
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
        List<Lesson> courseLessons = lessons.findByCourse_CourseIdOrderByOrderIndexAsc(course.getCourseId());
        int lessonCount = courseLessons.size();
        boolean readyForSubmit = !courseLessons.isEmpty()
                && course.getDescription() != null && !course.getDescription().isBlank()
                && courseLessons.stream().allMatch(this::isLessonComplete);
        boolean hidden = "APPROVED".equals(course.getStatus()) && course.getPublishedAt() != null;
        ManagedCourseView view = new ManagedCourseView(course.getCourseId(), course.getTitle(), course.getDescription(),
                course.getCategory() == null ? "Chưa phân loại" : course.getCategory().getName(),
                course.getInstructor().getFullName(), course.getLevel(), course.getPrice(),
                course.getStatus(), course.getVersionNo(), reviewComment,
                lessonCount, readyForSubmit, hidden, course.getPublishedAt(),
                course.getThumbnailUrl(), course.getPromoVideoUrl(), course.getObjectives(), course.getRequirements());

        if (sections != null) {
            List<CourseSection> courseSections = sections.findByCourse_CourseIdOrderByOrderIndexAsc(course.getCourseId());
            List<CourseSectionView> sectionViews = new ArrayList<>();
            for (CourseSection s : courseSections) {
                CourseSectionView sv = new CourseSectionView(s.getSectionId(), course.getCourseId(), s.getTitle(), s.getDescription(), s.getOrderIndex());
                sv.setLessons(lessons.findBySection_SectionIdOrderByOrderIndexAsc(s.getSectionId()));
                sectionViews.add(sv);
            }
            List<Lesson> unsectioned = lessons.findByCourse_CourseIdAndSectionIsNullOrderByOrderIndexAsc(course.getCourseId());
            if (!unsectioned.isEmpty()) {
                CourseSectionView unsectionedView = new CourseSectionView(null, course.getCourseId(), "Bài học chưa phân mục", null, 9999);
                unsectionedView.setLessons(unsectioned);
                sectionViews.add(unsectionedView);
            }
            view.setSections(sectionViews);
        }
        view.setChangeNote(course.getChangeNote());
        view.setCredits(course.getCredits() != null && course.getCredits() > 0 ? course.getCredits() : 3);
        return view;
    }

    private boolean isLessonComplete(Lesson l) {
        if (l.getTitle() == null || l.getTitle().isBlank()) {
            return false;
        }
        if ("QUIZ".equalsIgnoreCase(l.getLessonType())) {
            return true;
        }
        if ("VIDEO".equalsIgnoreCase(l.getLessonType())) {
            return l.getVideoUrl() != null && !l.getVideoUrl().isBlank();
        }
        return l.getContent() != null && !l.getContent().isBlank();
    }

    private String trimmed(String value) {
        return value == null || value.isBlank() ? null : value.trim();
    }

    private CourseActionException conflict(String message) {
        return new CourseActionException(HttpStatus.CONFLICT, message);
    }
}
