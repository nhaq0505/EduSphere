package com.edusphere.service.course;

import com.edusphere.dto.course.CourseCommentView;
import com.edusphere.dto.course.CourseRatingSummary;
import com.edusphere.entity.account.UserRoles;
import com.edusphere.entity.account.Users;
import com.edusphere.entity.course.Course;
import com.edusphere.entity.course.CourseComment;
import com.edusphere.entity.course.CourseCommentLike;
import com.edusphere.entity.course.Lesson;
import com.edusphere.repository.account.UserRepository;
import com.edusphere.repository.course.CourseCommentLikeRepository;
import com.edusphere.repository.course.CourseCommentRepository;
import com.edusphere.repository.course.CourseRepository;
import com.edusphere.repository.course.LessonRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Optional;
import java.util.Set;

@Service
public class CourseCommentService {

    private static final String ACTIVE = "ACTIVE";

    private final CourseCommentRepository commentRepository;
    private final CourseCommentLikeRepository likeRepository;
    private final CourseRepository courseRepository;
    private final LessonRepository lessonRepository;
    private final UserRepository userRepository;

    @Autowired
    public CourseCommentService(CourseCommentRepository commentRepository,
                                CourseCommentLikeRepository likeRepository,
                                CourseRepository courseRepository,
                                LessonRepository lessonRepository,
                                UserRepository userRepository) {
        this.commentRepository = commentRepository;
        this.likeRepository = likeRepository;
        this.courseRepository = courseRepository;
        this.lessonRepository = lessonRepository;
        this.userRepository = userRepository;
    }

    @Transactional(readOnly = true)
    public List<CourseCommentView> getCourseComments(Integer courseId, Integer currentUserId, String sort) {
        Course course = courseRepository.findById(courseId).orElse(null);
        if (course == null) {
            return List.of();
        }
        List<CourseComment> roots = new ArrayList<>(
                commentRepository.findByCourse_CourseIdAndLessonIsNullAndParentIsNullAndStatusOrderByPinnedDescCreatedAtDesc(courseId, ACTIVE)
        );
        sortRootComments(roots, sort);

        List<CourseComment> allReplies = commentRepository
                .findByCourse_CourseIdAndLessonIsNullAndParentIsNotNullAndStatusOrderByCreatedAtAsc(courseId, ACTIVE);

        return buildCommentTree(course, roots, allReplies, currentUserId);
    }

    @Transactional(readOnly = true)
    public List<CourseCommentView> getLessonComments(Integer courseId, Integer lessonId, Integer currentUserId, String sort) {
        if (courseId == null || lessonId == null) {
            return List.of();
        }
        Course course = courseRepository.findById(courseId).orElse(null);
        if (course == null) {
            return List.of();
        }
        List<CourseComment> roots = new ArrayList<>(
                commentRepository.findByCourse_CourseIdAndLesson_LessonIdAndParentIsNullAndStatusOrderByPinnedDescCreatedAtDesc(courseId, lessonId, ACTIVE)
        );
        sortRootComments(roots, sort);

        List<CourseComment> allReplies = commentRepository
                .findByCourse_CourseIdAndLesson_LessonIdAndParentIsNotNullAndStatusOrderByCreatedAtAsc(courseId, lessonId, ACTIVE);

        return buildCommentTree(course, roots, allReplies, currentUserId);
    }

    @Transactional(readOnly = true)
    public long countLessonComments(Integer courseId, Integer lessonId) {
        if (courseId == null || lessonId == null) return 0;
        return commentRepository.countByCourse_CourseIdAndLesson_LessonIdAndStatus(courseId, lessonId, ACTIVE);
    }

    @Transactional(readOnly = true)
    public CourseRatingSummary getCourseRatingSummary(Integer courseId) {
        List<CourseComment> roots = commentRepository
                .findByCourse_CourseIdAndLessonIsNullAndParentIsNullAndStatusOrderByPinnedDescCreatedAtDesc(courseId, ACTIVE);
        long totalComments = commentRepository.countByCourse_CourseIdAndLessonIsNullAndStatus(courseId, ACTIVE);

        int s5 = 0, s4 = 0, s3 = 0, s2 = 0, s1 = 0;
        long sum = 0;
        long ratedCount = 0;

        for (CourseComment c : roots) {
            Integer r = c.getRating();
            if (r != null && r >= 1 && r <= 5) {
                ratedCount++;
                sum += r;
                switch (r) {
                    case 5 -> s5++;
                    case 4 -> s4++;
                    case 3 -> s3++;
                    case 2 -> s2++;
                    case 1 -> s1++;
                }
            }
        }

        double avg = ratedCount > 0 ? Math.round((sum * 10.0) / ratedCount) / 10.0 : 0.0;
        return new CourseRatingSummary(avg, ratedCount, totalComments, s5, s4, s3, s2, s1);
    }

