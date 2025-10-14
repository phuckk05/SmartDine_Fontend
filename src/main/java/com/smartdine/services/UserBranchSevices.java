package com.smartdine.services;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.smartdine.models.UserBranch;
import com.smartdine.repository.UserBranchReppository;

@Service
public class UserBranchSevices {
    @Autowired
    UserBranchReppository userBranchReppository;

    // Thêm mới
    public UserBranch create(UserBranch userBranch) {
        return userBranchReppository.save(userBranch);
    }
}