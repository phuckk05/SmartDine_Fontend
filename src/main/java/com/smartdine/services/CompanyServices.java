package com.smartdine.services;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.smartdine.models.Company;
import com.smartdine.repository.CompanyRepository;

@Service
public class CompanyServices {
    @Autowired
    CompanyRepository companyRepository;

    // Lấy tất cà company
    public List<Company> getAll() {
        return companyRepository.findAll();
    }

    // Thêm mới company
    public Company save(Company company) {
        return companyRepository.save(company);
    }

    // Kiểm tra companyCode
    public Company existsByCompanyCode(String companyCode) {
        return companyRepository.existsByCompanyCode(companyCode).orElse(null);
    }

}
