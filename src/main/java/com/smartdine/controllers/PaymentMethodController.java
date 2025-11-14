package com.smartdine.controllers;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.smartdine.models.PaymentMethod;
import com.smartdine.services.PaymentMethodServices;

@RestController
@RequestMapping("/api/payment-methods")
public class PaymentMethodController {

    @Autowired
    private PaymentMethodServices paymentMethodServices;

    @GetMapping("/all")
    public ResponseEntity<?> getAll() {
        try {
            List<PaymentMethod> methods = paymentMethodServices.getAll();
            return ResponseEntity.ok(methods);
        } catch (Exception ex) {
            return ResponseEntity.internalServerError().body("Lỗi " + ex.getMessage());
        }
    }
}
