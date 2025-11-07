package com.smartdine.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

import com.smartdine.models.Category;

public interface CategoryRepository extends JpaRepository<Category, Integer> {
    List<Category> findByCompanyId(Integer companyId);

    List<Category> findByCompanyIdAndStatusId(Integer companyId, Integer statusId);
}
