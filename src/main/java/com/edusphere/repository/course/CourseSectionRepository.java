package com.edusphere.repository.course;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.edusphere.entity.course.CourseSection;

@Repository
public interface CourseSectionRepository extends JpaRepository<CourseSection, Integer> {

    List<CourseSection> findByCourse_CourseIdOrderByOrderIndexAsc(Integer courseId);

    Optional<CourseSection> findBySectionIdAndCourse_CourseId(Integer sectionId, Integer courseId);

    long countByCourse_CourseId(Integer courseId);

    void deleteByCourse_CourseId(Integer courseId);
}

