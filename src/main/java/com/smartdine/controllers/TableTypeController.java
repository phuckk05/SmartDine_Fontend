package com.smartdine.controllers;

import java.util.List;
import java.util.Optional;

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

    // Endpoint getAll() không còn cần thiết vì tất cả đều branch-specific
    // @GetMapping("/all")
    // public ResponseEntity<?> getAll() {
    //     try {
    //         List<TableType> types = tableTypeServices.getAll();
    //         return ResponseEntity.ok(types);
    //     } catch (Exception ex) {
    //         return ResponseEntity.internalServerError().body("Lỗi " + ex.getMessage());
    //     }
    // }

    // Lấy table types theo branch
    @GetMapping("/branch/{branchId}")
    public ResponseEntity<?> getByBranchId(@PathVariable Integer branchId) {
        try {
            List<TableType> types = tableTypeServices.getByBranchId(branchId);
            return ResponseEntity.ok(types);
        } catch (Exception ex) {
            return ResponseEntity.internalServerError().body("Lỗi " + ex.getMessage());
        }
    }

    // Tạo table type mới cho branch
    @PostMapping("/branch/{branchId}")
    public ResponseEntity<?> createTableType(@PathVariable Integer branchId, @RequestBody TableType tableType) {
        try {
            // Đảm bảo table type thuộc về branch được chỉ định
            tableType.setBranchId(branchId);
            TableType created = tableTypeServices.createTableType(tableType);
            return ResponseEntity.ok(created);
        } catch (RuntimeException ex) {
            return ResponseEntity.badRequest().body(ex.getMessage());
        } catch (Exception ex) {
            return ResponseEntity.internalServerError().body("Lỗi " + ex.getMessage());
        }
    }

    // Cập nhật table type
    @PutMapping("/{id}")
    public ResponseEntity<?> updateTableType(@PathVariable Integer id, @RequestBody TableType tableType) {
        try {
            TableType updated = tableTypeServices.updateTableType(id, tableType);
            return ResponseEntity.ok(updated);
        } catch (RuntimeException ex) {
            return ResponseEntity.badRequest().body(ex.getMessage());
        } catch (Exception ex) {
            return ResponseEntity.internalServerError().body("Lỗi " + ex.getMessage());
        }
    }

    // Xóa table type
    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteTableType(@PathVariable Integer id) {
        try {
            tableTypeServices.deleteTableType(id);
            return ResponseEntity.ok("Xóa loại bàn thành công");
        } catch (RuntimeException ex) {
            return ResponseEntity.badRequest().body(ex.getMessage());
        } catch (Exception ex) {
            return ResponseEntity.internalServerError().body("Lỗi " + ex.getMessage());
        }
    }

    // Lấy table type theo ID
    @GetMapping("/{id}")
    public ResponseEntity<?> getById(@PathVariable Integer id) {
        try {
            Optional<TableType> type = tableTypeServices.getById(id);
            if (type.isPresent()) {
                return ResponseEntity.ok(type.get());
            } else {
                return ResponseEntity.notFound().build();
            }
        } catch (Exception ex) {
            return ResponseEntity.internalServerError().body("Lỗi " + ex.getMessage());
        }
    }
}
