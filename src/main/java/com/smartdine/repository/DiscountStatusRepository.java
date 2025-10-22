package com.smartdine.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import com.smartdine.models.status.DiscountStatus;

public interface DiscountStatusRepository extends JpaRepository<DiscountStatus, Integer> {
}
