package com.smartdine.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import com.smartdine.models.BranchStatus;

public interface BranchStatusRepository extends JpaRepository<BranchStatus, Integer> {
}
