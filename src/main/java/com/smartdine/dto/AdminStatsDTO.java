package com.smartdine.dto;

public class AdminStatsDTO {
    private long totalCompanies;
    private long totalBranches;

    public AdminStatsDTO(long totalCompanies, long totalBranches) {
        this.totalCompanies = totalCompanies;
        this.totalBranches = totalBranches;
    }

    public long getTotalCompanies() {
        return totalCompanies;
    }

    public long getTotalBranches() {
        return totalBranches;
    }
}
