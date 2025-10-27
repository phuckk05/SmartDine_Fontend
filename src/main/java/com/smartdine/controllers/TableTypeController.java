package com.smartdine.controllers;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.smartdine.models.TableType;
import com.smartdine.services.TableTypeServices;

@RestController
@RequestMapping("/api/table-types")
public class TableTypeController {

    @Autowired
    private TableTypeServices tableTypeServices;

    @GetMapping("/all")
    public ResponseEntity<?> getAll() {
        try {
            List<TableType> types = tableTypeServices.getAll();
            return ResponseEntity.ok(types);
        } catch (Exception ex) {
            return ResponseEntity.internalServerError().body("Lỗi " + ex.getMessage());
        }
    }

    // Endpoint cho frontend - không có /all
    @GetMapping
    public ResponseEntity<?> getTableTypes() {
        try {
            List<TableType> types = tableTypeServices.getAll();
            return ResponseEntity.ok(types);
        } catch (Exception ex) {
            return ResponseEntity.internalServerError().body("Lỗi " + ex.getMessage());
        }
    }
}
