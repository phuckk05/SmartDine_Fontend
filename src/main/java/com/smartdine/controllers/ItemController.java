package com.smartdine.controllers;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.RequestBody;

import com.smartdine.models.Item;
import com.smartdine.services.ItemServices;

@RestController
@RequestMapping("/api/items")
public class ItemController {
    @Autowired
    private ItemServices itemServices;

    // Lấy items theo companyId và categoryId (tùy chọn)
    @GetMapping("/all")
    public ResponseEntity<?> getItems(
            @RequestParam("companyId") Integer companyId,
            @RequestParam(value = "categoryId", required = false) Integer categoryId) {
        try {
            List<Item> items = itemServices.getItems(companyId, categoryId);
            return ResponseEntity.ok(items);
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.internalServerError().body(e.getMessage());
        }
    }

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

    // Tạo item mới
    @PostMapping
    public ResponseEntity<?> createItem(@RequestBody Item item) {
        try {
            Item created = itemServices.createItem(item);
            return ResponseEntity.ok(created);
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

    // Cập nhật item
    @PutMapping("/{id}")
    public ResponseEntity<?> updateItem(@PathVariable Integer id, @RequestBody Item item) {
        try {
            Item updated = itemServices.updateItem(id, item);
            if (updated == null) {
                return ResponseEntity.notFound().build();
            }
            return ResponseEntity.ok(updated);
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

    // Xóa item
    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteItem(@PathVariable Integer id) {
        try {
            boolean deleted = itemServices.deleteItem(id);
            if (!deleted) {
                return ResponseEntity.notFound().build();
            }
            return ResponseEntity.noContent().build();
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.internalServerError().body(e.getMessage());
        }
    }
}