    @Transactional
    public CourseComment addComment(Integer courseId, Integer lessonId, Integer parentCommentId,
                                    Integer userId, String content, Integer rating) {
        if (userId == null) {
            throw new CourseActionException(HttpStatus.UNAUTHORIZED, "Vui lòng đăng nhập để bình luận.");
        }
        String text = content == null ? "" : content.trim();
        if (text.isEmpty()) {
            throw new CourseActionException(HttpStatus.BAD_REQUEST, "Nội dung bình luận không được để trống.");
        }
        if (text.length() > 3000) {
            throw new CourseActionException(HttpStatus.BAD_REQUEST, "Nội dung bình luận tối đa 3000 ký tự.");
        }

        Users author = userRepository.findById(userId)
                .orElseThrow(() -> new CourseActionException(HttpStatus.UNAUTHORIZED, "Vui lòng đăng nhập lại."));
        Course course = courseRepository.findById(courseId)
                .orElseThrow(() -> new CourseActionException(HttpStatus.NOT_FOUND, "Không tìm thấy khóa học."));

        Lesson lesson = null;
        if (lessonId != null) {
            lesson = lessonRepository.findByLessonIdAndCourse_CourseId(lessonId, courseId)
                    .orElseThrow(() -> new CourseActionException(HttpStatus.NOT_FOUND, "Không tìm thấy bài học."));
        }

        CourseComment parent = null;
        if (parentCommentId != null) {
            parent = commentRepository.findById(parentCommentId)
                    .filter(p -> ACTIVE.equalsIgnoreCase(p.getStatus())
                            && Objects.equals(p.getCourse().getCourseId(), courseId))
                    .orElseThrow(() -> new CourseActionException(HttpStatus.NOT_FOUND, "Không tìm thấy bình luận gốc để trả lời."));
            // Nếu người dùng trả lời vào một reply cấp 2, gắn về comment gốc cấp 1 để hiển thị dạng thread chuẩn VietJack
            if (parent.getParent() != null) {
                parent = parent.getParent();
            }
            if (lesson == null && parent.getLesson() != null) {
                lesson = parent.getLesson();
            }
        }

        CourseComment comment = new CourseComment();
        comment.setCourse(course);
        comment.setLesson(lesson);
        comment.setParent(parent);
        comment.setAuthor(author);
        comment.setContent(text);
        if (parent == null && lesson == null && rating != null && rating >= 1 && rating <= 5) {
            comment.setRating(rating);
        }
        comment.setLikeCount(0);
        comment.setPinned(false);
        comment.setStatus(ACTIVE);
        comment.setCreatedAt(LocalDateTime.now());
        comment.setUpdatedAt(LocalDateTime.now());

        return commentRepository.save(comment);
    }

    @Transactional
    public Map<String, Object> toggleLike(Integer commentId, Integer userId) {
        if (userId == null) {
            throw new CourseActionException(HttpStatus.UNAUTHORIZED, "Vui lòng đăng nhập để thích bình luận.");
        }
        CourseComment comment = commentRepository.findById(commentId)
                .filter(c -> ACTIVE.equalsIgnoreCase(c.getStatus()))
                .orElseThrow(() -> new CourseActionException(HttpStatus.NOT_FOUND, "Không tìm thấy bình luận."));
        Users user = userRepository.findById(userId)
                .orElseThrow(() -> new CourseActionException(HttpStatus.UNAUTHORIZED, "Vui lòng đăng nhập lại."));

        Optional<CourseCommentLike> existing = likeRepository.findByComment_CommentIdAndUser_UserId(commentId, userId);
        boolean liked;
        if (existing.isPresent()) {
            likeRepository.delete(existing.get());
            liked = false;
        } else {
            CourseCommentLike like = new CourseCommentLike();
            like.setComment(comment);
            like.setUser(user);
            like.setCreatedAt(LocalDateTime.now());
            likeRepository.save(like);
            liked = true;
        }

        int newCount = (int) likeRepository.countByComment_CommentId(commentId);
        comment.setLikeCount(newCount);
        commentRepository.save(comment);

        Map<String, Object> res = new HashMap<>();
        res.put("liked", liked);
        res.put("likeCount", newCount);
        res.put("courseId", comment.getCourse().getCourseId());
        res.put("lessonId", comment.getLesson() != null ? comment.getLesson().getLessonId() : null);
        return res;
    }

