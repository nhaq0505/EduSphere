package com.edusphere.dto.course;

import java.util.ArrayList;
import java.util.List;

import com.edusphere.entity.course.Lesson;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class CourseSectionView {
    private Integer sectionId;
    private Integer courseId;
    private String title;
    private String description;
    private Integer orderIndex;
    private List<Lesson> lessons = new ArrayList<>();

    public CourseSectionView() {}

    public CourseSectionView(Integer sectionId, Integer courseId, String title, String description, Integer orderIndex) {
        this.sectionId = sectionId;
        this.courseId = courseId;
        this.title = title;
        this.description = description;
        this.orderIndex = orderIndex;
    }

    public int getLessonCount() {
        return lessons != null ? lessons.size() : 0;
    }
}

