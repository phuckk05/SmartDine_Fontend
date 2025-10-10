package com.smartdine.repository;

import com.smartdine.models.Branch;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

public interface BranchRepository extends JpaRepository<Branch, Long> {
    boolean existsBranchCode(String BranchCode);

    Optional<Branch> findByBranchCode(String branchCode);
}
