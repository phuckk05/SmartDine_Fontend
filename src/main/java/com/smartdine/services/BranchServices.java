package com.smartdine.services;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.smartdine.models.Branch;
import com.smartdine.repository.BranchRepository;

@Service
public class BranchServices {

    @Autowired
    private BranchRepository branchRepository;

    public Branch getBranchById(Long id) {
        return branchRepository.findById(id).orElse(null);
    }

    // Tìm branch code và lấy thông tin chi nhánh đó
    public Branch findBranch(String branchCode) {
        if (branchRepository.existsBranchCode(branchCode)) {
            return branchRepository.findByBranchCode(branchCode).orElse(null);
        }
        return null;
    }
}
