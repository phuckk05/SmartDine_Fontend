package com.smartdine.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import com.smartdine.models.status.OrderItemStatus;

public interface OrderItemStatusRepository extends JpaRepository<OrderItemStatus, Integer> {
    // Find OrderItemStatus by name
    OrderItemStatus findByName(String name);
    // You can add custom query methods if needed
    
}
