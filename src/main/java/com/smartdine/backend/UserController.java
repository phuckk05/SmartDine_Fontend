package com.smartdine.backend.controller;

import com.smartdine.backend.model.User;
import com.smartdine.backend.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/users")
public class UserController {

    @Autowired
    private UserService userService;
    

    //Lấy all user
    @GetMapping
    public List<User> getUsers() {
        return userService.getAllUsers();
    }
    
    //Tạo user
    @PostMapping
    public User createUser(@RequestBody User user) {
        return userService.createUser(user);
    }
    //lấy user theo id 
    @GetMapping("/{id}")
    public User getUser(@PathVariable Long id) {
        return userService.getUserById(id);
    }
    //Xoa User
    @DeleteMapping("/{id}")
    public void deleteUser(@PathVariable Long id) {
        userService.deleteUser(id);
    }
    //Cap nhat user
    @PutMapping("/{id}")
     public ResponseEntity<User> updateUser(@PathVariable Long id, @RequestBody User updatedUser) {
    Optional<User> existingUser = userRepository.findById(id);
    if (existingUser.isPresent()) {
        User user = existingUser.get();
        user.setName(updatedUser.getName());
        user.setEmail(updatedUser.getEmail());
        userRepository.save(user);
        return ResponseEntity.ok(user);
    } else {
        return ResponseEntity.notFound().build();
    }
     }
    
}
