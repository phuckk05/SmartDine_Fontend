package com.smartdine.controllers;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.smartdine.models.Item;
import com.smartdine.services.ItemServices;

@RestController
@RequestMapping("/api/items")
public class ItemController {
    @Autowired
    private ItemServices itemServices;

    // lay item by comapnyId
    @GetMapping("/company/{companyId}")
    public ResponseEntity<?> getByCompanyId(@PathVariable Integer companyId) {
        try {
            List<Item> getItems = itemServices.getByCompanyId(companyId);
            return ResponseEntity.ok(getItems);
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.internalServerError().body(e.getMessage());
        }

    }

    // Lay item by id
    @GetMapping("/get/{id}")
    public ResponseEntity<?> getById(@PathVariable Integer id) {
        try {
            Item item = itemServices.getById(id);
            if (item != null) {
                return ResponseEntity.ok(item);
            } else {
                return ResponseEntity.notFound().build();
            }
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.internalServerError().body(e.getMessage());
        }
    }

    // Cap nhat trang thai item
    @PutMapping("/update/{id}")
    public ResponseEntity<?> updateItemStatus(@PathVariable Integer id, @RequestParam Integer statusId) {
        try {
            Item updatedItem = itemServices.updateItemStatus(id, statusId);
            if (updatedItem != null) {
                return ResponseEntity.ok(updatedItem);
            } else {
                return ResponseEntity.notFound().build();
            }
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.internalServerError().body(e.getMessage());
        }
    }
}
