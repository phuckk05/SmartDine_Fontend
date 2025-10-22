package com.smartdine.controllers;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.smartdine.models.DiscountStatus;
import com.smartdine.services.DiscountStatusServices;

@RestController
@RequestMapping("/api/discount-statuses")
public class DiscountStatusController {

    @Autowired
    private DiscountStatusServices discountStatusServices;

    @GetMapping("/all")
    public ResponseEntity<?> getAll() {
        try {
            List<DiscountStatus> statuses = discountStatusServices.getAll();
            return ResponseEntity.ok(statuses);
        } catch (Exception ex) {
            return ResponseEntity.internalServerError().body("Lỗi " + ex.getMessage());
        }
    }

    @GetMapping("/{id}")
    public ResponseEntity<?> getById(@PathVariable Integer id) {
        try {
            DiscountStatus status = discountStatusServices.getById(id);
            if (status == null) {
                return ResponseEntity.notFound().build();
            }
            return ResponseEntity.ok(status);
        } catch (Exception ex) {
            return ResponseEntity.internalServerError().body("Lỗi " + ex.getMessage());
        }
    }
}
