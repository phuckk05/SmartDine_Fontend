package com.smartdine.controllers.status;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.smartdine.models.status.TableStatus;
import com.smartdine.services.TableStatusServices;

@RestController
@RequestMapping("/api/table-statuses")
public class TableStatusController {

    @Autowired
    private TableStatusServices tableStatusServices;

    @GetMapping("/all")
    public ResponseEntity<?> getAll() {
        try {
            List<TableStatus> statuses = tableStatusServices.getAll();
            return ResponseEntity.ok(statuses);
        } catch (Exception ex) {
            return ResponseEntity.internalServerError().body("Lỗi " + ex.getMessage());
        }
    }

    @GetMapping("/{id}")
    public ResponseEntity<?> getById(@PathVariable Integer id) {
        try {
            TableStatus status = tableStatusServices.getById(id);
            if (status == null) {
                return ResponseEntity.notFound().build();
            }
            return ResponseEntity.ok(status);
        } catch (Exception ex) {
            return ResponseEntity.internalServerError().body("Lỗi " + ex.getMessage());
        }
    }
}
