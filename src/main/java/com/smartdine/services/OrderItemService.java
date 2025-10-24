package com.smartdine.services;

import java.time.LocalDate;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.smartdine.models.OrderItem;
import com.smartdine.repository.OrderItemRepository;

@Service
public class OrderItemService {
    @Autowired
    private OrderItemRepository orderItemRepository;

    // Lấy danh sách OrderItem theo orderId ngày hôm nay
    public List<OrderItem> getOrderItemsByOrderId(Integer orderId) {
        LocalDate today = LocalDate.now();
        LocalDate startOfDay = today.atStartOfDay().toLocalDate();
        LocalDate endOfDay = today.atTime(23, 59, 59).toLocalDate();
        return orderItemRepository.findByOrderIdAndCreatedAtBetween(orderId, startOfDay, endOfDay);
    }

    // Cap̉̀ nhật trạng thái của order item
    public OrderItem updateOrderItemStatus(Integer id, Integer statusId) {
        OrderItem orderItem = orderItemRepository.findById(id).orElse(null);
        if (orderItem == null) {
            throw new IllegalArgumentException("OrderItem not found with id: " + id);
        }
        orderItem.setStatusId(statusId);
        return orderItemRepository.save(orderItem);
    }

    // Cập nhật người đã phục vụ món lên
    public OrderItem updateServedBy(Integer id, Integer servedBy) {
        OrderItem orderItem = orderItemRepository.findById(id).orElse(null);
        if (orderItem == null) {
            throw new IllegalArgumentException("OrderItem not found with id: " + id);
        }
        orderItem.setServedBy(servedBy);
        return orderItemRepository.save(orderItem);
    }
}