package com.smartdine.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import com.smartdine.models.status.CompanyStatus;

public interface CompanyStatusRepository extends JpaRepository<CompanyStatus, Integer> {
}
