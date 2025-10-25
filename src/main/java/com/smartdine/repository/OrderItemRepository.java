package com.smartdine.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import com.smartdine.models.OrderItem;

public interface OrderItemRepository extends JpaRepository<OrderItem, Integer> {

        List<OrderItem> findByOrderIdIn(List<Integer> orderIds);

        List<OrderItem> findByOrderId(Integer orderId);
}