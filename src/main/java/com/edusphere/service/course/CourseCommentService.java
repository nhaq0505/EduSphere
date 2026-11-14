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

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Objects;
import java.util.Optional;
import java.util.Set;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * Dịch vụ nghiệp vụ xử lý Bình luận Khóa học (Course Reviews & Discussions)
 * và Hỏi đáp riêng tư giữa Học viên - Giảng viên trong từng Bài giảng (Lesson Q&A).
 */
@Service
public class CourseCommentService {

  private static final String ACTIVE = "ACTIVE";
  private static final String DELETED = "DELETED";
  private static final int MAX_COMMENT_LENGTH = 3000;

  private final CourseCommentRepository commentRepository;
  private final CourseCommentLikeRepository likeRepository;
  private final CourseRepository courseRepository;
  private final LessonRepository lessonRepository;
  private final UserRepository userRepository;

  @Autowired
  public CourseCommentService(
      CourseCommentRepository commentRepository,
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
  public List<CourseCommentView> getCourseComments(
      Integer courseId,
      Integer currentUserId,
      String sort) {
    Course course = courseRepository.findById(courseId).orElse(null);
    if (course == null) {
      return List.of();
    }
    List<CourseComment> roots = new ArrayList<>(
        commentRepository.findByCourse_CourseIdAndLessonIsNullAndParentIsNullAndStatusOrderByPinnedDescCreatedAtDesc(
            courseId, ACTIVE));
    sortRootComments(roots, sort);

    List<CourseComment> allReplies = commentRepository
        .findByCourse_CourseIdAndLessonIsNullAndParentIsNotNullAndStatusOrderByCreatedAtAsc(
            courseId, ACTIVE);

    return buildCommentTree(course, roots, allReplies, currentUserId);
  }

  @Transactional(readOnly = true)
  public List<CourseCommentView> getLessonComments(
      Integer courseId,
      Integer lessonId,
      Integer currentUserId,
      String sort) {
    if (courseId == null || lessonId == null || currentUserId == null) {
      return List.of();
    }
    Course course = courseRepository.findById(courseId).orElse(null);
    if (course == null) {
      return List.of();
    }
    Users currentUser = userRepository.findById(currentUserId).orElse(null);
    boolean isModerator = canModerate(course, currentUser);

    List<CourseComment> roots = new ArrayList<>(
        commentRepository.findByCourse_CourseIdAndLesson_LessonIdAndParentIsNullAndStatusOrderByPinnedDescCreatedAtDesc(
            courseId, lessonId, ACTIVE));
    // Học viên chỉ xem được các luồng trao đổi riêng của chính mình với giáo viên;
    // Giảng viên khóa học / Quản trị viên xem được toàn bộ để trả lời riêng từng học viên.
    if (!isModerator) {
      roots.removeIf(r -> r.getAuthor() == null
          || !Objects.equals(r.getAuthor().getUserId(), currentUserId));
    }
    sortRootComments(roots, sort);

    List<CourseComment> allReplies = commentRepository
        .findByCourse_CourseIdAndLesson_LessonIdAndParentIsNotNullAndStatusOrderByCreatedAtAsc(
            courseId, lessonId, ACTIVE);

    return buildCommentTree(course, roots, allReplies, currentUserId);
  }

  @Transactional(readOnly = true)
  public long countLessonComments(Integer courseId, Integer lessonId) {
    if (courseId == null || lessonId == null) {
      return 0;
    }
    return commentRepository.countByCourse_CourseIdAndLesson_LessonIdAndStatus(
        courseId, lessonId, ACTIVE);
  }

  @Transactional(readOnly = true)
  public long countLessonComments(Integer courseId, Integer lessonId, Integer currentUserId) {
    if (courseId == null || lessonId == null || currentUserId == null) {
      return 0;
    }
    Course course = courseRepository.findById(courseId).orElse(null);
    if (course == null) {
      return 0;
    }
    Users currentUser = userRepository.findById(currentUserId).orElse(null);
    if (canModerate(course, currentUser)) {
      return commentRepository.countByCourse_CourseIdAndLesson_LessonIdAndStatus(
          courseId, lessonId, ACTIVE);
    }
    List<CourseComment> roots = commentRepository
        .findByCourse_CourseIdAndLesson_LessonIdAndParentIsNullAndStatusOrderByPinnedDescCreatedAtDesc(
            courseId, lessonId, ACTIVE)
        .stream()
        .filter(r -> r.getAuthor() != null
            && Objects.equals(r.getAuthor().getUserId(), currentUserId))
        .toList();
    if (roots.isEmpty()) {
      return 0;
    }
    List<Integer> rootIds = roots.stream().map(CourseComment::getCommentId).toList();
    long replyCount = commentRepository
        .findByParent_CommentIdInAndStatusOrderByCreatedAtAsc(rootIds, ACTIVE)
        .size();
    return roots.size() + replyCount;
  }

  @Transactional(readOnly = true)
  public CourseRatingSummary getCourseRatingSummary(Integer courseId) {
    List<CourseComment> roots = commentRepository
        .findByCourse_CourseIdAndLessonIsNullAndParentIsNullAndStatusOrderByPinnedDescCreatedAtDesc(
            courseId, ACTIVE);
    long totalComments = commentRepository.countByCourse_CourseIdAndLessonIsNullAndStatus(
        courseId, ACTIVE);

    int s5 = 0;
    int s4 = 0;
    int s3 = 0;
    int s2 = 0;
    int s1 = 0;
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
          default -> { }
        }
      }
    }

    double avg = ratedCount > 0 ? Math.round((sum * 10.0) / ratedCount) / 10.0 : 0.0;
    return new CourseRatingSummary(avg, ratedCount, totalComments, s5, s4, s3, s2, s1);
  }

  /**
   * Tổng hợp thống kê thảo luận trong khóa học (tổng số thảo luận gốc, phản hồi từ giảng viên, số câu đã ghim).
   */
  @Transactional(readOnly = true)
  public Map<String, Object> buildCourseDiscussionStats(Integer courseId) {
    Map<String, Object> stats = new LinkedHashMap<>();
    Course course = courseRepository.findById(courseId).orElse(null);
    if (course == null) {
      stats.put("rootThreads", 0);
      stats.put("totalReplies", 0);
      stats.put("pinnedThreads", 0);
      stats.put("instructorReplies", 0);
      return stats;
    }

    List<CourseComment> roots = commentRepository
        .findByCourse_CourseIdAndLessonIsNullAndParentIsNullAndStatusOrderByPinnedDescCreatedAtDesc(
            courseId, ACTIVE);
    List<CourseComment> replies = commentRepository
        .findByCourse_CourseIdAndLessonIsNullAndParentIsNotNullAndStatusOrderByCreatedAtAsc(
            courseId, ACTIVE);

    int pinnedCount = 0;
    for (CourseComment r : roots) {
      if (Boolean.TRUE.equals(r.getPinned())) {
        pinnedCount++;
      }
    }

    Integer instructorId = course.getInstructor() != null
        ? course.getInstructor().getUserId()
        : null;
    int instructorReplies = 0;
    for (CourseComment rep : replies) {
      if (instructorId != null
          && rep.getAuthor() != null
          && Objects.equals(instructorId, rep.getAuthor().getUserId())) {
        instructorReplies++;
      }
    }

    stats.put("rootThreads", roots.size());
    stats.put("totalReplies", replies.size());
    stats.put("pinnedThreads", pinnedCount);
    stats.put("instructorReplies", instructorReplies);
    return stats;
  }

  @Transactional
  public CourseComment addComment(
      Integer courseId,
      Integer lessonId,
      Integer parentCommentId,
      Integer userId,
      String content,
      Integer rating) {
    if (userId == null) {
      throw new CourseActionException(
          HttpStatus.UNAUTHORIZED, "Vui lòng đăng nhập để bình luận.");
    }
    String text = content == null ? "" : content.trim();
    if (text.isEmpty()) {
      throw new CourseActionException(
          HttpStatus.BAD_REQUEST, "Nội dung bình luận không được để trống.");
    }
    if (text.length() > MAX_COMMENT_LENGTH) {
      throw new CourseActionException(
          HttpStatus.BAD_REQUEST, "Nội dung bình luận tối đa 3000 ký tự.");
    }

    Users author = userRepository.findById(userId)
        .orElseThrow(() -> new CourseActionException(
            HttpStatus.UNAUTHORIZED, "Vui lòng đăng nhập lại."));
    Course course = courseRepository.findById(courseId)
        .orElseThrow(() -> new CourseActionException(
            HttpStatus.NOT_FOUND, "Không tìm thấy khóa học."));

    Lesson lesson = null;
    if (lessonId != null) {
      lesson = lessonRepository.findByLessonIdAndCourse_CourseId(lessonId, courseId)
          .orElseThrow(() -> new CourseActionException(
              HttpStatus.NOT_FOUND, "Không tìm thấy bài học."));
    }

    CourseComment parent = null;
    if (parentCommentId != null) {
      parent = commentRepository.findById(parentCommentId)
          .filter(p -> ACTIVE.equalsIgnoreCase(p.getStatus())
              && Objects.equals(p.getCourse().getCourseId(), courseId))
          .orElseThrow(() -> new CourseActionException(
              HttpStatus.NOT_FOUND, "Không tìm thấy bình luận gốc để trả lời."));
      // Nếu người dùng trả lời vào một reply cấp 2, gắn về comment gốc cấp 1 để hiển thị dạng thread
      if (parent.getParent() != null) {
        parent = parent.getParent();
      }
      if (lesson == null && parent.getLesson() != null) {
        lesson = parent.getLesson();
      }
      // Trong trao đổi riêng dưới bài giảng: chỉ tác giả câu hỏi gốc hoặc giảng viên/admin mới được trả lời
      if (lesson != null && !canModerate(course, author)) {
        Integer rootAuthorId = parent.getAuthor() != null ? parent.getAuthor().getUserId() : null;
        if (!Objects.equals(rootAuthorId, userId)) {
          throw new CourseActionException(
              HttpStatus.FORBIDDEN,
              "Bạn không có quyền trả lời trao đổi riêng của học viên khác.");
        }
      }
    }

    if (lesson != null && parent == null && canModerate(course, author)) {
      throw new CourseActionException(
          HttpStatus.BAD_REQUEST,
          "Để trao đổi riêng với học viên, vui lòng nhấn \"Trả lời\" dưới câu hỏi của học viên đó.");
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
      throw new CourseActionException(
          HttpStatus.UNAUTHORIZED, "Vui lòng đăng nhập để thích bình luận.");
    }
    CourseComment comment = commentRepository.findById(commentId)
        .filter(c -> ACTIVE.equalsIgnoreCase(c.getStatus()))
        .orElseThrow(() -> new CourseActionException(
            HttpStatus.NOT_FOUND, "Không tìm thấy bình luận."));
    Users user = userRepository.findById(userId)
        .orElseThrow(() -> new CourseActionException(
            HttpStatus.UNAUTHORIZED, "Vui lòng đăng nhập lại."));

    if (comment.getLesson() != null && !canModerate(comment.getCourse(), user)) {
      CourseComment root = comment.getParent() != null ? comment.getParent() : comment;
      Integer rootAuthorId = root.getAuthor() != null ? root.getAuthor().getUserId() : null;
      if (!Objects.equals(rootAuthorId, userId)) {
        throw new CourseActionException(
            HttpStatus.FORBIDDEN,
            "Bạn không có quyền tương tác với trao đổi riêng của học viên khác.");
      }
    }

    Optional<CourseCommentLike> existing = likeRepository
        .findByComment_CommentIdAndUser_UserId(commentId, userId);
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
        .orElseThrow(() -> new CourseActionException(
            HttpStatus.NOT_FOUND, "Không tìm thấy bình luận."));
    Users currentUser = userRepository.findById(userId)
        .orElseThrow(() -> new CourseActionException(
            HttpStatus.UNAUTHORIZED, "Vui lòng đăng nhập lại."));

    if (!canModerate(comment.getCourse(), currentUser)) {
      throw new CourseActionException(
          HttpStatus.FORBIDDEN,
          "Chỉ giảng viên khóa học hoặc quản trị viên mới có quyền ghim bình luận.");
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
        .orElseThrow(() -> new CourseActionException(
            HttpStatus.NOT_FOUND, "Không tìm thấy bình luận."));
    Users currentUser = userRepository.findById(userId)
        .orElseThrow(() -> new CourseActionException(
            HttpStatus.UNAUTHORIZED, "Vui lòng đăng nhập lại."));

    boolean isAuthor = comment.getAuthor() != null
        && Objects.equals(comment.getAuthor().getUserId(), userId);
    if (!isAuthor && !canModerate(comment.getCourse(), currentUser)) {
      throw new CourseActionException(
          HttpStatus.FORBIDDEN, "Bạn không có quyền xóa bình luận này.");
    }

    comment.setStatus(DELETED);
    comment.setUpdatedAt(LocalDateTime.now());
    return commentRepository.save(comment);
  }

  private void sortRootComments(List<CourseComment> roots, String sort) {
    if ("popular".equalsIgnoreCase(sort)) {
      roots.sort(Comparator
          .comparing((CourseComment c) -> Boolean.TRUE.equals(c.getPinned())).reversed()
          .thenComparing(
              (CourseComment c) -> c.getLikeCount() != null ? c.getLikeCount() : 0,
              Comparator.reverseOrder())
          .thenComparing(
              CourseComment::getCreatedAt,
              Comparator.nullsLast(Comparator.reverseOrder())));
    } else if ("oldest".equalsIgnoreCase(sort)) {
      roots.sort(Comparator
          .comparing((CourseComment c) -> Boolean.TRUE.equals(c.getPinned())).reversed()
          .thenComparing(
              CourseComment::getCreatedAt,
              Comparator.nullsLast(Comparator.naturalOrder())));
    }
  }

  private List<CourseCommentView> buildCommentTree(
      Course course,
      List<CourseComment> roots,
      List<CourseComment> allReplies,
      Integer currentUserId) {
    Users currentUser = currentUserId != null
        ? userRepository.findById(currentUserId).orElse(null)
        : null;
    boolean isModerator = canModerate(course, currentUser);

    List<Integer> allIds = new ArrayList<>();
    for (CourseComment r : roots) {
      allIds.add(r.getCommentId());
    }
    for (CourseComment rep : allReplies) {
      allIds.add(rep.getCommentId());
    }

    Set<Integer> likedIds = new HashSet<>();
    if (currentUserId != null && !allIds.isEmpty()) {
      likedIds.addAll(likeRepository.findLikedCommentIdsByUser(currentUserId, allIds));
    }

    Map<Integer, List<CourseCommentView>> repliesByParentId = new HashMap<>();
    for (CourseComment rep : allReplies) {
      if (rep.getParent() != null) {
        Integer parentId = rep.getParent().getCommentId();
        CourseCommentView repView = toView(
            course, rep, currentUserId, isModerator, likedIds.contains(rep.getCommentId()));
        repliesByParentId.computeIfAbsent(parentId, k -> new ArrayList<>()).add(repView);
      }
    }

    List<CourseCommentView> result = new ArrayList<>();
    for (CourseComment root : roots) {
      CourseCommentView rootView = toView(
          course, root, currentUserId, isModerator, likedIds.contains(root.getCommentId()));
      List<CourseCommentView> childViews = repliesByParentId.getOrDefault(
          root.getCommentId(), List.of());
      rootView.setReplies(childViews);
      result.add(rootView);
    }
    return result;
  }

  private CourseCommentView toView(
      Course course,
      CourseComment c,
      Integer currentUserId,
      boolean isModerator,
      boolean likedByMe) {
    Users author = c.getAuthor();
    Integer authorId = author != null ? author.getUserId() : null;
    String authorName = author != null && author.getFullName() != null
        ? author.getFullName()
        : "Người dùng EduSphere";
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

    boolean canDelete = isModerator
        || (currentUserId != null && Objects.equals(currentUserId, authorId));

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
        String rName = ur.getRoles().getRoleName().toUpperCase(Locale.ROOT);
        if ("ADMINISTRATOR".equals(rName)) {
          isAdmin = true;
        }
        if ("INSTRUCTOR".equals(rName)) {
          isInstructor = true;
        }
      }
    }
    if (isAdmin) {
      return "ADMINISTRATOR";
    }
    if (isInstructor) {
      return "INSTRUCTOR";
    }
    return "STUDENT";
  }

  private boolean canModerate(Course course, Users user) {
    if (user == null || course == null) {
      return false;
    }
    if (course.getInstructor() != null
        && Objects.equals(course.getInstructor().getUserId(), user.getUserId())) {
      return true;
    }
    if (user.getUserRolesCollection() != null) {
      for (UserRoles ur : user.getUserRolesCollection()) {
        if (ur.getRoles() != null
            && "ADMINISTRATOR".equalsIgnoreCase(ur.getRoles().getRoleName())) {
          return true;
        }
      }
    }
    return false;
  }
}
