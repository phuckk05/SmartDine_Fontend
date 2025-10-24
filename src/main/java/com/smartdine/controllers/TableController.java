package com.smartdine.controllers;

import com.smartdine.models.RestaurantTable;
import com.smartdine.services.RestaurantTableServices;

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

@RestController
@RequestMapping("/api/table-management")
public class TableController {

    @Autowired
    private RestaurantTableServices tableServices;

    // Lấy tất cả bàn
    @GetMapping("/all")
    public ResponseEntity<List<RestaurantTable>> getAllTables() {
        try {
            List<RestaurantTable> tables = tableServices.getAll();
            return ResponseEntity.ok(tables);
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.internalServerError().build();
        }
    }

    // Lấy bàn theo chi nhánh
    // @GetMapping("/branch/{branchId}")
    // public ResponseEntity<List<RestaurantTable>> getTablesByBranch(@PathVariable
    // int branchId) {
    // try {
    // List<RestaurantTable> tables = tableServices.getTablesByBranch(branchId);
    // return ResponseEntity.ok(tables);
    // } catch (Exception e) {
    // e.printStackTrace();
    // return ResponseEntity.internalServerError().build();
    // }
    // }

    // Lấy bàn theo ID
    @GetMapping("/{tableId}")
    public ResponseEntity<RestaurantTable> getTableById(@PathVariable int tableId) {
        try {
            RestaurantTable table = tableServices.getById(tableId);
            if (table == null) {
                return ResponseEntity.notFound().build();
            }
            return ResponseEntity.ok(table);
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.internalServerError().build();
        }
    }

    // Tạo bàn mới
    @PostMapping
    public ResponseEntity<?> createTable(@RequestBody RestaurantTable table) {
        try {
            RestaurantTable createdTable = tableServices.create(table);
            return ResponseEntity.ok(createdTable);
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.internalServerError().body(e.getMessage());
        }
    }

    // Cập nhật bàn
    @PutMapping("/{tableId}")
    public ResponseEntity<?> updateTable(@PathVariable int tableId, @RequestBody RestaurantTable table) {
        try {
            RestaurantTable updatedTable = tableServices.update(tableId, table);
            if (updatedTable == null) {
                return ResponseEntity.notFound().build();
            }
            return ResponseEntity.ok(updatedTable);
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.internalServerError().body(e.getMessage());
        }
    }

    // Xóa bàn
    @DeleteMapping("/{tableId}")
    public ResponseEntity<?> deleteTable(@PathVariable int tableId) {
        try {
            boolean deleted = tableServices.delete(tableId);
            if (!deleted) {
                return ResponseEntity.notFound().build();
            }
            return ResponseEntity.ok().build();
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.internalServerError().body(e.getMessage());
        }
    }

    // Lấy bàn theo trạng thái
    // @GetMapping("/status/{statusId}")
    // public ResponseEntity<List<RestaurantTable>> getTablesByStatus(@PathVariable
    // int statusId) {
    // try {
    // List<RestaurantTable> tables = tableServices.getTablesByStatus(statusId);
    // return ResponseEntity.ok(tables);
    // } catch (Exception e) {
    // e.printStackTrace();
    // return ResponseEntity.internalServerError().build();
    // }
    // }

    // Lấy bàn theo loại
    // @GetMapping("/type/{typeId}")
    // public ResponseEntity<List<RestaurantTable>> getTablesByType(@PathVariable
    // int typeId) {
    // try {
    // List<RestaurantTable> tables = tableServices.getTablesByType(typeId);
    // return ResponseEntity.ok(tables);
    // } catch (Exception e) {
    // e.printStackTrace();
    // return ResponseEntity.internalServerError().build();
    // }
    // }
}