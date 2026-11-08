package com.edusphere.repository.course;

import com.edusphere.entity.course.BankCategory;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface BankCategoryRepository extends JpaRepository<BankCategory, Integer> {

    List<BankCategory> findByBank_BankIdOrderByOrderIndexAsc(Integer bankId);

    Optional<BankCategory> findByCategoryIdAndBank_BankId(Integer categoryId, Integer bankId);
}

