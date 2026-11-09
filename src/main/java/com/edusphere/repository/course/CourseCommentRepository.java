package com.edusphere.repository.course;

import com.edusphere.entity.course.CourseComment;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Collection;
import java.util.List;

public interface CourseCommentRepository extends JpaRepository<CourseComment, Integer> {

    List<CourseComment> findByCourse_CourseIdAndLessonIsNullAndParentIsNullAndStatusOrderByPinnedDescCreatedAtDesc(
            Integer courseId, String status);

    List<CourseComment> findByCourse_CourseIdAndLesson_LessonIdAndParentIsNullAndStatusOrderByPinnedDescCreatedAtDesc(
            Integer courseId, Integer lessonId, String status);

    List<CourseComment> findByCourse_CourseIdAndLessonIsNullAndParentIsNotNullAndStatusOrderByCreatedAtAsc(
            Integer courseId, String status);

    List<CourseComment> findByCourse_CourseIdAndLesson_LessonIdAndParentIsNotNullAndStatusOrderByCreatedAtAsc(
            Integer courseId, Integer lessonId, String status);

    List<CourseComment> findByParent_CommentIdInAndStatusOrderByCreatedAtAsc(
            Collection<Integer> parentIds, String status);

    List<CourseComment> findByParent_CommentIdAndStatusOrderByCreatedAtAsc(
            Integer parentId, String status);

    long countByCourse_CourseIdAndLessonIsNullAndStatus(Integer courseId, String status);

    long countByCourse_CourseIdAndLesson_LessonIdAndStatus(Integer courseId, Integer lessonId, String status);

    List<CourseComment> findByCourse_CourseIdAndRatingIsNotNullAndStatus(Integer courseId, String status);

    @Query("SELECT AVG(CAST(c.rating AS double)) FROM CourseComment c WHERE c.course.courseId = :courseId AND c.lesson IS NULL AND c.parent IS NULL AND c.rating IS NOT NULL AND c.status = 'ACTIVE'")
    Double findAverageRatingByCourseId(@Param("courseId") Integer courseId);

    @Query("SELECT COUNT(c) FROM CourseComment c WHERE c.course.courseId = :courseId AND c.lesson IS NULL AND c.parent IS NULL AND c.rating IS NOT NULL AND c.status = 'ACTIVE'")
    long countRatingsByCourseId(@Param("courseId") Integer courseId);
}
