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
    @GetMapping
    public List<User> getUsers() {
        return userService.getAllUsers();
    }

    // Tạo user
    @PostMapping
    public ResponseEntity<?> createUser(@RequestBody User user) {
        try {
            User createUser = userService.createUser(user);
            return ResponseEntity.ok(createUser);
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }

    // lấy user theo id
    @GetMapping("/{id}")
    public User getUser(@PathVariable Long id) {
        return userService.getUserById(id);
    }

    // Xoa User
    @DeleteMapping("/{id}")
    public void deleteUser(@PathVariable Long id) {
        userService.deleteUser(id);
    }

}
