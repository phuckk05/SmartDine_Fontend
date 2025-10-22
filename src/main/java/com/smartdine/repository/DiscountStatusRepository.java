package com.smartdine.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import com.smartdine.models.DiscountStatus;

public interface DiscountStatusRepository extends JpaRepository<DiscountStatus, Integer> {
}
