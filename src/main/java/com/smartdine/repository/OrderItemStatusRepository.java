package com.smartdine.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import com.smartdine.models.status.OrderItemStatus;

public interface OrderItemStatusRepository extends JpaRepository<OrderItemStatus, Integer> {
}
