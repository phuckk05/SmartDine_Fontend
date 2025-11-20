package com.smartdine.services;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.smartdine.models.OrderItem;
import com.smartdine.repository.OrderItemRepository;

import jakarta.transaction.Transactional;

@Service
public class OrderItemService {
    @Autowired
    private OrderItemRepository orderItemRepository;

    // Thêm order item
    @Transactional
    public OrderItem addOrderItem(OrderItem orderItem) {
        return orderItemRepository.save(orderItem);
    }

    // Thêm danh sách order items
    @Transactional
    public List<OrderItem> addOrderItems(List<OrderItem> orderItems) {
        return orderItemRepository.saveAll(orderItems);
    }

    // Lấy danh sách OrderItem theo các orderId
    public List<OrderItem> getOrderItemsByOrderIds(List<Integer> orderIds) {
        if (orderIds == null || orderIds.isEmpty()) {
            return new ArrayList<>();
        }
        Set<Integer> uniqueIds = new LinkedHashSet<>(orderIds);
        return orderItemRepository.findByOrderIdIn(new ArrayList<>(uniqueIds)).stream()
                .sorted(Comparator.comparing(OrderItem::getCreatedAt))
                .collect(Collectors.toList());
    }

    // Lấy danh sách OrderItem theo từng orderId
    public List<OrderItem> getOrderItemsByOrderId(Integer orderId) {
        if (orderId == null) {
            return new ArrayList<>();
        }
        return orderItemRepository.findByOrderId(orderId).stream()
                .sorted(Comparator.comparing(OrderItem::getCreatedAt))
                .collect(Collectors.toList());
    }

    // Cập nhật trạng thái của order item
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

    // Cập nhật số lượng của order item
    public OrderItem updateOrderItemQuantity(Integer id, Integer newQuantity) {
        OrderItem orderItem = orderItemRepository.findById(id).orElse(null);
        if (orderItem == null) {
            throw new IllegalArgumentException("OrderItem not found with id: " + id);
        }
        if (newQuantity < 0) {
            throw new IllegalArgumentException("Quantity cannot be negative");
        }
        orderItem.setQuantity(newQuantity);
        // Nếu số lượng = 0, đặt status = 4 (hủy)
        if (newQuantity == 0) {
            orderItem.setStatusId(4);
        }
        return orderItemRepository.save(orderItem);
    }

}
