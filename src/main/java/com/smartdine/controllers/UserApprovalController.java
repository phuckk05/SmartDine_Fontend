package com.smartdine.controllers;

import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.smartdine.models.User;
import com.smartdine.services.UserApprovalService;

@RestController
@RequestMapping("/api/user-approval")
@CrossOrigin(origins = "*")
public class UserApprovalController {

    @Autowired
    private UserApprovalService userApprovalService;

    // Lấy danh sách user chờ duyệt theo companyId
    @GetMapping("/pending/{companyId}")
    public ResponseEntity<List<User>> getPendingUsers(@PathVariable Integer companyId) {
        try {
            List<User> pendingUsers = userApprovalService.getPendingUsersByCompany(companyId);
            return ResponseEntity.ok(pendingUsers);
        } catch (Exception e) {
            return ResponseEntity.badRequest().build();
        }
    }

    // Lấy danh sách user chờ duyệt theo branchId
    @GetMapping("/pending/branch/{branchId}")
    public ResponseEntity<List<User>> getPendingUsersByBranch(@PathVariable Integer branchId) {
        try {
            List<User> pendingUsers = userApprovalService.getPendingUsersByBranch(branchId);
            return ResponseEntity.ok(pendingUsers);
        } catch (Exception e) {
            return ResponseEntity.badRequest().build();
        }
    }

    // Lấy danh sách user bị khóa (status = 0) theo branchId  
    @GetMapping("/locked/branch/{branchId}")
    public ResponseEntity<List<User>> getLockedUsersByBranch(@PathVariable Integer branchId) {
        try {
            List<User> lockedUsers = userApprovalService.getLockedUsersByBranch(branchId);
            return ResponseEntity.ok(lockedUsers);
        } catch (Exception e) {
            return ResponseEntity.badRequest().build();
        }
    }

    // Duyệt user (chuyển statusId từ 3 -> 1)
    @PutMapping("/approve/{userId}")
    public ResponseEntity<Map<String, String>> approveUser(@PathVariable Integer userId) {
        try {
            boolean result = userApprovalService.approveUser(userId);
            if (result) {
                return ResponseEntity.ok(Map.of("message", "User approved successfully"));
            } else {
                return ResponseEntity.badRequest().body(Map.of("error", "User not found or already processed"));
            }
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }

    // Từ chối user (chuyển statusId từ 3 -> 2)
    @PutMapping("/reject/{userId}")
    public ResponseEntity<Map<String, String>> rejectUser(@PathVariable Integer userId, 
                                                           @RequestParam(required = false) String reason) {
        try {
            boolean result = userApprovalService.rejectUser(userId, reason);
            if (result) {
                return ResponseEntity.ok(Map.of("message", "User rejected successfully"));
            } else {
                return ResponseEntity.badRequest().body(Map.of("error", "User not found or already processed"));
            }
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }

    // Khóa user (chuyển statusId -> 2)
    @PutMapping("/block/{userId}")
    public ResponseEntity<Map<String, String>> blockUser(@PathVariable Integer userId,
                                                         @RequestParam(required = false) String reason) {
        try {
            boolean result = userApprovalService.blockUser(userId, reason);
            if (result) {
                return ResponseEntity.ok(Map.of("message", "User blocked successfully"));
            } else {
                return ResponseEntity.badRequest().body(Map.of("error", "User not found"));
            }
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }

    // Lấy thống kê số lượng user chờ duyệt
    @GetMapping("/statistics/{companyId}")
    public ResponseEntity<Map<String, Integer>> getPendingStatistics(@PathVariable Integer companyId) {
        try {
            Map<String, Integer> stats = userApprovalService.getPendingStatistics(companyId);
            return ResponseEntity.ok(stats);
        } catch (Exception e) {
            return ResponseEntity.badRequest().build();
        }
    }
}