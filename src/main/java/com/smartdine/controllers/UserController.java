package com.smartdine.backend.controller;

import com.smartdine.backend.model.User;
import org.springframework.http.ResponseEntity;
import java.util.Optional;
import com.smartdine.backend.repository.UserRepository;

import com.smartdine.backend.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/users")
public class UserController {

    @Autowired
    private UserService userService;
     @Autowired
    private UserRepository userRepository;
    

    //Lấy all user
    @GetMapping
    public List<User> getUsers() {
        return userService.getAllUsers();
    }
    
    //Tạo user
    @PostMapping
    public ResponseEntity<?> createUser(@RequestBody User user) {
        try{
           User createUser = userService.createUser(user)
           return ResponseEntity.ok(createUser)
        } catch(){
           return ResponseEntity.badRequest().body(e.getMessage());
        }
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
