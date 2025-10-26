package com.smartdine.controllers;

import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.smartdine.models.Branch;
import com.smartdine.services.BranchServices;

@RestController
@RequestMapping("/api/branches")
public class BranchController {

    @Autowired
    private BranchServices branchServices;

    // Lấy tất cả branch
    @GetMapping
    public List<Branch> getAll() {
        return branchServices.getAll();
    }

    // Thêm mới branch
    @PostMapping
    public ResponseEntity<?> createBranch(@RequestBody Branch branch) {
        try {
            final Branch createBranch = branchServices.create(branch);
            return ResponseEntity.ok(createBranch);
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.internalServerError().body(e.getMessage());
        }
    }

    // Lấy thông tin branch theo mã code
    @GetMapping("/{branchCode}")
    public ResponseEntity<Branch> getBranchByCode(@PathVariable String branchCode) {
        Branch branch = branchServices.findBranch(branchCode);
        if (branch == null) {
            // Trả về 404
            return ResponseEntity.notFound().build();
        }
        return ResponseEntity.ok(branch);
    }

    // Lấy thông tin branch theo id
    @GetMapping("/id/{id}")
    public ResponseEntity<Branch> getBranchById(@PathVariable Integer id) {
        Branch branch = branchServices.getBranchById(id);
        if (branch == null) {
            // Trả về 404
            return ResponseEntity.notFound().build();
        }
        return ResponseEntity.ok(branch);
    }

    // Lấy thống kê chi nhánh
    @GetMapping("/{branchId}/statistics")
    public ResponseEntity<?> getBranchStatistics(@PathVariable Integer branchId) {
        try {
            // Tạo thống kê cơ bản cho chi nhánh
            Map<String, Object> statistics = new HashMap<>();
            statistics.put("branchId", branchId);
            statistics.put("totalEmployees", 15); // Mock data - should get from EmployeeService
            statistics.put("totalTables", 20); // Mock data - should get from TableService
            statistics.put("todayRevenue", 2500000.0); // Mock data - should get from PaymentService
            statistics.put("todayOrders", 45); // Mock data - should get from OrderService
            statistics.put("occupancyRate", 75.0); // Mock data
            statistics.put("lastUpdated", LocalDateTime.now(ZoneId.of("Asia/Ho_Chi_Minh")).toString());

            return ResponseEntity.ok(statistics);
        } catch (Exception ex) {
            return ResponseEntity.internalServerError().body("Lỗi " + ex.getMessage());
        }
    }
}
