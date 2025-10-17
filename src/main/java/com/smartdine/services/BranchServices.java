package com.smartdine.services;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.smartdine.models.Branch;
import com.smartdine.repository.BranchRepository;

@Service
public class BranchServices {

    @Autowired
    private BranchRepository branchRepository;

    // Cập nhật branch
    // Xóa branch

    // Thêm mới branch
    public Branch create(Branch branch) {
        return branchRepository.save(branch);
    }

    // Lấy all branch
    public List<Branch> getAll() {
        return branchRepository.findAll();
    }

    // Tìm branch bằng id
    public Branch getBranchById(int id) {
        return branchRepository.findById(id).orElse(null);
    }

    // Tìm branch code và lấy thông tin chi nhánh đó
    public Branch findBranch(String branchCode) {
        if (branchRepository.existsByBranchCode(branchCode)) {
            return branchRepository.findByBranchCode(branchCode).orElse(null);
        }
        return null;
    }
}
