package com.smartdine.controllers;

import java.util.Collections;
import java.util.List;
import java.util.Map;

import com.smartdine.response.GetListCompanyAndOwnerResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.smartdine.models.Company;
import com.smartdine.services.CompanyServices;
import com.smartdine.services.BranchServices;

@RestController
@RequestMapping({ "/api/companys", "/api/company" })
public class CompanyController {
    @Autowired
    CompanyServices companyServices;

    @Autowired
    BranchServices branchServices;

    @GetMapping("/all")
    public ResponseEntity<?> getAllCompanys() {
        try {
            List<Company> companys = companyServices.getAll();
            return ResponseEntity.ok(companys);
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.internalServerError().body("Loi " + e.getMessage());
        }
    }

    @GetMapping("/with-branches")
    public ResponseEntity<?> getCompaniesWithBranches() {
        try {
            List<Map<String, Object>> data = companyServices.getCompaniesWithBranches(branchServices);
            return ResponseEntity.ok(Collections.singletonMap("companies", data));
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.internalServerError()
                    .body("Lỗi lấy danh sách công ty kèm chi nhánh: " + e.getMessage());
        }
    }

    @PostMapping
    public ResponseEntity<?> createCompany(@RequestBody Company company) {
        try {
            Company create = companyServices.save(company);
            return ResponseEntity.ok(create);
        } catch (Exception e) {
            return ResponseEntity.internalServerError().body(e.getMessage());
        }
    }

    @GetMapping("/{companyCode}")
    public ResponseEntity<?> existsByCompanyCode(@PathVariable String companyCode) {
        try {
            Company company = companyServices.existsByCompanyCode(companyCode);
            return ResponseEntity.ok(company);
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.badRequest().body(null);
        }
    }

    /// Lấy danh sách công ty chờ xác nhận (statusId = 3)
    @GetMapping("/pending")
    public ResponseEntity<?> getPendingCompanies() {
        try {
            List<Company> pending = companyServices.getPendingCompanies();
            return ResponseEntity.ok(pending);
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.internalServerError().body("Lỗi khi lấy danh sách pending");
        }
    }

    /// Duyệt công ty
    @PutMapping("/approve/{id}")
    public ResponseEntity<?> approveCompany(@PathVariable Integer id) {
        try {
            Company approved = companyServices.approveCompany(id);
            return ResponseEntity.ok(approved);
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.badRequest().body("Lỗi khi duyệt công ty: " + e.getMessage());
        }
    }

    /// Từ chối công ty
    @PutMapping("/reject/{id}")
    public ResponseEntity<?> rejectCompany(@PathVariable Integer id) {
        try {
            Company rejected = companyServices.rejectCompany(id);
            return ResponseEntity.ok(rejected);
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.badRequest().body("Lỗi khi từ chối công ty: " + e.getMessage());
        }
    }

    /// Xóa công ty
    @DeleteMapping("/delete/{id}")
    public ResponseEntity<?> deleteCompany(@PathVariable Integer id) {
        try {
            boolean result = companyServices.deleteCompany(id);
            if (result) {
                return ResponseEntity.ok("Đã xóa thành công công ty có ID = " + id);
            } else {
                return ResponseEntity.badRequest().body("Không tìm thấy công ty ID = " + id);
            }
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.internalServerError().body("Lỗi khi xóa công ty");
        }
    }

    /// Thống kê công ty
    @GetMapping("/stats")
    public ResponseEntity<?> getCompanyStats(@RequestParam("companyId") Integer companyId) {
        try {
            return ResponseEntity.ok(companyServices.getCompanyStats(companyId));
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.internalServerError().body("Lỗi khi lấy thống kê công ty: " + e.getMessage());
        }
    }

<<<<<<< HEAD
    // Quản lý cửa hàng
    // ✅ Danh sách công ty đã duyệt (active)
    @GetMapping("/active")
    public ResponseEntity<?> getActiveCompanies() {
=======


    @GetMapping("/get-list-company-and-owner")
    public ResponseEntity<List<GetListCompanyAndOwnerResponse>> getListCompanyAndOwner() {
>>>>>>> bc249b156ae2cd818951108c384e8d1a5b110004
        try {
            List<GetListCompanyAndOwnerResponse> list = companyServices.getListCompanyAndOwner();
            return ResponseEntity.ok(list);
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.internalServerError().build();
        }
    }

    @PutMapping("/active/{id}")
    public ResponseEntity<?> activateCompany(@PathVariable Integer id) {
        try {
            Company activated = companyServices.updateCompanyStatus(id, 1);
            return ResponseEntity.ok(activated);
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.badRequest().body("Lỗi khi kích hoạt công ty: " + e.getMessage());
        }
    }

    @PutMapping("/inactive/{id}")
    public ResponseEntity<?> deactivateCompany(@PathVariable Integer id) {
        try {
            Company deactivated = companyServices.updateCompanyStatus(id, 2);
            return ResponseEntity.ok(deactivated);
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.badRequest().body("Lỗi khi vô hiệu hóa công ty: " + e.getMessage());
        }
    }

}
