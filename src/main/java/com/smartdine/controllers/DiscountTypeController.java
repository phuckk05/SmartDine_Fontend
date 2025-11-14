package com.smartdine.controllers;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.smartdine.models.DiscountType;
import com.smartdine.services.DiscountTypeServices;

@RestController
@RequestMapping("/api/discount-types")
public class DiscountTypeController {

    @Autowired
    private DiscountTypeServices discountTypeServices;

    @GetMapping("/all")
    public ResponseEntity<?> getAll() {
        try {
            List<DiscountType> types = discountTypeServices.getAll();
            return ResponseEntity.ok(types);
        } catch (Exception ex) {
            return ResponseEntity.internalServerError().body("Lỗi " + ex.getMessage());
        }
    }
}
