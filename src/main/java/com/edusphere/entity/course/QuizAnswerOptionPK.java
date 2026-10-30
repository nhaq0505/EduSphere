package com.edusphere.entity.course;

import java.io.Serializable;
import java.util.Objects;

import jakarta.persistence.Column;
import jakarta.persistence.Embeddable;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@Embeddable
public class QuizAnswerOptionPK implements Serializable {

    private static final long serialVersionUID = 1L;

    @Column(name = "answer_id")
    private Integer answerId;

    @Column(name = "option_id")
    private Integer optionId;

    public QuizAnswerOptionPK(Integer answerId, Integer optionId) {
        this.answerId = answerId;
        this.optionId = optionId;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof QuizAnswerOptionPK that)) return false;
        return Objects.equals(answerId, that.answerId) && Objects.equals(optionId, that.optionId);
    }

    @Override
    public int hashCode() {
        return Objects.hash(answerId, optionId);
    }
}
