package com.smartdine.controllers;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
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
}
