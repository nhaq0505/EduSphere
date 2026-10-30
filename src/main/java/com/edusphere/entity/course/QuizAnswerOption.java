package com.edusphere.entity.course;

import jakarta.persistence.Column;
import jakarta.persistence.EmbeddedId;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.MapsId;
import jakarta.persistence.Table;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@Entity
@Table(name = "quiz_answer_options")
public class QuizAnswerOption {

    @EmbeddedId
    private QuizAnswerOptionPK id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @MapsId("answerId")
    @JoinColumn(name = "answer_id", referencedColumnName = "answer_id", nullable = false)
    private QuizAnswer answer;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "question_id", referencedColumnName = "question_id", nullable = false)
    private Question question;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @MapsId("optionId")
    @JoinColumn(name = "option_id", referencedColumnName = "option_id", nullable = false)
    private AnswerOption option;

    @Column(name = "option_content_snapshot", nullable = false, columnDefinition = "nvarchar(max)")
    private String optionContentSnapshot;

    public QuizAnswerOption(QuizAnswer answer, Question question, AnswerOption option) {
        this.id = new QuizAnswerOptionPK(answer.getAnswerId(), option.getOptionId());
        this.answer = answer;
        this.question = question;
        this.option = option;
        this.optionContentSnapshot = option.getContent();
    }
}
