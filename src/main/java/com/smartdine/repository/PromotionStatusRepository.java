package com.smartdine.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import com.smartdine.models.PromotionStatus;

public interface PromotionStatusRepository extends JpaRepository<PromotionStatus, Integer> {
}
