package com.smartdine.services;

import com.smartdine.models.User;
import com.smartdine.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class UserService {

    @Autowired
    private UserRepository userRepository;

    public List<User> getAllUsers() {
        return userRepository.findAll();
    }

    public User createUser(User user) {
        if (user.getEmail() == null || user.getEmail().trim().isEmpty()) {
            throw new RuntimeException("Email không được để trống");
        }
        if (user.getPhone() == null || user.getPhone().trim().isEmpty()) {
            throw new RuntimeException("Số điện thoại không được để trống");
        }

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

    public void deleteUser(Integer id) {
        userRepository.deleteById(id);
    }
}