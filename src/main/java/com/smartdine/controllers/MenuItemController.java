package com.smartdine.controllers;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.smartdine.models.MenuItem;
import com.smartdine.services.MenuItemServices;

@RestController
@RequestMapping("/api/menu-items")
public class MenuItemController {

    @Autowired
    private MenuItemServices menuItemServices;

    @PostMapping
    public ResponseEntity<?> assignMenuItem(@RequestBody MenuItem menuItem) {
        try {
            MenuItem created = menuItemServices.assignMenuItem(menuItem);
            return ResponseEntity.ok(created);
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }

    @DeleteMapping
    public ResponseEntity<?> deleteMenuItem(
            @RequestParam("categoryId") Integer categoryId,
            @RequestParam("itemId") Integer itemId) {
        try {
            boolean removed = menuItemServices.removeMenuItem(categoryId, itemId);
            if (!removed) {
                return ResponseEntity.notFound().build();
            }
            return ResponseEntity.noContent().build();
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.internalServerError().body(e.getMessage());
        }
    }

    // Tìm kiếm menu-item theo id
    @GetMapping("/{id}")
    public ResponseEntity<?> getMenuById(@PathVariable Integer id) {
        try {
            List<MenuItem> menuItems = menuItemServices.getMenuById(id);
            if (menuItems.isEmpty()) {
                return ResponseEntity.notFound().build();
            }
            return ResponseEntity.ok(menuItems);
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.internalServerError().body(e.getMessage());
        }
    }
}
