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

    @Autowired
    private UserRepository userRepository;


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
    public Company approveCompany(Integer companyId) {
        // Lấy company cần duyệt
        Company company = companyRepository.findById(companyId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy công ty có id = " + companyId));

        // Cập nhật status company thành 1 (đã duyệt)
        company.setStatusId(1);
        company.setUpdatedAt(LocalDateTime.now());
        companyRepository.save(company);

        // ✅ Cập nhật luôn user (chủ công ty) tương ứng
        List<User> owners = userRepository.findByCompanyIdAndRole(companyId, 1); // role=1 => Owner
        for (User owner : owners) {
            owner.setStatusId(1); // Duyệt luôn user
            owner.setUpdatedAt(LocalDateTime.now());
            userRepository.save(owner);
        }

        return company;
    }

    /// Từ chối công ty
    @Transactional
    public Company rejectCompany(Integer companyId) {
        // 1️⃣ Lấy thông tin công ty
        Company company = companyRepository.findById(companyId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy công ty có id = " + companyId));

        // 2️⃣ Cập nhật trạng thái công ty => 2 (bị từ chối)
        company.setStatusId(2);
        company.setUpdatedAt(LocalDateTime.now());
        companyRepository.save(company);

        // 3️⃣ Cập nhật luôn user là chủ công ty (role = 1)
        List<User> owners = userRepository.findByCompanyIdAndRole(companyId, 1);
        for (User owner : owners) {
            owner.setStatusId(2); // Từ chối user luôn
            owner.setUpdatedAt(LocalDateTime.now());
            userRepository.save(owner);
        }

        return company;
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
