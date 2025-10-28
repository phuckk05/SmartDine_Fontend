package com.smartdine.controllers;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import com.smartdine.models.Chef;
import com.smartdine.services.ChefService;

@RestController
@RequestMapping("/api/chef")
@CrossOrigin(origins = "*") // Cho phép Flutter gọi API
public class ChefController {

    @Autowired
    private ChefService chefService;

    // Lấy thông tin Chef theo id
    @GetMapping("/{id}")
    public ResponseEntity<?> getChefById(@PathVariable Integer id) {
        try {
            Chef chef = chefService.getById(id);
            if (chef != null) {
                return ResponseEntity.ok(chef);
            } else {
                return ResponseEntity.notFound().build();
            }
        } catch (Exception e) {
            return ResponseEntity.internalServerError()
                                 .body("Lỗi khi lấy Chef: " + e.getMessage());
        }
    }

    // Lấy toàn bộ Chef (nếu cần)
    @GetMapping("/all")
    public ResponseEntity<?> getAllChefs() {
        try {
            return ResponseEntity.ok(chefService.getAll());
        } catch (Exception e) {
            return ResponseEntity.internalServerError()
                                 .body("Lỗi khi lấy danh sách Chef: " + e.getMessage());
        }
    }
}
