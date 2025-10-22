package com.smartdine.controllers;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.smartdine.models.CompanyPaymentMethodStatus;
import com.smartdine.services.CompanyPaymentMethodStatusServices;

@RestController
@RequestMapping("/api/company-payment-method-statuses")
public class CompanyPaymentMethodStatusController {

    @Autowired
    private CompanyPaymentMethodStatusServices statusServices;

    @GetMapping("/all")
    public ResponseEntity<?> getAll() {
        try {
            List<CompanyPaymentMethodStatus> statuses = statusServices.getAll();
            return ResponseEntity.ok(statuses);
        } catch (Exception ex) {
            return ResponseEntity.internalServerError().body("Lỗi " + ex.getMessage());
        }
    }

    @GetMapping("/{id}")
    public ResponseEntity<?> getById(@PathVariable Integer id) {
        try {
            CompanyPaymentMethodStatus status = statusServices.getById(id);
            if (status == null) {
                return ResponseEntity.notFound().build();
            }
            return ResponseEntity.ok(status);
        } catch (Exception ex) {
            return ResponseEntity.internalServerError().body("Lỗi " + ex.getMessage());
        }
    }
}