    @Transactional
    public CourseComment togglePin(Integer commentId, Integer userId) {
        if (userId == null) {
            throw new CourseActionException(HttpStatus.UNAUTHORIZED, "Vui lòng đăng nhập.");
        }
        CourseComment comment = commentRepository.findById(commentId)
                .filter(c -> ACTIVE.equalsIgnoreCase(c.getStatus()))
                .orElseThrow(() -> new CourseActionException(HttpStatus.NOT_FOUND, "Không tìm thấy bình luận."));
        Users currentUser = userRepository.findById(userId)
                .orElseThrow(() -> new CourseActionException(HttpStatus.UNAUTHORIZED, "Vui lòng đăng nhập lại."));

        if (!canModerate(comment.getCourse(), currentUser)) {
            throw new CourseActionException(HttpStatus.FORBIDDEN, "Chỉ giảng viên khóa học hoặc quản trị viên mới có quyền ghim bình luận.");
        }

        comment.setPinned(!Boolean.TRUE.equals(comment.getPinned()));
        comment.setUpdatedAt(LocalDateTime.now());
        return commentRepository.save(comment);
    }

    @Transactional
    public CourseComment deleteComment(Integer commentId, Integer userId) {
        if (userId == null) {
            throw new CourseActionException(HttpStatus.UNAUTHORIZED, "Vui lòng đăng nhập.");
        }
        CourseComment comment = commentRepository.findById(commentId)
                .orElseThrow(() -> new CourseActionException(HttpStatus.NOT_FOUND, "Không tìm thấy bình luận."));
        Users currentUser = userRepository.findById(userId)
                .orElseThrow(() -> new CourseActionException(HttpStatus.UNAUTHORIZED, "Vui lòng đăng nhập lại."));

        boolean isAuthor = comment.getAuthor() != null && Objects.equals(comment.getAuthor().getUserId(), userId);
        if (!isAuthor && !canModerate(comment.getCourse(), currentUser)) {
            throw new CourseActionException(HttpStatus.FORBIDDEN, "Bạn không có quyền xóa bình luận này.");
        }

        comment.setStatus("DELETED");
        comment.setUpdatedAt(LocalDateTime.now());
        return commentRepository.save(comment);
    }

    private void sortRootComments(List<CourseComment> roots, String sort) {
        if ("popular".equalsIgnoreCase(sort)) {
            roots.sort(Comparator
                    .comparing((CourseComment c) -> Boolean.TRUE.equals(c.getPinned())).reversed()
                    .thenComparing((CourseComment c) -> c.getLikeCount() != null ? c.getLikeCount() : 0, Comparator.reverseOrder())
                    .thenComparing(CourseComment::getCreatedAt, Comparator.nullsLast(Comparator.reverseOrder())));
        } else if ("oldest".equalsIgnoreCase(sort)) {
            roots.sort(Comparator
                    .comparing((CourseComment c) -> Boolean.TRUE.equals(c.getPinned())).reversed()
                    .thenComparing(CourseComment::getCreatedAt, Comparator.nullsLast(Comparator.naturalOrder())));
        }
    }

