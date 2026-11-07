package com.edusphere.repository.course;

import com.edusphere.entity.course.BankQuestion;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface BankQuestionRepository extends JpaRepository<BankQuestion, Integer> {

    List<BankQuestion> findByBank_BankIdOrderByCreatedAtDesc(Integer bankId);

    List<BankQuestion> findByBank_BankIdAndCategory_CategoryIdOrderByCreatedAtDesc(Integer bankId, Integer categoryId);

    Optional<BankQuestion> findByBankQuestionIdAndBank_BankId(Integer questionId, Integer bankId);

    @Modifying
    @Query("DELETE FROM BankQuestion q WHERE q.bankQuestionId = :questionId AND q.bank.bankId = :bankId")
    int deleteByQuestionIdAndBankId(@Param("questionId") Integer questionId, @Param("bankId") Integer bankId);

    long countByBank_BankId(Integer bankId);

    long countByBank_BankIdAndCategory_CategoryId(Integer bankId, Integer categoryId);

    @Query(value = "SELECT TOP (:count) * FROM bank_questions WHERE bank_id = :bankId ORDER BY NEWID()", nativeQuery = true)
    List<BankQuestion> findRandomByBank(@Param("bankId") Integer bankId, @Param("count") int count);

    @Query(value = "SELECT TOP (:count) * FROM bank_questions WHERE bank_id = :bankId AND category_id = :categoryId ORDER BY NEWID()", nativeQuery = true)
    List<BankQuestion> findRandomByBankAndCategory(@Param("bankId") Integer bankId, @Param("categoryId") Integer categoryId, @Param("count") int count);

    @Query(value = "SELECT TOP (:count) * FROM bank_questions WHERE bank_id = :bankId AND difficulty_level = :difficulty ORDER BY NEWID()", nativeQuery = true)
    List<BankQuestion> findRandomByBankAndDifficulty(@Param("bankId") Integer bankId, @Param("difficulty") String difficulty, @Param("count") int count);
}

