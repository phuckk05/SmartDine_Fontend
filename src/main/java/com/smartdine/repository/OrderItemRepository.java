package com.smartdine.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

import com.smartdine.models.OrderItem;

public interface OrderItemRepository extends JpaRepository<OrderItem, Integer> {
    List<OrderItem> findByOrderId(Integer orderId);
}