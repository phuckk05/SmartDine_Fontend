package com.smartdine.controllers;

import java.util.List;

import org.antlr.v4.runtime.atn.SemanticContext.OR;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.smartdine.models.OrderItem;
import com.smartdine.services.OrderItemService;

@RestController
@RequestMapping("/api/order-items")
public class OrderItemController {
    @Autowired
    private OrderItemService orderItemServices;

    // Lấy tất cả order item ngày hôm nay
    @GetMapping("/today")
    public ResponseEntity<?> getOrderItemsToday(@PathVariable Integer orderId) {
        try {
            List<OrderItem> orderItems = orderItemServices.getOrderItemsByOrderId(orderId);
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
            OrderItem updatedOrderItem = orderItemServices.updateOrderItemStatus(id, status);
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
            OrderItem updatedOrderItem = orderItemServices.updateServedBy(id, servedBy);
            return ResponseEntity.ok(updatedOrderItem);
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.internalServerError().body(e.getMessage());
        }
    }
}
