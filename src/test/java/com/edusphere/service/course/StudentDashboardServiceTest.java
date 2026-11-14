package com.edusphere.service.course;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyInt;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

import com.edusphere.dto.course.EnrolledCourseView;
import com.edusphere.dto.course.StudentDashboardView;
import com.edusphere.entity.course.Lesson;
import com.edusphere.repository.course.CourseRatingRepository;
import com.edusphere.repository.course.LessonRepository;
import com.edusphere.repository.course.StudentStudyLogRepository;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

/**
 * Unit tests kiểm thử StudentDashboardService và StudentDashboardView.
 */
class StudentDashboardServiceTest {

  private CourseManagementService courseManagementService;
  private StudentStudyLogRepository studyLogRepository;
  private CourseRatingRepository ratingRepository;
  private LessonRepository lessonRepository;
  private StudentDashboardService dashboardService;

  @BeforeEach
  void setUp() {
    courseManagementService = mock(CourseManagementService.class);
    studyLogRepository = mock(StudentStudyLogRepository.class);
    ratingRepository = mock(CourseRatingRepository.class);
    lessonRepository = mock(LessonRepository.class);

    dashboardService = new StudentDashboardService(
        courseManagementService,
        studyLogRepository,
        ratingRepository,
        lessonRepository);
  }

  @Test
  void getDashboard_computesStudyHoursStreaksMilestonesAndChartJson() {
    EnrolledCourseView enrolled = new EnrolledCourseView(
        10,
        "Lập trình Java Core & OOP",
        "TS. Lê Minh",
        "ACTIVE",
        "PUBLISHED");
    enrolled.setThumbnailUrl("/assets/img/java.png");
    enrolled.setProgressPercent(50);
    enrolled.setCompletedLessons(1);
    enrolled.setTotalLessons(2);
    enrolled.setEnrolledAt(LocalDateTime.now().minusDays(5));

    Lesson l1 = new Lesson();
    l1.setLessonId(101);
    l1.setStatus("PUBLISHED");

    Lesson l2 = new Lesson();
    l2.setLessonId(102);
    l2.setStatus("PUBLISHED");

    when(courseManagementService.enrolledCourses(7))
        .thenReturn(List.of(enrolled));
    when(lessonRepository.findByCourse_CourseIdAndStatusOrderByOrderIndexAsc(10, "PUBLISHED"))
        .thenReturn(List.of(l1, l2));
    when(studyLogRepository.sumDurationSecondsByStudentId(7))
        .thenReturn(9000L); // 2.5h
    when(studyLogRepository.sumDurationSecondsByStudentIdGroupByCourse(7))
        .thenReturn(List.<Object[]>of(new Object[]{10, 5400L}));
    when(studyLogRepository.sumDailyDurationSeconds(
        anyInt(), any(LocalDate.class), any(LocalDate.class)))
        .thenReturn(List.of(
            new Object[]{LocalDate.now().minusDays(1), 3600L},
            new Object[]{LocalDate.now(), 5400L}));

    StudentDashboardView view = dashboardService.getDashboard(7, "Nguyễn Trọng Thiên");

    assertNotNull(view);
    assertEquals("Nguyễn Trọng Thiên", view.getStudentName());
    assertEquals(1, view.getEnrolledCoursesCount());
    assertEquals(1, view.getInProgressCoursesCount());
    assertEquals(0, view.getCompletedCoursesCount());
    assertEquals(2, view.getCurrentStreakDays());
    assertTrue(view.getLongestStreakDays() >= 2);
    assertTrue(view.isHasActiveStreak());
    assertNotNull(view.getChart7dLabelsJson());
    assertNotNull(view.getChart7dValuesJson());
    assertNotNull(view.getMilestones());
    assertFalse(view.getMilestones().isEmpty());
    assertNotNull(view.getHabitInsights());
    assertFalse(view.getHabitInsights().isEmpty());
  }
}
