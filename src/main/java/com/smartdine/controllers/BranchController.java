package com.smartdine.controllers;

import com.smartdine.models.Branch;
import com.smartdine.services.*;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/branches")
public class BranchController {

    @Autowired
    private BranchServices branchServices;

    // Lấy tất cả branch
    @GetMapping("/all")
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
}
