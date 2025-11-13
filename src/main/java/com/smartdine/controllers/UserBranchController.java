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
import org.springframework.web.bind.annotation.RestController;

import com.smartdine.models.UserBranch;
import com.smartdine.services.UserBranchSevices;

@RestController
@RequestMapping("/api/user-branches")
public class UserBranchController {
    @Autowired
    UserBranchSevices userBranchServices;

    @GetMapping("/all")
    public ResponseEntity<?> getAll() {
        try {
            List<UserBranch> userBranches = userBranchServices.getAll();
            return ResponseEntity.ok(userBranches);
        } catch (Exception e) {
            return ResponseEntity.internalServerError().body(e.getMessage());
        }
    }

    // Thêm mới
    @PostMapping
    public ResponseEntity<?> createUser(@RequestBody UserBranch userBranch) {
        try {
            UserBranch createUser = userBranchServices.create(userBranch);
            return ResponseEntity.ok(createUser);
        } catch (RuntimeException e) {
            e.printStackTrace();
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }

    // Lấy userBranch theo userId
    @GetMapping("/user/{userId}")
    public ResponseEntity<?> getByUserId(@PathVariable Integer userId) {
        try {
            UserBranch userBranch = userBranchServices.getByUserId(userId);
            return ResponseEntity.ok(userBranch);
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.internalServerError().body(e.getMessage());
        }
    }

    // Lấy usrBranch theo branchId
    @GetMapping("/branch/{branchId}")
    public ResponseEntity<?> getByBranchId(@PathVariable Integer branchId) {
        try {
            List<UserBranch> userBranches = userBranchServices.getByBranchId(branchId);
            return ResponseEntity.ok(userBranches);
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.internalServerError().body(e.getMessage());
        }
    }

    // Xóa user khỏi chi nhánh
    @DeleteMapping("/user/{userId}")
    public ResponseEntity<?> removeUserFromBranch(@PathVariable Integer userId) {
        try {
            boolean removed = userBranchServices.deleteByUserId(userId);
            if (!removed) {
                return ResponseEntity.notFound().build();
            }
            return ResponseEntity.noContent().build();
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.internalServerError().body(e.getMessage());
        }
    }
}
