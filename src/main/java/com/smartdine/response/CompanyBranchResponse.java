package com.smartdine.response;

public class CompanyBranchResponse {
    private Integer companyId;
    private String companyName;

    private Integer branchId;
    private String branchName;

    public CompanyBranchResponse(Integer companyId, String companyName,
                                 Integer branchId, String branchName) {
        this.companyId = companyId;
        this.companyName = companyName;
        this.branchId = branchId;
        this.branchName = branchName;
    }

    // Getter & Setter
    public Integer getCompanyId() {
        return companyId;
    }
    public void setCompanyId(Integer companyId) {
        this.companyId = companyId;
    }

    public String getCompanyName() {
        return companyName;
    }
    public void setCompanyName(String companyName) {
        this.companyName = companyName;
    }

    public Integer getBranchId() {
        return branchId;
    }
    public void setBranchId(Integer branchId) {
        this.branchId = branchId;
    }

    public String getBranchName() {
        return branchName;
    }
    public void setBranchName(String branchName) {
        this.branchName = branchName;
    }
}
