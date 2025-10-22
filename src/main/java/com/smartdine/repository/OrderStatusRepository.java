package com.smartdine.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import com.smartdine.models.OrderStatus;

public interface OrderStatusRepository extends JpaRepository<OrderStatus, Integer> {
}
