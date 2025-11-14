package com.smartdine.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import com.smartdine.models.CompanyPaymentMethod;

public interface CompanyPaymentMethodRepository extends JpaRepository<CompanyPaymentMethod, Integer> {
}
