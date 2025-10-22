package com.smartdine.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import com.smartdine.models.CategoryStatus;

public interface CategoryStatusRepository extends JpaRepository<CategoryStatus, Integer> {
}
