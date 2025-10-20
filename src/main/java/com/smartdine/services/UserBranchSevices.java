package com.smartdine.services;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.smartdine.models.UserBranch;
import com.smartdine.repository.UserBranchRepository;

@Service
public class UserBranchSevices {
    @Autowired
    UserBranchRepository userBranchRepository;

    public List<UserBranch> getAll() {
        return userBranchRepository.findAll();
    }

    // Thêm mới
    public UserBranch create(UserBranch userBranch) {
        return userBranchRepository.save(userBranch);
    }

    // Lấy UserBranch theo userId
    public UserBranch getByUserId(Integer userId) {
        return userBranchRepository.findByUserId(userId);
    }
}