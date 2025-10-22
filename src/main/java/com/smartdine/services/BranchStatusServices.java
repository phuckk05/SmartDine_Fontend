package com.smartdine.services;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.smartdine.models.BranchStatus;
import com.smartdine.repository.BranchStatusRepository;

@Service
public class BranchStatusServices {
    @Autowired
    private BranchStatusRepository branchStatusRepository;

    public List<BranchStatus> getAll() {
        return branchStatusRepository.findAll();
    }

    public BranchStatus getById(Integer id) {
        return branchStatusRepository.findById(id).orElse(null);
    }
}
