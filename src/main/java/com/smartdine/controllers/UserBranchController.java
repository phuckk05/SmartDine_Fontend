package com.smartdine.controllers;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import com.smartdine.models.UserBranch;
import com.smartdine.services.UserBranchSevices;

@RestController
@RequestMapping("/api/user_branches")
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
}
