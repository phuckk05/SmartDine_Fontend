package com.smartdine.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import com.smartdine.models.status.PaymentStatus;

public interface PaymentStatusRepository extends JpaRepository<PaymentStatus, Integer> {
}
