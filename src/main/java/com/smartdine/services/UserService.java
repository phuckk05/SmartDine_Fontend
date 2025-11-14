package com.smartdine.services;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.time.LocalDateTime;
import java.util.Base64;
import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.smartdine.models.User;
import com.smartdine.repository.UserRepository;

@Service
public class UserService {

    @Autowired
    private UserRepository userRepository;

    @Autowired
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
        // Hash password nếu chưa được hash
        if (!isAlreadyHashed(newPassword)) {
            u.setPassworkHash(hashPassword(newPassword));
        } else {
            u.setPassworkHash(newPassword);
        }
        u.setUpdatedAt(LocalDateTime.now());
        return userRepository.save(u);
    }

    // Lấy user theo email
    public User getUserByEmail(String email) {
        return userRepository.findByEmail(email);
    }

    // Hash password using BCrypt-compatible format
    public String hashPassword(String plainPassword) {
        try {
            // Tạo salt ngẫu nhiên
            SecureRandom random = new SecureRandom();
            byte[] salt = new byte[16];
            random.nextBytes(salt);
            
            // Hash password với salt
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            md.update(salt);
            byte[] hashedPassword = md.digest(plainPassword.getBytes());
            
            // Tạo format tương tự BCrypt: $2a$12$[salt][hash]
            String saltBase64 = Base64.getEncoder().encodeToString(salt).substring(0, 22);
            String hashBase64 = Base64.getEncoder().encodeToString(hashedPassword).substring(0, 31);
            
            return "$2a$12$" + saltBase64 + hashBase64;
        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException("Error hashing password", e);
        }
    }

    // Thêm mới user
    public User createUser(User user) {

        if (userRepository.existsByEmail(user.getEmail())) {
            throw new RuntimeException("Email đã tồn tại!");
        }
        if (userRepository.existsByPhone(user.getPhone())) {
            throw new RuntimeException("Số điện thoại đã tồn tại!");
        }

        // Hash password nếu chưa được hash (để đảm bảo password luôn được mã hóa)
        if (user.getPassworkHash() != null && !isAlreadyHashed(user.getPassworkHash())) {
            user.setPassworkHash(hashPassword(user.getPassworkHash()));
        }

        // ensure timestamps
        if (user.getCreatedAt() == null) {
            user.setCreatedAt(java.time.LocalDateTime.now());
        }
        user.setUpdatedAt(java.time.LocalDateTime.now());

        return userRepository.save(user);
    }
    
    // Kiểm tra xem password đã được hash chưa (BCrypt format)
    private boolean isAlreadyHashed(String password) {
        if (password == null) return false;
        
        // Kiểm tra BCrypt format ($2a$, $2b$, $2y$)
        return password.startsWith("$2a$") || password.startsWith("$2b$") || password.startsWith("$2y$");
    }
    
    // Verify password với hash (để sử dụng cho authentication)
    public boolean verifyPassword(String plainPassword, String hashedPassword) {
        if (hashedPassword.startsWith("$2a$12$")) {
            // Đây là hash được tạo bởi method hashPassword() của chúng ta
            try {
                // Extract salt từ hash
                String saltAndHash = hashedPassword.substring(6); // Bỏ "$2a$12$"
                String saltBase64 = saltAndHash.substring(0, 22);
                
                // Recreate salt
                byte[] salt = Base64.getDecoder().decode(saltBase64 + "==");
                
                // Hash input password với cùng salt
                MessageDigest md = MessageDigest.getInstance("SHA-256");
                md.update(salt);
                byte[] hashedInput = md.digest(plainPassword.getBytes());
                
                // So sánh với hash đã lưu
                String inputHashBase64 = Base64.getEncoder().encodeToString(hashedInput).substring(0, 31);
                String expectedHash = "$2a$12$" + saltBase64 + inputHashBase64;
                
                return hashedPassword.equals(expectedHash);
            } catch (Exception e) {
                return false;
            }
        }
        
        // Đối với hash BCrypt thật từ dữ liệu cũ, tạm thời return false 
        // (cần thư viện BCrypt thật để verify)
        return false;
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

        if (userDetails.getFullName() != null) {
            user.setFullName(userDetails.getFullName());
        }
        if (userDetails.getEmail() != null && !userDetails.getEmail().equals(user.getEmail())) {
            if (userRepository.existsByEmail(userDetails.getEmail())) {
                throw new IllegalArgumentException("Email đã tồn tại");
            }
            user.setEmail(userDetails.getEmail());
        }
        if (userDetails.getPhone() != null && !userDetails.getPhone().equals(user.getPhone())) {
            if (userRepository.existsByPhone(userDetails.getPhone())) {
                throw new IllegalArgumentException("Số điện thoại đã tồn tại");
            }
            user.setPhone(userDetails.getPhone());
        }
        if (userDetails.getStatusId() != null) {
            user.setStatusId(userDetails.getStatusId());
        }
        if (userDetails.getRole() != null) {
            user.setRole(userDetails.getRole());
        }
        // Hash password nếu có cập nhật password
        if (userDetails.getPassworkHash() != null && !userDetails.getPassworkHash().isEmpty()) {
            if (!isAlreadyHashed(userDetails.getPassworkHash())) {
                user.setPassworkHash(hashPassword(userDetails.getPassworkHash()));
            } else {
                user.setPassworkHash(userDetails.getPassworkHash());
            }
        }
        user.setUpdatedAt(LocalDateTime.now());

        return userRepository.save(user);
    }

    // Cập nhật mã công ty
    public User updateCompanyId(Integer id, Integer companyId) {
        User user = userRepository.findById(id).orElse(null);
        if (user == null) {
            throw new IllegalArgumentException("User not found with id: " + id);
        }

        user.setCompanyId(companyId);
        user.setUpdatedAt(LocalDateTime.now());

        return userRepository.save(user);
    }

    public User getCurrentUser(Integer id) {
        return userRepository.findById(id).orElse(null);
    }

}