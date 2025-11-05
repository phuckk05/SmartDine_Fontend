package com.smartdine.controllers;

import com.smartdine.services.UserService;
import com.smartdine.models.User;
import org.springframework.http.ResponseEntity;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/users")
public class UserController {

    @Autowired
    private UserService userService;

    // Lấy all user
    @GetMapping("/all")
    public List<User> getUsers() {
        return userService.getAllUsers();
    }

    // Lấy user theo email
    @GetMapping("/email/{email}")
    public User getUserByEmail(@PathVariable String email) {
        return userService.getUserByEmail(email);
    }

    // Tạo user
    @PostMapping
    public ResponseEntity<?> createUser(@RequestBody User user) {
        try {
            User createUser = userService.createUser(user);
            return ResponseEntity.ok(createUser);
        } catch (RuntimeException e) {
            e.printStackTrace();
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }

    // lấy user theo id
    @GetMapping("/get/{id}")
    public User getUser(@PathVariable Integer id) {
        return userService.getUserById(id);
    }

    // Xoa User
    @DeleteMapping("/delete/{id}")
    public boolean deleteUser(@PathVariable Integer id) {
        return userService.deleteUser(id);
    }

    // Cập nhật mật khẩu
    @PutMapping("/password/{id}")
    public ResponseEntity<?> updatePassword(@PathVariable Integer id, @RequestParam String newPassword) {
        try {
            User updatedUser = userService.updatePassword(id, newPassword);
            return ResponseEntity.ok(updatedUser);
        } catch (IllegalArgumentException ex) {
            return ResponseEntity.notFound().build();
        }
    }

    // Cập nhật user
    @PutMapping("/update/{id}")
    public ResponseEntity<?> updateUser(@PathVariable Integer id, @RequestBody User userDetails) {
        try {
            User updatedUser = userService.updateUser(id, userDetails);
            return ResponseEntity.ok(updatedUser);
        } catch (IllegalArgumentException ex) {
            return ResponseEntity.notFound().build();
        }
    }
    // Lấy danh sách user đang chờ xác nhận
    @GetMapping("/pending")
    public List<User> getPendingUsers() {
        return userService.getPendingUsers();
    }

}
