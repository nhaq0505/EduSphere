package com.edusphere.entity.course;

import com.edusphere.entity.account.Users;
import jakarta.persistence.CascadeType;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.OneToMany;
import jakarta.persistence.OrderBy;
import jakarta.persistence.PrePersist;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Getter
@Setter
@NoArgsConstructor
@Entity
@Table(name = "bank_questions")
public class BankQuestion {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "bank_question_id")
    private Integer bankQuestionId;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "bank_id", referencedColumnName = "bank_id", nullable = false)
    private QuestionBank bank;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "category_id", referencedColumnName = "category_id")
    private BankCategory category;

    @Column(name = "content", nullable = false, columnDefinition = "nvarchar(max)")
    private String content;

    @Column(name = "image_url", length = 500)
    private String imageUrl;

    @Column(name = "video_url", length = 500)
    private String videoUrl;

    /** SINGLE_CHOICE, MULTIPLE_CHOICE, TRUE_FALSE, SHORT_ANSWER, ESSAY */
    @Column(name = "type", nullable = false, length = 30)
    private String type = "SINGLE_CHOICE";

    /** EASY, MEDIUM, HARD */
    @Column(name = "difficulty_level", nullable = false, length = 20)
    private String difficultyLevel = "MEDIUM";

    @Column(name = "default_score", nullable = false, precision = 5, scale = 2)
    private BigDecimal defaultScore = BigDecimal.valueOf(1.0);

    @Column(name = "correct_answer", columnDefinition = "nvarchar(max)")
    private String correctAnswer;

    @Column(name = "explanation", columnDefinition = "nvarchar(max)")
    private String explanation;

    @Column(name = "sample_essay_answer", columnDefinition = "nvarchar(max)")
    private String sampleEssayAnswer;

    @Column(name = "tags", length = 500)
    private String tags;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "created_by", referencedColumnName = "user_id", nullable = false)
    private Users createdBy;

    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt;

    @OneToMany(mappedBy = "bankQuestion", cascade = CascadeType.ALL, orphanRemoval = true, fetch = FetchType.LAZY)
    @OrderBy("orderIndex ASC")
    private List<BankAnswerOption> options = new ArrayList<>();

    @PrePersist
    protected void onCreate() {
        if (createdAt == null) createdAt = LocalDateTime.now();
    }
}

