package com.edusphere.dto;

import lombok.Getter;

@Getter
public class EnrolledCourseView {
    private final Integer courseId;
    private final String title;
    private final String instructorName;
    private final String enrollmentStatus;
    private final String courseStatus;

    public EnrolledCourseView(Integer courseId, String title, String instructorName,
                              String enrollmentStatus, String courseStatus) {
        this.courseId = courseId;
        this.title = title;
        this.instructorName = instructorName;
        this.enrollmentStatus = enrollmentStatus;
        this.courseStatus = courseStatus;
    }
}
