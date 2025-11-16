package com.smartdine.controllers;

import com.smartdine.dto.AdminStatsDTO;
import com.smartdine.repository.BranchRepository;
import com.smartdine.repository.CompanyRepository;
import com.smartdine.response.ApiResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/admin")
public class AdminController {

    @Autowired
    private CompanyRepository companyRepository;

    @Autowired
    private BranchRepository branchRepository;

    // API thống kê
    @GetMapping("/stats")
    public ResponseEntity<ApiResponse<AdminStatsDTO>> getStatistics() {

        long totalCompanies = companyRepository.count();
        long totalBranches  = branchRepository.count();

        AdminStatsDTO stats = new AdminStatsDTO(totalCompanies, totalBranches);

        return ResponseEntity.ok(
                new ApiResponse<>(
                        200,
                        "Lấy thống kê thành công",
                        stats
                )
        );
    }

}
