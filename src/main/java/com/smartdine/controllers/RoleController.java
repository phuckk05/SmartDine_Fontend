package com.smartdine.controllers;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.smartdine.models.Role;
import com.smartdine.services.RoleServices;

@RestController
@RequestMapping("/api/roles")
public class RoleController {

    @Autowired
    RoleServices roleServices;

    @GetMapping("/all")
    public ResponseEntity<?> getAllRoles() {
        try {
            List<Role> roles = roleServices.getAll();
            return ResponseEntity.ok(roles);
        } catch (Exception e) {
            return ResponseEntity.internalServerError().body("Lỗi " + e.getMessage());
        }
    }

    // Endpoint cho frontend - không có /all
    @GetMapping
    public ResponseEntity<?> getRoles() {
        try {
            List<Role> roles = roleServices.getAll();
            return ResponseEntity.ok(roles);
        } catch (Exception e) {
            return ResponseEntity.internalServerError().body("Lỗi " + e.getMessage());
        }
    }

    // Lấy role theo id
    @GetMapping("/{id}")
    public ResponseEntity<?> getRoleById(@PathVariable Integer id) {
        try {
            Role role = roleServices.getById(id);
            return ResponseEntity.ok(role);
        } catch (Exception e) {
            return ResponseEntity.internalServerError().body("Lỗi " + e.getMessage());
        }
    }
}
