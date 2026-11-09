package com.edusphere.service.course;

import com.edusphere.dto.course.CourseRatingItemView;
import com.edusphere.dto.course.CourseRatingSummaryView;
import com.edusphere.entity.account.Users;
import com.edusphere.entity.course.Course;
import com.edusphere.entity.course.CourseRating;
import com.edusphere.repository.account.UserRepository;
import com.edusphere.repository.course.CourseRatingRepository;
import com.edusphere.repository.course.CourseRepository;
import com.edusphere.repository.course.EnrollmentRepository;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * Dịch vụ quản lý đánh giá sao (1–5 sao) và nhận xét khóa học của học viên.
 */
@Service
public class CourseRatingService {

    private static final DateTimeFormatter DATE_FORMATTER = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");

    private final CourseRatingRepository courseRatingRepository;
    private final CourseRepository courseRepository;
    private final EnrollmentRepository enrollmentRepository;
    private final UserRepository usersRepository;

    public CourseRatingService(CourseRatingRepository courseRatingRepository,
                               CourseRepository courseRepository,
                               EnrollmentRepository enrollmentRepository,
                               UserRepository usersRepository) {
        this.courseRatingRepository = courseRatingRepository;
        this.courseRepository = courseRepository;
        this.enrollmentRepository = enrollmentRepository;
        this.usersRepository = usersRepository;
    }

    /**
     * Lấy toàn bộ thống kê điểm sao, phân bổ 1–5 sao, danh sách nhận xét và quyền đánh giá cho trang chi tiết khóa học.
     */
    @Transactional(readOnly = true)
    public CourseRatingSummaryView getRatingSummary(Integer courseId, Integer currentUserId, boolean isAdmin) {
        Course course = courseRepository.findById(courseId).orElse(null);
        List<CourseRating> entities = courseRatingRepository.findByCourseIdWithStudentOrderByCreatedAtDesc(courseId);

        Map<Integer, Long> starCounts = new LinkedHashMap<>();
        for (int star = 5; star >= 1; star--) {
            starCounts.put(star, 0L);
        }

        long totalRatings = entities.size();
        long sumStars = 0;
        List<CourseRatingItemView> reviewItems = new ArrayList<>();
        CourseRatingItemView myRating = null;

        for (CourseRating entity : entities) {
            int r = entity.getRating() == null ? 5 : Math.max(1, Math.min(5, entity.getRating()));
            sumStars += r;
            starCounts.put(r, starCounts.getOrDefault(r, 0L) + 1L);

            CourseRatingItemView item = toItemView(entity);
            reviewItems.add(item);

            if (currentUserId != null && entity.getStudent() != null
                    && currentUserId.equals(entity.getStudent().getUserId())) {
                myRating = item;
            }
        }

        double averageRating = totalRatings == 0
                ? 0.0
                : Math.round((sumStars * 10.0) / totalRatings) / 10.0;
        int roundedStars = (int) Math.round(averageRating);

        Map<Integer, Integer> starPercents = new LinkedHashMap<>();
        for (int star = 5; star >= 1; star--) {
            long count = starCounts.getOrDefault(star, 0L);
            int pct = totalRatings == 0 ? 0 : (int) Math.round((count * 100.0) / totalRatings);
            starPercents.put(star, pct);
        }

        boolean isCourseOwner = course != null && course.getInstructor() != null
                && currentUserId != null && currentUserId.equals(course.getInstructor().getUserId());

        boolean enrolled = currentUserId != null && enrollmentRepository
                .findByStudent_UserIdAndCourse_CourseId(currentUserId, courseId)
                .map(e -> !"DROPPED".equals(e.getStatus()))
                .orElse(false);

        boolean canRate = enrolled && !isCourseOwner;
        boolean canReply = isCourseOwner || isAdmin;

        return new CourseRatingSummaryView(
                averageRating,
                roundedStars,
                totalRatings,
                starCounts,
                starPercents,
                reviewItems,
                myRating,
                canRate,
                canReply
        );
    }

