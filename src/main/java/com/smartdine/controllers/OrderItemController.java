package com.smartdine.controllers;

import java.util.List;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.smartdine.dto.KitchenOrderItemDto;
import com.smartdine.models.Order;
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

    // Lấy tất cả order item ngày hôm nay
    @GetMapping("/today/branch/{branchId}")
    public ResponseEntity<?> getOrderItemsToday(@PathVariable Integer branchId) {
        try {
            List<Order> orders = orderServices.getOrdersByBranchIdToday(branchId);
            List<Integer> orderIds = orders.stream().map(Order::getId).toList();
            List<KitchenOrderItemDto> orderItems = orderItemServices.getOrderItemsByOrderIds(orderIds);
            return ResponseEntity.ok(orderItems);
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.internalServerError().body(e.getMessage());
        }

    }

    // Cập nhật trạng thái của order item
    @PutMapping("/{id}/status")
    public ResponseEntity<?> updateOrderItemStatus(@PathVariable Integer id, @RequestBody Integer status) {
        try {
            KitchenOrderItemDto updatedOrderItem = orderItemServices.updateOrderItemStatus(id, status);
            return ResponseEntity.ok(updatedOrderItem);
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.internalServerError().body(e.getMessage());
        }
    }

    // Cập nhật người phục vụ món
    @PutMapping("/{id}/served-by")
    public ResponseEntity<?> updateServedBy(@PathVariable Integer id, @RequestBody Integer servedBy) {
        try {
            KitchenOrderItemDto updatedOrderItem = orderItemServices.updateServedBy(id, servedBy);
            return ResponseEntity.ok(updatedOrderItem);
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.internalServerError().body(e.getMessage());
        }
    }

}