    private List<CourseCommentView> buildCommentTree(Course course,
                                                     List<CourseComment> roots,
                                                     List<CourseComment> allReplies,
                                                     Integer currentUserId) {
        Users currentUser = currentUserId != null ? userRepository.findById(currentUserId).orElse(null) : null;
        boolean isModerator = canModerate(course, currentUser);

        List<Integer> allIds = new ArrayList<>();
        for (CourseComment r : roots) allIds.add(r.getCommentId());
        for (CourseComment rep : allReplies) allIds.add(rep.getCommentId());

        Set<Integer> likedIds = new HashSet<>();
        if (currentUserId != null && !allIds.isEmpty()) {
            likedIds.addAll(likeRepository.findLikedCommentIdsByUser(currentUserId, allIds));
        }

        Map<Integer, List<CourseCommentView>> repliesByParentId = new HashMap<>();
        for (CourseComment rep : allReplies) {
            if (rep.getParent() != null) {
                Integer parentId = rep.getParent().getCommentId();
                CourseCommentView repView = toView(course, rep, currentUserId, isModerator, likedIds.contains(rep.getCommentId()));
                repliesByParentId.computeIfAbsent(parentId, k -> new ArrayList<>()).add(repView);
            }
        }

        List<CourseCommentView> result = new ArrayList<>();
        for (CourseComment root : roots) {
            CourseCommentView rootView = toView(course, root, currentUserId, isModerator, likedIds.contains(root.getCommentId()));
            List<CourseCommentView> childViews = repliesByParentId.getOrDefault(root.getCommentId(), List.of());
            rootView.setReplies(childViews);
            result.add(rootView);
        }
        return result;
    }

    private CourseCommentView toView(Course course, CourseComment c, Integer currentUserId,
                                     boolean isModerator, boolean likedByMe) {
        Users author = c.getAuthor();
        Integer authorId = author != null ? author.getUserId() : null;
        String authorName = author != null && author.getFullName() != null ? author.getFullName() : "Người dùng EduSphere";
        boolean isCourseInstructor = course.getInstructor() != null
                && authorId != null
                && Objects.equals(course.getInstructor().getUserId(), authorId);

        String roleCode = detectPrimaryRole(author, isCourseInstructor);
        String roleBadge = switch (roleCode) {
            case "COURSE_INSTRUCTOR" -> "Giảng viên khóa học";
            case "INSTRUCTOR" -> "Giáo viên";
            case "ADMINISTRATOR" -> "Quản trị viên";
            default -> "Học viên";
        };

        boolean canDelete = isModerator || (currentUserId != null && Objects.equals(currentUserId, authorId));

        return CourseCommentView.builder()
                .commentId(c.getCommentId())
                .courseId(course.getCourseId())
                .lessonId(c.getLesson() != null ? c.getLesson().getLessonId() : null)
                .lessonTitle(c.getLesson() != null ? c.getLesson().getTitle() : null)
                .parentCommentId(c.getParent() != null ? c.getParent().getCommentId() : null)
                .authorId(authorId)
                .authorName(authorName)
                .authorAvatarUrl(author != null ? author.getAvatarUrl() : null)
                .authorRoleBadge(roleBadge)
                .authorRoleCode(roleCode)
                .courseInstructor(isCourseInstructor)
                .content(c.getContent())
                .rating(c.getRating())
                .likeCount(c.getLikeCount() != null ? c.getLikeCount() : 0)
                .likedByMe(likedByMe)
                .pinned(Boolean.TRUE.equals(c.getPinned()))
                .canDelete(canDelete)
                .canPin(isModerator && c.getParent() == null)
                .createdAt(c.getCreatedAt())
                .build();
    }

    private String detectPrimaryRole(Users user, boolean isCourseInstructor) {
        if (isCourseInstructor) {
            return "COURSE_INSTRUCTOR";
        }
        if (user == null || user.getUserRolesCollection() == null) {
            return "STUDENT";
        }
        boolean isAdmin = false;
        boolean isInstructor = false;
        for (UserRoles ur : user.getUserRolesCollection()) {
            if (ur.getRoles() != null && ur.getRoles().getRoleName() != null) {
                String rName = ur.getRoles().getRoleName().toUpperCase();
                if ("ADMINISTRATOR".equals(rName)) isAdmin = true;
                if ("INSTRUCTOR".equals(rName)) isInstructor = true;
            }
        }
        if (isAdmin) return "ADMINISTRATOR";
        if (isInstructor) return "INSTRUCTOR";
        return "STUDENT";
    }

    private boolean canModerate(Course course, Users user) {
        if (user == null || course == null) return false;
        if (course.getInstructor() != null && Objects.equals(course.getInstructor().getUserId(), user.getUserId())) {
            return true;
        }
        if (user.getUserRolesCollection() != null) {
            for (UserRoles ur : user.getUserRolesCollection()) {
                if (ur.getRoles() != null && "ADMINISTRATOR".equalsIgnoreCase(ur.getRoles().getRoleName())) {
                    return true;
                }
            }
        }
        return false;
    }
}
