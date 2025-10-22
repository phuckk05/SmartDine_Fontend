package com.smartdine.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import com.smartdine.models.status.CategoryStatus;

public interface CategoryStatusRepository extends JpaRepository<CategoryStatus, Integer> {
}
