package com.smartdine.controllers;

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
import org.springframework.web.bind.annotation.RestController;

import com.smartdine.models.TableType;
import com.smartdine.services.TableTypeServices;

@RestController
@RequestMapping("/api/table-types")
public class TableTypeController {

    @Autowired
    private TableTypeServices tableTypeServices;

    @GetMapping("/branch/{branchId}")
    public ResponseEntity<?> getByBranch(@PathVariable Integer branchId) {
        try {
            List<TableType> types = tableTypeServices.getByBranchId(branchId);
            return ResponseEntity.ok(types);
        } catch (Exception ex) {
            return ResponseEntity.internalServerError().body("Lỗi " + ex.getMessage());
        }
    }

    @PostMapping("/branch/{branchId}")
    public ResponseEntity<?> createTableType(@PathVariable Integer branchId, @RequestBody Map<String, Object> request) {
        try {
            TableType tableType = new TableType();
            tableType.setName((String) request.get("name"));
            tableType.setCode((String) request.get("code"));
            tableType.setBranchId(branchId);

            TableType created = tableTypeServices.create(tableType);
            return ResponseEntity.ok(created);
        } catch (Exception ex) {
            return ResponseEntity.internalServerError().body("Lỗi tạo loại bàn: " + ex.getMessage());
        }
    }

    @PutMapping("/{typeId}")
    public ResponseEntity<?> updateTableType(@PathVariable Integer typeId, @RequestBody Map<String, Object> request) {
        try {
            TableType existing = tableTypeServices.getById(typeId);
            if (existing == null) {
                return ResponseEntity.notFound().build();
            }

            existing.setName((String) request.get("name"));
            existing.setCode((String) request.get("code"));

            TableType updated = tableTypeServices.update(typeId, existing);
            return ResponseEntity.ok(updated);
        } catch (Exception ex) {
            return ResponseEntity.internalServerError().body("Lỗi cập nhật loại bàn: " + ex.getMessage());
        }
    }

    @DeleteMapping("/{typeId}")
    public ResponseEntity<?> deleteTableType(@PathVariable Integer typeId) {
        try {
            boolean deleted = tableTypeServices.delete(typeId);
            if (!deleted) {
                return ResponseEntity.notFound().build();
            }
            return ResponseEntity.noContent().build();
        } catch (Exception ex) {
            return ResponseEntity.internalServerError().body("Lỗi xóa loại bàn: " + ex.getMessage());
        }
    }
}
