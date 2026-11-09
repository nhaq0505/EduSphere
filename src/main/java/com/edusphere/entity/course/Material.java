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
import jakarta.persistence.PrePersist;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDateTime;

@Getter
@Setter
@NoArgsConstructor
@Entity
@Table(name = "materials")
public class Material {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "material_id")
    private Integer materialId;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "lesson_id", referencedColumnName = "lesson_id", nullable = false)
    private Lesson lesson;

    @Column(name = "title", nullable = false, length = 255, columnDefinition = "nvarchar(255)")
    private String title;

    @Column(name = "type", nullable = false, length = 20)
    private String type;

    @Column(name = "file_url", nullable = false, length = 2048)
    private String fileUrl;

    @Column(name = "original_file_name", length = 255, columnDefinition = "nvarchar(255)")
    private String originalFileName;

    @Column(name = "content_type", length = 100)
    private String contentType;

    @Column(name = "size_bytes")
    private Long sizeBytes;

    @Column(name = "order_index", nullable = false)
    private Integer orderIndex;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "uploaded_by", referencedColumnName = "user_id", nullable = false)
    private Users uploadedBy;

    @Column(name = "uploaded_at", nullable = false)
    private LocalDateTime uploadedAt;

    @PrePersist
    private void setUploadedAt() {
        if (uploadedAt == null) {
            uploadedAt = LocalDateTime.now();
        }
    }
}
