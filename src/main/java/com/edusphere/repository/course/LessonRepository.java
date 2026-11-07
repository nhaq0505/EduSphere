package com.edusphere.repository.course;

import com.edusphere.entity.course.Lesson;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface LessonRepository extends JpaRepository<Lesson, Integer> {

    List<Lesson> findByCourse_CourseIdAndStatusOrderByOrderIndexAsc(Integer courseId, String status);

    Optional<Lesson> findByLessonIdAndCourse_CourseIdAndStatus(Integer lessonId, Integer courseId, String status);

    Optional<Lesson> findByLessonIdAndCourse_CourseId(Integer lessonId, Integer courseId);

    List<Lesson> findByCourse_CourseIdOrderByOrderIndexAsc(Integer courseId);

    List<Lesson> findBySection_SectionIdOrderByOrderIndexAsc(Integer sectionId);

    List<Lesson> findBySection_SectionIdAndStatusOrderByOrderIndexAsc(Integer sectionId, String status);

    List<Lesson> findByCourse_CourseIdAndSectionIsNullOrderByOrderIndexAsc(Integer courseId);

    List<Lesson> findByCourse_CourseIdAndSectionIsNullAndStatusOrderByOrderIndexAsc(Integer courseId, String status);

    long countByCourse_CourseId(Integer courseId);

    long countByCourse_CourseIdAndStatus(Integer courseId, String status);

    long countBySection_SectionId(Integer sectionId);

    List<Lesson> findByPrerequisiteLesson_LessonId(Integer lessonId);

    List<Lesson> findByBunnyVideoId(String bunnyVideoId);
}
