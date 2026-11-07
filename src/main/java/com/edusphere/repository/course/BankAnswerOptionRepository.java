package com.edusphere.repository.course;

import com.edusphere.entity.course.BankAnswerOption;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface BankAnswerOptionRepository extends JpaRepository<BankAnswerOption, Integer> {

    List<BankAnswerOption> findByBankQuestion_BankQuestionIdOrderByOrderIndexAsc(Integer bankQuestionId);

    void deleteByBankQuestion_BankQuestionId(Integer bankQuestionId);

    @org.springframework.data.jpa.repository.Modifying
    @org.springframework.data.jpa.repository.Query("DELETE FROM BankAnswerOption o WHERE o.bankQuestion.bankQuestionId = :bankQuestionId")
    int deleteOptionsByQuestionId(@org.springframework.data.repository.query.Param("bankQuestionId") Integer bankQuestionId);
}