    /**
     * Học viên gửi mới hoặc cập nhật đánh giá sao (1–5 sao) và nhận xét cho khóa học đã ghi danh.
     */
    @Transactional
    public void submitOrUpdateRating(Integer courseId, Integer studentId, Integer rating, String comment) {
        if (rating == null || rating < 1 || rating > 5) {
            throw new CourseActionException(HttpStatus.BAD_REQUEST, "Vui lòng chọn mức đánh giá từ 1 đến 5 sao.");
        }

        Course course = courseRepository.findById(courseId)
                .orElseThrow(() -> new CourseActionException(HttpStatus.NOT_FOUND, "Không tìm thấy khóa học."));

        if (course.getInstructor() != null && studentId.equals(course.getInstructor().getUserId())) {
            throw new CourseActionException(HttpStatus.BAD_REQUEST, "Giảng viên không thể tự đánh giá khóa học của chính mình.");
        }

        boolean enrolled = enrollmentRepository.findByStudent_UserIdAndCourse_CourseId(studentId, courseId)
                .map(e -> !"DROPPED".equals(e.getStatus()))
                .orElse(false);
        if (!enrolled) {
            throw new CourseActionException(HttpStatus.FORBIDDEN, "Bạn cần ghi danh vào khóa học trước khi gửi đánh giá.");
        }

        Users student = usersRepository.findById(studentId)
                .orElseThrow(() -> new CourseActionException(HttpStatus.NOT_FOUND, "Không tìm thấy tài khoản học viên."));

        String normalizedComment = normalizeText(comment, 2000);

        CourseRating courseRating = courseRatingRepository
                .findByCourse_CourseIdAndStudent_UserId(courseId, studentId)
                .orElseGet(() -> {
                    CourseRating created = new CourseRating();
                    created.setCourse(course);
                    created.setStudent(student);
                    created.setCreatedAt(LocalDateTime.now());
                    return created;
                });

        courseRating.setRating(rating);
        courseRating.setComment(normalizedComment);
        if (courseRating.getRatingId() != null) {
            courseRating.setUpdatedAt(LocalDateTime.now());
        }
        courseRatingRepository.save(courseRating);
    }

    /**
     * Học viên xóa đánh giá của chính mình trên khóa học.
     */
    @Transactional
    public void deleteMyRating(Integer courseId, Integer studentId) {
        CourseRating existing = courseRatingRepository
                .findByCourse_CourseIdAndStudent_UserId(courseId, studentId)
                .orElseThrow(() -> new CourseActionException(HttpStatus.NOT_FOUND, "Bạn chưa có đánh giá nào cho khóa học này."));
        courseRatingRepository.delete(existing);
    }

    /**
     * Giảng viên sở hữu khóa học (hoặc Admin) phản hồi đánh giá của học viên.
     */
    @Transactional
    public void replyToRating(Integer courseId, Integer ratingId, Integer actorId, boolean isAdmin, String replyText) {
        Course course = courseRepository.findById(courseId)
                .orElseThrow(() -> new CourseActionException(HttpStatus.NOT_FOUND, "Không tìm thấy khóa học."));

        boolean isCourseOwner = course.getInstructor() != null && actorId.equals(course.getInstructor().getUserId());
        if (!isCourseOwner && !isAdmin) {
            throw new CourseActionException(HttpStatus.FORBIDDEN, "Chỉ giảng viên của khóa học hoặc quản trị viên mới có quyền phản hồi đánh giá.");
        }

        CourseRating rating = courseRatingRepository.findById(ratingId)
                .filter(r -> r.getCourse().getCourseId().equals(courseId))
                .orElseThrow(() -> new CourseActionException(HttpStatus.NOT_FOUND, "Không tìm thấy đánh giá cần phản hồi."));

        String normalizedReply = normalizeText(replyText, 2000);
        rating.setInstructorReply(normalizedReply);
        rating.setRepliedAt(normalizedReply == null ? null : LocalDateTime.now());
        courseRatingRepository.save(rating);
    }

    /**
     * Chuyển đổi thực thể CourseRating sang DTO hiển thị trên giao diện.
     */
    private CourseRatingItemView toItemView(CourseRating entity) {
        String fullName = entity.getStudent() != null && entity.getStudent().getFullName() != null
                ? entity.getStudent().getFullName().trim()
                : "Học viên";
        String initial = fullName.isEmpty() ? "H" : fullName.substring(0, 1).toUpperCase();
        LocalDateTime displayTime = entity.getUpdatedAt() != null ? entity.getUpdatedAt() : entity.getCreatedAt();

        return new CourseRatingItemView(
                entity.getRatingId(),
                entity.getStudent() != null ? entity.getStudent().getUserId() : null,
                fullName,
                initial,
                entity.getRating() != null ? entity.getRating() : 5,
                entity.getComment(),
                displayTime != null ? displayTime.format(DATE_FORMATTER) : "",
                entity.getUpdatedAt() != null,
                entity.getInstructorReply(),
                entity.getRepliedAt() != null ? entity.getRepliedAt().format(DATE_FORMATTER) : ""
        );
    }

    /**
     * Chuẩn hóa văn bản nhận xét/phản hồi và giới hạn độ dài an toàn.
     */
    private String normalizeText(String raw, int maxLen) {
        if (raw == null) {
            return null;
        }
        String trimmed = raw.trim();
        if (trimmed.isEmpty()) {
            return null;
        }
        return trimmed.length() <= maxLen ? trimmed : trimmed.substring(0, maxLen);
    }
}
