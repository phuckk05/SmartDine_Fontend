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
        return companyRepository.findByCompanyCode(companyCode).orElse(null);
    }

    /// Danh sách công ty chờ duyệt
    public List<Company> getPendingCompanies() {
        return companyRepository.findByStatusId(3);
    }

    /// Duyệt công ty
    public Company approveCompany(Integer id) {
        Company company = companyRepository.findById(id).orElseThrow();
        company.setStatusId(1); // đã duyệt
        return companyRepository.save(company);
    }

    /// Từ chối công ty
    public Company rejectCompany(Integer id) {
        Company company = companyRepository.findById(id).orElseThrow();
        company.setStatusId(2); // bị từ chối
        return companyRepository.save(company);
    }

    /// Xóa company
    public boolean deleteCompany(Integer id) {
        if (companyRepository.existsById(id)) {
            companyRepository.deleteById(id);
            return true;
        }
        return false;
    }

}
