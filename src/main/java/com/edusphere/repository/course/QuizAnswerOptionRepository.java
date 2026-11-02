package com.edusphere.repository.course;

import com.edusphere.entity.course.QuizAnswerOption;
import com.edusphere.entity.course.QuizAnswerOptionPK;

import java.util.Collection;

import org.springframework.data.jpa.repository.JpaRepository;

public interface QuizAnswerOptionRepository extends JpaRepository<QuizAnswerOption, QuizAnswerOptionPK> {

    void deleteByOption_OptionIdIn(Collection<Integer> optionIds);
}
