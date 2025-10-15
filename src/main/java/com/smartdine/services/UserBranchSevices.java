package com.smartdine.services;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.smartdine.models.UserBranch;
import com.smartdine.repository.UserBranchRepository;

@Service
public class UserBranchSevices {
    @Autowired
    UserBranchRepository userBranchRepository;

    // Thêm mới
    public UserBranch create(UserBranch userBranch) {
        return userBranchRepository.save(userBranch);
    }
}