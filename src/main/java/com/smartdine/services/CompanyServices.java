package com.smartdine.services;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.smartdine.models.Company;
import com.smartdine.models.User;
import com.smartdine.repository.BranchRepository;
import com.smartdine.repository.CompanyRepository;
import com.smartdine.repository.UserRepository;
import com.smartdine.response.GetListCompanyAndOwnerResponse;

import jakarta.transaction.Transactional;

@Service
public class CompanyServices {
    @Autowired
    CompanyRepository companyRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private BranchRepository branchRepository;

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

    /// Danh sách xác nhận chờ duyệt
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
        List<User> owners = userRepository.findByCompanyIdAndRole(companyId, 5); // role=1 => Owner
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
        List<User> owners = userRepository.findByCompanyIdAndRole(companyId, 5);
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

    public java.util.Map<String, Object> getCompanyStats(Integer companyId) {
        Company company = companyRepository.findById(companyId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy công ty"));

        long branchCount = branchRepository.countByCompanyId(companyId);
        long employeeCount = userRepository.findByCompanyId(companyId).size();
        long activeEmployeeCount = userRepository.findByCompanyIdAndRole(companyId, 2).size();

        java.util.Map<String, Object> stats = new java.util.HashMap<>();
        stats.put("companyId", company.getId());
        stats.put("companyName", company.getName());
        stats.put("totalBranches", branchCount);
        stats.put("totalEmployees", employeeCount);
        stats.put("activeStaff", activeEmployeeCount);
        stats.put("createdAt", company.getCreatedAt());
        stats.put("statusId", company.getStatusId());
        return stats;
    }

    // Quản lý cửa hàng
    // ✅ Danh sách công ty đã được duyệt (statusId = 1)
    public List<Company> getActiveCompanies() {
        return companyRepository.findByStatusId(1);
    }

    // ✅ Kích hoạt / vô hiệu hóa công ty
    @Transactional
    public Company toggleCompanyStatus(Integer companyId, boolean isActive) {
        Company company = companyRepository.findById(companyId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy công ty có id = " + companyId));

        company.setStatusId(isActive ? 1 : 2); // 1 = Active, 2 = Inactive
        company.setUpdatedAt(LocalDateTime.now());
        companyRepository.save(company);

        // Cập nhật luôn user chủ công ty
        List<User> owners = userRepository.findByCompanyIdAndRole(companyId, 5);
        for (User owner : owners) {
            owner.setStatusId(isActive ? 1 : 2);
            owner.setUpdatedAt(LocalDateTime.now());
            userRepository.save(owner);
        }

        return company;
    }

    public List<Map<String, Object>> getCompaniesWithBranches(BranchServices branchServices) {
        List<Company> companies = companyRepository.findAll();
        List<Map<String, Object>> result = new ArrayList<>();

        for (Company company : companies) {
            Map<String, Object> companyMap = new HashMap<>();
            companyMap.put("id", company.getId());
            companyMap.put("name", company.getName());
            companyMap.put("company_code", company.getCompanyCode());
            companyMap.put("statusId", company.getStatusId());
            companyMap.put("createdAt", company.getCreatedAt());

            List<Map<String, Object>> branchList = new ArrayList<>();
            branchServices.getByCompanyId(company.getId()).forEach(branch -> {
                Map<String, Object> branchMap = new HashMap<>();
                branchMap.put("id", branch.getId());
                branchMap.put("company_id", branch.getCompanyId());
                branchMap.put("name", branch.getName());
                branchMap.put("active", branch.getStatusId() != null ? branch.getStatusId() == 1 : Boolean.TRUE);
                branchList.add(branchMap);
            });

            companyMap.put("branches", branchList);
            result.add(companyMap);
        }

        return result;
    }

    public List<GetListCompanyAndOwnerResponse> getListCompanyAndOwner() {
        return companyRepository.getListCompanyAndOwner();
    }

    // ✅ Update status (1 = active, 2 = inactive)
    public Company updateCompanyStatus(Integer id, Integer statusId) {
        Company company = companyRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy công ty với ID: " + id));
        company.setStatusId(statusId);
        return companyRepository.save(company);
    }
}
