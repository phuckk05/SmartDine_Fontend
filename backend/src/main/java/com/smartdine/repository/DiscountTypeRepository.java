package com.smartdine.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import com.smartdine.models.DiscountType;

public interface DiscountTypeRepository extends JpaRepository<DiscountType, Integer> {
}
