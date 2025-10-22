package com.smartdine.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import com.smartdine.models.CompanyPaymentMethodStatus;

public interface CompanyPaymentMethodStatusRepository
        extends JpaRepository<CompanyPaymentMethodStatus, Integer> {
}
