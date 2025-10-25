package com.smartdine.services;

import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.smartdine.models.OrderItem;
import com.smartdine.repository.OrderItemRepository;

@Service
public class OrderItemService {
    @Autowired
    private OrderItemRepository orderItemRepository;

    // Lấy danh sách OrderItem theo các orderId kèm thông tin món và bàn
    public List<OrderItem> getOrderItemsByOrderIds(List<Integer> orderIds) {
        if (orderIds == null || orderIds.isEmpty()) {
            return List.of();
        }
        Set<Integer> uniqueIds = new LinkedHashSet<>(orderIds);
        return orderItemRepository.findDetailedByOrderIds(List.copyOf(uniqueIds));
    }

    // Cập nhật trạng thái của order item
    public OrderItem updateOrderItemStatus(Integer id, Integer statusId) {
        OrderItem orderItem = orderItemRepository.findById(id).orElse(null);
        if (orderItem == null) {
            throw new IllegalArgumentException("OrderItem not found with id: " + id);
        }
        orderItem.setStatusId(statusId);
        orderItemRepository.save(orderItem);
        return orderItemRepository.findDetailedById(id);
    }

    // Cập nhật người đã phục vụ món lên
    public OrderItem updateServedBy(Integer id, Integer servedBy) {
        OrderItem orderItem = orderItemRepository.findById(id).orElse(null);
        if (orderItem == null) {
            throw new IllegalArgumentException("OrderItem not found with id: " + id);
        }
        orderItem.setServedBy(servedBy);
        orderItemRepository.save(orderItem);
        return orderItemRepository.findDetailedById(id);
    }
}