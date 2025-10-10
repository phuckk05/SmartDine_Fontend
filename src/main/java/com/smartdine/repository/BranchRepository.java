package com.smartdine.repository;

import com.smartdine.models.Branch;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

public interface BranchRepository extends JpaRepository<Branch, Integer> {

    boolean existsByBranchCode(String branchCode);

    Optional<Branch> findByBranchCode(String branchCode);
}
