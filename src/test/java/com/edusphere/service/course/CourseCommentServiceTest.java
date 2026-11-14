package com.edusphere.service.course;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

import com.edusphere.dto.course.CourseRatingSummary;
import com.edusphere.entity.account.Users;
import com.edusphere.entity.course.Course;
import com.edusphere.entity.course.CourseComment;
import com.edusphere.repository.account.UserRepository;
import com.edusphere.repository.course.CourseCommentLikeRepository;
import com.edusphere.repository.course.CourseCommentRepository;
import com.edusphere.repository.course.CourseRepository;
import com.edusphere.repository.course.LessonRepository;

import java.util.List;
import java.util.Map;
import java.util.Optional;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.http.HttpStatus;

/**
 * Unit tests kiểm thử CourseCommentService (bình luận khóa học, đánh giá sao và hỏi đáp bài giảng).
 */
class CourseCommentServiceTest {

  private CourseCommentRepository commentRepository;
  private CourseCommentLikeRepository likeRepository;
  private CourseRepository courseRepository;
  private LessonRepository lessonRepository;
  private UserRepository userRepository;
  private CourseCommentService service;

  @BeforeEach
  void setUp() {
    commentRepository = mock(CourseCommentRepository.class);
    likeRepository = mock(CourseCommentLikeRepository.class);
    courseRepository = mock(CourseRepository.class);
    lessonRepository = mock(LessonRepository.class);
    userRepository = mock(UserRepository.class);

    service = new CourseCommentService(
        commentRepository,
        likeRepository,
        courseRepository,
        lessonRepository,
        userRepository);
  }

  @Test
  void getCourseRatingSummary_calculatesStarDistributionAndAverageCorrectly() {
    CourseComment c1 = new CourseComment();
    c1.setRating(5);
    CourseComment c2 = new CourseComment();
    c2.setRating(4);
    CourseComment c3 = new CourseComment();
    c3.setRating(5);

    when(commentRepository.findByCourse_CourseIdAndLessonIsNullAndParentIsNullAndStatusOrderByPinnedDescCreatedAtDesc(
        12, "ACTIVE"))
        .thenReturn(List.of(c1, c2, c3));
    when(commentRepository.countByCourse_CourseIdAndLessonIsNullAndStatus(12, "ACTIVE"))
        .thenReturn(5L);

    CourseRatingSummary summary = service.getCourseRatingSummary(12);
    assertNotNull(summary);
    assertEquals(4.7, summary.getAverageRating());
    assertEquals(3L, summary.getRatingCount());
    assertEquals(5L, summary.getTotalComments());
    assertEquals(2, summary.getFiveStarCount());
    assertEquals(1, summary.getFourStarCount());
  }

  @Test
  void addComment_validatesEmptyContentAndSavesRootCommentWithRating() {
    Users author = new Users();
    author.setUserId(20);
    author.setFullName("Lê Văn Tùng");

    Users instructor = new Users();
    instructor.setUserId(1);

    Course course = new Course();
    course.setCourseId(12);
    course.setInstructor(instructor);

    when(userRepository.findById(20)).thenReturn(Optional.of(author));
    when(courseRepository.findById(12)).thenReturn(Optional.of(course));
    when(commentRepository.save(any(CourseComment.class))).thenAnswer(inv -> {
      CourseComment c = inv.getArgument(0);
      c.setCommentId(300);
      return c;
    });

    CourseActionException emptyEx = assertThrows(
        CourseActionException.class,
        () -> service.addComment(12, null, null, 20, "   ", 5));
    assertEquals(HttpStatus.BAD_REQUEST, emptyEx.getStatus());

    CourseComment saved = service.addComment(
        12, null, null, 20, "Khóa học rất dễ hiểu và thực tế!", 5);
    assertNotNull(saved);
    assertEquals(300, saved.getCommentId());
    assertEquals(5, saved.getRating());
    assertEquals("ACTIVE", saved.getStatus());
  }

  @Test
  void buildCourseDiscussionStats_returnsThreadAndInstructorReplyCounts() {
    Users instructor = new Users();
    instructor.setUserId(1);

    Course course = new Course();
    course.setCourseId(15);
    course.setInstructor(instructor);

    CourseComment root = new CourseComment();
    root.setCommentId(1);
    root.setPinned(true);

    CourseComment replyByInstructor = new CourseComment();
    replyByInstructor.setCommentId(2);
    replyByInstructor.setAuthor(instructor);

    when(courseRepository.findById(15)).thenReturn(Optional.of(course));
    when(commentRepository.findByCourse_CourseIdAndLessonIsNullAndParentIsNullAndStatusOrderByPinnedDescCreatedAtDesc(
        15, "ACTIVE"))
        .thenReturn(List.of(root));
    when(commentRepository.findByCourse_CourseIdAndLessonIsNullAndParentIsNotNullAndStatusOrderByCreatedAtAsc(
        15, "ACTIVE"))
        .thenReturn(List.of(replyByInstructor));

    Map<String, Object> stats = service.buildCourseDiscussionStats(15);
    assertTrue(stats.containsKey("rootThreads"));
    assertEquals(1, stats.get("rootThreads"));
    assertEquals(1, stats.get("pinnedThreads"));
    assertEquals(1, stats.get("instructorReplies"));
  }
}
