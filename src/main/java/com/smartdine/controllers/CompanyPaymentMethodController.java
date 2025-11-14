package com.smartdine.controllers;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.smartdine.models.CompanyPaymentMethod;
import com.smartdine.services.CompanyPaymentMethodServices;

@RestController
@RequestMapping("/api/company-payment-methods")
public class CompanyPaymentMethodController {

    @Autowired
    private CompanyPaymentMethodServices companyPaymentMethodServices;

    @GetMapping("/all")
    public ResponseEntity<?> getAll() {
        try {
            List<CompanyPaymentMethod> methods = companyPaymentMethodServices.getAll();
            return ResponseEntity.ok(methods);
        } catch (Exception ex) {
            return ResponseEntity.internalServerError().body("Lỗi " + ex.getMessage());
        }
    }
}
