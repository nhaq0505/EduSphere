package com.edusphere.service.course;

import org.springframework.http.HttpStatus;

public class CourseActionException extends RuntimeException {
    private final HttpStatus status;

    public CourseActionException(HttpStatus status, String message) {
        super(message);
        this.status = status;
    }

    public HttpStatus getStatus() { return status; }
}
