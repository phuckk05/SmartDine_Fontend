package com.smartdine.services;

import com.smartdine.models.User;
import com.smartdine.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Service
public class UserService {

    @Autowired
    private UserRepository userRepository;
    private UserBranchSevices userBranchSevices;

    public List<User> getAllUsers() {
        return userRepository.findAll();
    }

    // update password
    public User updatePassword(Integer id, String newPassword) {
        Optional<User> user = userRepository.findById(id);
        if (user.isEmpty()) {
            throw new IllegalArgumentException("User not found with id: " + id);
        }

        User u = user.get();
        u.setPassworkHash(newPassword);
        u.setUpdatedAt(LocalDateTime.now());
        return userRepository.save(u);
    }

    // Lấy user theo email
    public User getUserByEmail(String email) {
        return userRepository.findByEmail(email);
    }

    // Thêm mới user
    public User createUser(User user) {

        if (userRepository.existsByEmail(user.getEmail())) {
            throw new RuntimeException("Email đã tồn tại!");
        }
        if (userRepository.existsByPhone(user.getPhone())) {
            throw new RuntimeException("Số điện thoại đã tồn tại!");
        }

        // ensure timestamps
        if (user.getCreatedAt() == null) {
            user.setCreatedAt(java.time.LocalDateTime.now());
        }
        user.setUpdatedAt(java.time.LocalDateTime.now());

        return userRepository.save(user);
    }

    public User getUserById(Integer id) {
        return userRepository.findById(id).orElse(null);
    }

    // Xóa User
    public boolean deleteUser(Integer id) {
        userBranchSevices.deleteByUserId(id);
        userRepository.deleteById(id);
        return true;
    }

    // Cập nhật user
    public User updateUser(Integer id, User userDetails) {
        User user = userRepository.findById(id).orElse(null);
        if (user == null) {
            throw new IllegalArgumentException("User not found with id: " + id);
        }

        user.setFullName(userDetails.getFullName());
        user.setEmail(userDetails.getEmail());
        user.setPhone(userDetails.getPhone());
        user.setUpdatedAt(LocalDateTime.now());

        return userRepository.save(user);
    }
    
}