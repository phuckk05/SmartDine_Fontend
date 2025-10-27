package com.smartdine.controllers;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.smartdine.models.Menu;
import com.smartdine.services.MenuServices;

@RestController
@RequestMapping("/api/menus")
public class MenuController {

    @Autowired
    private MenuServices menuServices;

    @GetMapping
    public ResponseEntity<?> getAll() {
        try {
            List<Menu> menus = menuServices.getAll();
            return ResponseEntity.ok(menus);
        } catch (Exception ex) {
            return ResponseEntity.internalServerError().body("Lỗi " + ex.getMessage());
        }
    }

    @GetMapping("/{id}")
    public ResponseEntity<?> getById(@PathVariable Integer id) {
        try {
            Menu menu = menuServices.getById(id);
            if (menu == null) {
                return ResponseEntity.notFound().build();
            }
            return ResponseEntity.ok(menu);
        } catch (Exception ex) {
            return ResponseEntity.internalServerError().body("Lỗi " + ex.getMessage());
        }
    }

    @PostMapping
    public ResponseEntity<?> create(@RequestBody Menu menu) {
        try {
            Menu created = menuServices.create(menu);
            return ResponseEntity.ok(created);
        } catch (Exception ex) {
            return ResponseEntity.internalServerError().body("Lỗi " + ex.getMessage());
        }
    }

    @PutMapping("/{id}")
    public ResponseEntity<?> update(@PathVariable Integer id, @RequestBody Menu menu) {
        try {
            Menu updated = menuServices.update(id, menu);
            if (updated == null) {
                return ResponseEntity.notFound().build();
            }
            return ResponseEntity.ok(updated);
        } catch (Exception ex) {
            return ResponseEntity.internalServerError().body("Lỗi " + ex.getMessage());
        }
    }
    //Lay menu theo company id
    @GetMapping("/company/{companyId}")
    public ResponseEntity<?> getByCompanyId(@PathVariable Integer companyId) {
        try {
            List<Menu> menus = menuServices.getByCompanyId(companyId);
            return ResponseEntity.ok(menus);
        } catch (Exception ex) {
            return ResponseEntity.internalServerError().body("Lỗi " + ex.getMessage());
        }
    }
    
    @DeleteMapping("/{id}")
    public ResponseEntity<?> delete(@PathVariable Integer id) {
        try {
            boolean deleted = menuServices.delete(id);
            if (!deleted) {
                return ResponseEntity.notFound().build();
            }
            return ResponseEntity.noContent().build();
        } catch (Exception ex) {
            return ResponseEntity.internalServerError().body("Lỗi " + ex.getMessage());
        }
    }

    // Get Top Dishes theo chi nhánh
    @GetMapping("/top-dishes/branch/{branchId}")
    public ResponseEntity<?> getTopDishesByBranch(
            @PathVariable Integer branchId,
            @RequestParam(value = "limit", defaultValue = "10") int limit) {
        try {
            // TODO: Implement logic to get top dishes by sales/revenue
            // For now, return mock data structure matching the API spec
            
            List<Map<String, Object>> topDishes = new ArrayList<>();
            
            // Mock top dishes data - should be replaced with actual database query
            // that joins MenuItem, OrderItem tables to get real statistics
            Map<String, Object> dish1 = new HashMap<>();
            dish1.put("itemId", 1);
            dish1.put("name", "Phở bò");
            dish1.put("quantity", 20);
            dish1.put("revenue", 300000);
            topDishes.add(dish1);
            
            Map<String, Object> dish2 = new HashMap<>();
            dish2.put("itemId", 2);
            dish2.put("name", "Cơm tấm");
            dish2.put("quantity", 15);
            dish2.put("revenue", 225000);
            topDishes.add(dish2);
            
            Map<String, Object> dish3 = new HashMap<>();
            dish3.put("itemId", 3);
            dish3.put("name", "Bún bò Huế");
            dish3.put("quantity", 12);
            dish3.put("revenue", 180000);
            topDishes.add(dish3);
            
            // Limit results
            List<Map<String, Object>> limitedResults = topDishes.stream()
                .limit(limit)
                .toList();
            
            return ResponseEntity.ok(limitedResults);
        } catch (Exception ex) {
            return ResponseEntity.internalServerError().body("Lỗi " + ex.getMessage());
        }
    }
}
