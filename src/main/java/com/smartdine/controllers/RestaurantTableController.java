package com.smartdine.controllers;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.smartdine.models.RestaurantTable;
import com.smartdine.services.RestaurantTableServices;

@RestController
@RequestMapping("/api/tables")
public class RestaurantTableController {

    @Autowired
    private RestaurantTableServices restaurantTableServices;

    @GetMapping("/all")
    public ResponseEntity<?> getAll() {
        try {
            List<RestaurantTable> tables = restaurantTableServices.getAll();
            return ResponseEntity.ok(tables);
        } catch (Exception ex) {
            return ResponseEntity.internalServerError().body("Lỗi " + ex.getMessage());
        }
    }

    @GetMapping("/get/{id}")
    public ResponseEntity<?> getById(@PathVariable Integer id) {
        try {
            RestaurantTable table = restaurantTableServices.getById(id);
            if (table == null) {
                return ResponseEntity.notFound().build();
            }
            return ResponseEntity.ok(table);
        } catch (Exception ex) {
            return ResponseEntity.internalServerError().body("Lỗi " + ex.getMessage());
        }
    }

    // Tạo mới bàn
    @PostMapping
    public ResponseEntity<?> create(@RequestBody RestaurantTable table) {
        try {
            RestaurantTable created = restaurantTableServices.create(table);
            return ResponseEntity.ok(created);
        } catch (Exception ex) {
            return ResponseEntity.internalServerError().body("Lỗi " + ex.getMessage());
        }
    }

    @PutMapping("/update/{id}")
    public ResponseEntity<?> update(@PathVariable Integer id, @RequestBody RestaurantTable table) {
        try {
            RestaurantTable updated = restaurantTableServices.update(id, table);
            if (updated == null) {
                return ResponseEntity.notFound().build();
            }
            return ResponseEntity.ok(updated);
        } catch (Exception ex) {
            return ResponseEntity.internalServerError().body("Lỗi " + ex.getMessage());
        }
    }

    // Xóa bàn
    @DeleteMapping("/delete/{id}")
    public ResponseEntity<?> delete(@PathVariable Integer id) {
        try {
            boolean deleted = restaurantTableServices.delete(id);
            if (!deleted) {
                return ResponseEntity.notFound().build();
            }
            return ResponseEntity.noContent().build();
        } catch (Exception ex) {
            return ResponseEntity.internalServerError().body("Lỗi " + ex.getMessage());
        }
    }

    // Lấy bàn theo branchId
    @GetMapping("/get/branch/{branchId}")
    public ResponseEntity<?> getByBranchId(@PathVariable Integer branchId) {
        try {
            List<RestaurantTable> tables = restaurantTableServices.getByBranchId(branchId);
            return ResponseEntity.ok(tables);
        } catch (Exception ex) {
            return ResponseEntity.internalServerError().body("Lỗi " + ex.getMessage());
        }
    }
}
