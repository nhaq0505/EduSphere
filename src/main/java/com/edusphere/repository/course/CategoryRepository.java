package com.edusphere.repository.course;

import com.edusphere.entity.course.Category;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

public interface CategoryRepository extends JpaRepository<Category, Integer> {

    List<Category> findByStatusOrderByNameAsc(String status);
}
