package com.smartdine.controllers.status;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.smartdine.models.status.PaymentStatus;
import com.smartdine.services.PaymentStatusServices;

@RestController
@RequestMapping("/api/payment-statuses")
public class PaymentStatusController {

    @Autowired
    private PaymentStatusServices paymentStatusServices;

    @GetMapping("/all")
    public ResponseEntity<?> getAll() {
        try {
            List<PaymentStatus> statuses = paymentStatusServices.getAll();
            return ResponseEntity.ok(statuses);
        } catch (Exception ex) {
            return ResponseEntity.internalServerError().body("Lỗi " + ex.getMessage());
        }
    }

    @GetMapping("/{id}")
    public ResponseEntity<?> getById(@PathVariable Integer id) {
        try {
            PaymentStatus status = paymentStatusServices.getById(id);
            if (status == null) {
                return ResponseEntity.notFound().build();
            }
            return ResponseEntity.ok(status);
        } catch (Exception ex) {
            return ResponseEntity.internalServerError().body("Lỗi " + ex.getMessage());
        }
    }
}
