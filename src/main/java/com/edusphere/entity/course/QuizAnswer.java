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
import jakarta.persistence.Table;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@Entity
@Table(name = "quiz_answers")
public class QuizAnswer {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "answer_id")
    private Integer answerId;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "attempt_id", referencedColumnName = "attempt_id", nullable = false)
    private QuizAttempt attempt;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "quiz_id", referencedColumnName = "quiz_id", nullable = false)
    private Quiz quiz;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "question_id", referencedColumnName = "question_id", nullable = false)
    private Question question;

    @Column(name = "answer_text", columnDefinition = "nvarchar(max)")
    private String answerText;

    @Column(name = "question_content_snapshot", nullable = false, columnDefinition = "nvarchar(max)")
    private String questionContentSnapshot;

    @Column(name = "question_type_snapshot", nullable = false, length = 30)
    private String questionTypeSnapshot;

    @Column(name = "max_score", nullable = false, precision = 10, scale = 2)
    private BigDecimal maxScore;

    @Column(name = "awarded_score", precision = 10, scale = 2)
    private BigDecimal awardedScore;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "graded_by", referencedColumnName = "user_id")
    private Users gradedBy;

    @Column(name = "graded_at")
    private LocalDateTime gradedAt;

    @OneToMany(mappedBy = "answer", cascade = CascadeType.ALL, orphanRemoval = true, fetch = FetchType.LAZY)
    private List<QuizAnswerOption> selectedOptions = new ArrayList<>();
}
