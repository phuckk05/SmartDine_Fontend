package com.smartdine.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import com.smartdine.models.UserCompany;

public interface UserCompanyRepository extends JpaRepository<UserCompany, Integer> {
    boolean existsByCompanyCode(String email);
}
