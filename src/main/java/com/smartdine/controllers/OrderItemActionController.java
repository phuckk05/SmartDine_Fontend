package com.smartdine.controllers;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.smartdine.models.OrderItemAction;
import com.smartdine.services.OrderItemActionServices;

@RestController
@RequestMapping("/api/order-item-actions")
public class OrderItemActionController {

    @Autowired
    private OrderItemActionServices orderItemActionServices;

    @GetMapping("/all")
    public ResponseEntity<?> getAll() {
        try {
            List<OrderItemAction> actions = orderItemActionServices.getAll();
            return ResponseEntity.ok(actions);
        } catch (Exception ex) {
            return ResponseEntity.internalServerError().body("Lỗi " + ex.getMessage());
        }
    }

    @GetMapping("/{id}")
    public ResponseEntity<?> getById(@PathVariable Integer id) {
        try {
            OrderItemAction action = orderItemActionServices.getById(id);
            if (action == null) {
                return ResponseEntity.notFound().build();
            }
            return ResponseEntity.ok(action);
        } catch (Exception ex) {
            return ResponseEntity.internalServerError().body("Lỗi " + ex.getMessage());
        }
    }
}
