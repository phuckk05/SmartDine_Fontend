package com.smartdine.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import com.smartdine.models.status.CompanyPaymentMethodStatus;

public interface CompanyPaymentMethodStatusRepository
                extends JpaRepository<CompanyPaymentMethodStatus, Integer> {
}
