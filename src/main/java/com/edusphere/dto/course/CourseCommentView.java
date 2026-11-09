package com.edusphere.dto.course;

import lombok.Builder;
import lombok.Getter;
import lombok.Setter;

import java.time.Duration;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;

@Getter
@Setter
@Builder
public class CourseCommentView {

    private static final DateTimeFormatter DT_FMT = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");

    private Integer commentId;
    private Integer courseId;
    private Integer lessonId;
    private String lessonTitle;
    private Integer parentCommentId;

    private Integer authorId;
    private String authorName;
    private String authorAvatarUrl;
    private String authorRoleBadge;
    private String authorRoleCode;
    private boolean courseInstructor;

    private String content;
    private Integer rating;
    private int likeCount;
    private boolean likedByMe;
    private boolean pinned;
    private boolean canDelete;
    private boolean canPin;

    private LocalDateTime createdAt;

    @Builder.Default
    private List<CourseCommentView> replies = new ArrayList<>();

    public String getAuthorInitials() {
        if (authorName == null || authorName.isBlank()) {
            return "HV";
        }
        String[] parts = authorName.trim().split("\\s+");
        if (parts.length == 1) {
            return parts[0].substring(0, Math.min(2, parts[0].length())).toUpperCase();
        }
        String first = parts[0].substring(0, 1);
        String last = parts[parts.length - 1].substring(0, 1);
        return (first + last).toUpperCase();
    }

    public String getRelativeTimeLabel() {
        if (createdAt == null) {
            return "Vừa xong";
        }
        Duration diff = Duration.between(createdAt, LocalDateTime.now());
        long seconds = diff.getSeconds();
        if (seconds < 60) {
            return "Vừa xong";
        }
        long minutes = seconds / 60;
        if (minutes < 60) {
            return minutes + " phút trước";
        }
        long hours = minutes / 60;
        if (hours < 24) {
            return hours + " giờ trước";
        }
        long days = hours / 24;
        if (days < 30) {
            return days + " ngày trước";
        }
        return createdAt.format(DT_FMT);
    }
}
