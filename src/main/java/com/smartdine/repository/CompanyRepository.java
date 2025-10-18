package com.smartdine.repository;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

import com.smartdine.models.Company;

public interface CompanyRepository extends JpaRepository<Company, Integer> {
    Optional<Company> existsByCompanyCode(String comapanyCode);
}
