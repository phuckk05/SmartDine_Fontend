package com.smartdine.backend.service;

import com.smartdine.backend.model.User;
import com.smartdine.backend.repository.UserRepository;
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
        if(userRepository.existsByEmail(user.getEmail())){
            throw new RuntimeException("Email đã tồn tại!");
        }
        if (userRepository.existsByPhone(user.getPhone())) {
            throw new RuntimeException("Số điện thoại đã tồn tại!");
        }
        return userRepository.save(user)
    }

    public User getUserById(Long id) {
        return userRepository.findById(id).orElse(null);
    }

    public void deleteUser(Long id) {
        userRepository.deleteById(id);
    }
}