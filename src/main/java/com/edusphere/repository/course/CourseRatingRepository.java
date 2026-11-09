package com.edusphere.repository.course;

import com.edusphere.entity.course.CourseRating;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Collection;
import java.util.List;
import java.util.Optional;

public interface CourseRatingRepository extends JpaRepository<CourseRating, Integer> {

    @Query("""
            select cr from CourseRating cr
            join fetch cr.student
            where cr.course.courseId = :courseId
            order by cr.createdAt desc
            """)
    List<CourseRating> findByCourseIdWithStudentOrderByCreatedAtDesc(@Param("courseId") Integer courseId);

    Optional<CourseRating> findByCourse_CourseIdAndStudent_UserId(Integer courseId, Integer studentId);

    @Query("""
            select cr.course.courseId, avg(cast(cr.rating as double)), count(cr)
            from CourseRating cr
            where cr.course.courseId in :courseIds
            group by cr.course.courseId
            """)
    List<Object[]> summarizeByCourseIds(@Param("courseIds") Collection<Integer> courseIds);
}
