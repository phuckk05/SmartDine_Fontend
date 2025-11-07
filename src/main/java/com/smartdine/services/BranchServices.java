package com.smartdine.services;

import java.time.LocalDateTime;
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

    public List<Branch> getByCompanyId(Integer companyId) {
        return branchRepository.findByCompanyId(companyId);
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

    // Lấy branch theo id
    public Branch getBranchById(Integer id) {
        return branchRepository.findById(id).orElse(null);
    }

    // Cập nhật branch
    public Branch updateBranch(Integer id, Branch payload) {
        return branchRepository.findById(id).map(existing -> {
            if (payload.getName() != null) {
                existing.setName(payload.getName());
            }
            if (payload.getAddress() != null) {
                existing.setAddress(payload.getAddress());
            }
            if (payload.getBranchCode() != null) {
                existing.setBranchCode(payload.getBranchCode());
            }
            if (payload.getStatusId() != null) {
                existing.setStatusId(payload.getStatusId());
            }
            if (payload.getManagerId() != null) {
                existing.setManagerId(payload.getManagerId());
            }
            if (payload.getImage() != null) {
                existing.setImage(payload.getImage());
            }
            if (payload.getCompanyId() != null) {
                existing.setCompanyId(payload.getCompanyId());
            }
            existing.setUpdatedAt(LocalDateTime.now());
            return branchRepository.save(existing);
        }).orElse(null);
    }
}
