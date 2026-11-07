package com.edusphere.entity.course;

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
import jakarta.persistence.Table;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@Entity
@Table(name = "questions")
public class Question {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "question_id")
    private Integer questionId;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "quiz_id", referencedColumnName = "quiz_id", nullable = false)
    private Quiz quiz;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "bank_question_id", referencedColumnName = "bank_question_id")
    private BankQuestion bankQuestion;

    @Column(name = "content", nullable = false, columnDefinition = "nvarchar(max)")
    private String content;

    @Column(name = "image_url", length = 500)
    private String imageUrl;

    @Column(name = "video_url", length = 500)
    private String videoUrl;

    /** SINGLE_CHOICE / MULTIPLE_CHOICE / TRUE_FALSE / SHORT_ANSWER / ESSAY */
    @Column(name = "type", nullable = false, length = 30)
    private String type;

    @Column(name = "score", nullable = false, precision = 10, scale = 2)
    private BigDecimal score = BigDecimal.valueOf(1);

    @Column(name = "order_index", nullable = false)
    private Integer orderIndex = 1;

    @Column(name = "correct_answer", columnDefinition = "nvarchar(max)")
    private String correctAnswer;

    @Column(name = "explanation", columnDefinition = "nvarchar(max)")
    private String explanation;

    @Column(name = "sample_essay_answer", columnDefinition = "nvarchar(max)")
    private String sampleEssayAnswer;

    @OneToMany(mappedBy = "question", cascade = CascadeType.ALL, orphanRemoval = true, fetch = FetchType.LAZY)
    @OrderBy("orderIndex ASC")
    private List<AnswerOption> options = new ArrayList<>();
}
