package com.edusphere.entity.course;

import com.edusphere.entity.account.Users;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;

import java.time.LocalDateTime;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@Entity
@Table(name = "course_reviews")
public class CourseReview {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "review_id")
    private Integer reviewId;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "course_id", referencedColumnName = "course_id", nullable = false)
    private Course course;

    @Column(name = "course_version", nullable = false)
    private Integer courseVersion;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "admin_id", referencedColumnName = "user_id", nullable = false)
    private Users admin;

    @Column(name = "decision", nullable = false, length = 20)
    private String decision;

    @Column(name = "comment", length = 2000, columnDefinition = "nvarchar(2000)")
    private String comment;

    @Column(name = "reviewed_at", nullable = false)
    private LocalDateTime reviewedAt;

    @jakarta.persistence.PrePersist
    private void setReviewedAt() {
        if (reviewedAt == null) reviewedAt = LocalDateTime.now();
    }
}
