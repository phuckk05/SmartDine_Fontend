package com.smartdine.controllers;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.smartdine.models.Order;
import com.smartdine.models.OrderItem;
import com.smartdine.services.OrderItemService;
import com.smartdine.services.OrderServices;

@RestController
@RequestMapping("/api/order-items")
public class OrderItemController {
    private final OrderItemService orderItemServices;
    private final OrderServices orderServices;

    public OrderItemController(OrderItemService orderItemServices, OrderServices orderServices) {
        this.orderItemServices = orderItemServices;
        this.orderServices = orderServices;
    }

    // Save order items
    @PostMapping("/save")
    public ResponseEntity<?> saveOrderItem(@RequestBody List<OrderItem> orderItems) {
        try {
            List<OrderItem> savedOrderItems = orderItemServices.addOrderItems(orderItems);
            return ResponseEntity.ok(savedOrderItems);
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.internalServerError().build();
        }
    }

    // Lấy tất cả order item ngày hôm nay
    @GetMapping("/today/branch/{branchId}")
    public ResponseEntity<List<OrderItem>> getOrderItemsToday(@PathVariable Integer branchId) {
        try {
            List<Order> orders = orderServices.getOrdersByBranchIdToday(branchId);
            List<Integer> orderIds = orders.stream().map(Order::getId).collect(Collectors.toList());
            List<OrderItem> orderItems = orderItemServices.getOrderItemsByOrderIds(orderIds);
            return ResponseEntity.ok(orderItems);
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.internalServerError().build();
        }
    }

    // Lấy danh sách order item theo orderId
    @GetMapping("/order/{orderId}")
    public ResponseEntity<List<OrderItem>> getOrderItemsByOrder(@PathVariable Integer orderId) {
        try {
            List<OrderItem> orderItems = orderItemServices.getOrderItemsByOrderId(orderId);
            return ResponseEntity.ok(orderItems);
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.internalServerError().build();
        }
    }

    // Cập nhật trạng thái của order item (nhận Map với statusId)
    @PutMapping("/{id}/status")
    public ResponseEntity<OrderItem> updateOrderItemStatus(
            @PathVariable Integer id, 
            @RequestBody Map<String, Integer> payload) {
        try {
            Integer statusId = payload.get("statusId");
            OrderItem updatedOrderItem = orderItemServices.updateOrderItemStatus(id, statusId);
            return ResponseEntity.ok(updatedOrderItem);
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.internalServerError().build();
        }
    }

    // Cập nhật người phục vụ món
    @PutMapping("/{id}/served-by")
    public ResponseEntity<OrderItem> updateServedBy(@PathVariable Integer id, @RequestBody Integer servedBy) {
        try {
            OrderItem updatedOrderItem = orderItemServices.updateServedBy(id, servedBy);
            return ResponseEntity.ok(updatedOrderItem);
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.internalServerError().build();
        }
    }

    // Cập nhật số lượng của order item
    @PutMapping("/{id}/quantity")
    public ResponseEntity<OrderItem> updateOrderItemQuantity(
            @PathVariable Integer id,
            @RequestBody Map<String, Integer> payload) {
        try {
            Integer newQuantity = payload.get("quantity");
            OrderItem updatedOrderItem = orderItemServices.updateOrderItemQuantity(id, newQuantity);
            return ResponseEntity.ok(updatedOrderItem);
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.internalServerError().build();
        }
    }
}
