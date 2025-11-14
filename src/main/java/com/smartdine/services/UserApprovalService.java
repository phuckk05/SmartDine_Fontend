package com.smartdine.services;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.smartdine.models.User;
import com.smartdine.repository.UserRepository;

@Service
public class UserApprovalService {

    @Autowired
    private UserRepository userRepository;

    // Lấy danh sách user chờ duyệt theo companyId
    public List<User> getPendingUsersByCompany(Integer companyId) {
        return userRepository.findByCompanyIdAndStatusIdOrderByCreatedAtDesc(companyId, 3);
    }

    // Lấy danh sách user chờ duyệt theo branchId (thông qua user_branches table)
    public List<User> getPendingUsersByBranch(Integer branchId) {
        // Tạm thời sử dụng cách đơn giản - lấy tất cả user statusId = 3
        // Sau này có thể tối ưu với JOIN query nếu cần
        return userRepository.findByStatusIdOrderByCreatedAtDesc(3);
    }

    // Duyệt user (chuyển statusId từ 3 -> 1: Active)
    public boolean approveUser(Integer userId) {
        Optional<User> userOpt = userRepository.findById(userId);
        if (userOpt.isPresent()) {
            User user = userOpt.get();
            if (user.getStatusId() == 3) { // Chỉ duyệt user đang chờ duyệt
                user.setStatusId(1); // Active
                user.setUpdatedAt(LocalDateTime.now());
                userRepository.save(user);
                return true;
            }
        }
        return false;
    }

    // Từ chối user (chuyển statusId từ 3 -> 2: Inactive/Rejected)
    public boolean rejectUser(Integer userId, String reason) {
        Optional<User> userOpt = userRepository.findById(userId);
        if (userOpt.isPresent()) {
            User user = userOpt.get();
            if (user.getStatusId() == 3) { // Chỉ từ chối user đang chờ duyệt
                user.setStatusId(2); // Inactive/Rejected
                user.setUpdatedAt(LocalDateTime.now());
                // Có thể lưu lý do từ chối vào một trường note nếu cần
                userRepository.save(user);
                return true;
            }
        }
        return false;
    }

    // Khóa user (chuyển statusId -> 2: Blocked)
    public boolean blockUser(Integer userId, String reason) {
        Optional<User> userOpt = userRepository.findById(userId);
        if (userOpt.isPresent()) {
            User user = userOpt.get();
            user.setStatusId(2); // Blocked/Inactive
            user.setUpdatedAt(LocalDateTime.now());
            userRepository.save(user);
            return true;
        }
        return false;
    }

    // Thống kê số lượng user theo trạng thái
    public Map<String, Integer> getPendingStatistics(Integer companyId) {
        Map<String, Integer> stats = new HashMap<>();
        
        // Đếm số user chờ duyệt
        int pendingCount = userRepository.countByCompanyIdAndStatusId(companyId, 3);
        
        // Đếm số user active
        int activeCount = userRepository.countByCompanyIdAndStatusId(companyId, 1);
        
        // Đếm số user inactive/blocked
        int inactiveCount = userRepository.countByCompanyIdAndStatusId(companyId, 2);
        
        // Tổng số user
        int totalCount = userRepository.countByCompanyId(companyId);
        
        stats.put("pending", pendingCount);
        stats.put("active", activeCount);
        stats.put("inactive", inactiveCount);
        stats.put("total", totalCount);
        
        return stats;
    }

    // Lấy user theo ID để kiểm tra trạng thái
    public User getUserById(Integer userId) {
        return userRepository.findById(userId).orElse(null);
    }

    // Kiểm tra user có đang chờ duyệt không
    public boolean isUserPending(Integer userId) {
        Optional<User> user = userRepository.findById(userId);
        return user.isPresent() && user.get().getStatusId() == 3;
    }

    // Lấy tất cả user chờ duyệt (không phân biệt company)
    public List<User> getAllPendingUsers() {
        return userRepository.findByStatusIdOrderByCreatedAtDesc(3);
    }
}