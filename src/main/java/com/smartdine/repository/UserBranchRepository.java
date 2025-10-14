package com.smartdine.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import com.smartdine.models.UserBranch;

public interface UserBranchRepository extends JpaRepository<UserBranch, Integer> {
}
