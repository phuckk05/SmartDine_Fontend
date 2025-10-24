package com.smartdine.repository;

import java.time.LocalDate;
import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

import com.smartdine.models.OrderItem;

public interface OrderItemRepository extends JpaRepository<OrderItem, Integer> {
    // Lấy danh sách OrderItem theo orderId ngày hôm nay
    List<OrderItem> findByOrderIdAndCreatedAtBetween(Integer orderId, LocalDate startOfDay, LocalDate endOfDay);

}