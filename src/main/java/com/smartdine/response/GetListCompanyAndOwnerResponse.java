package com.smartdine.response;

public class GetListCompanyAndOwnerResponse {
    private Integer companyId;      // ✅ Thêm ID công ty
    private String companyName;
    private String ownerName;
    private String phoneNumber;
    private Integer userId;
    private Integer statusId;
    private Long totalBranches;

    public GetListCompanyAndOwnerResponse() {
    }

    // ✅ Constructor đầy đủ (có companyId)
    public GetListCompanyAndOwnerResponse(
            Integer companyId,
            String companyName,
            Integer userId,
            String fullName,
            String phone,
            Long totalBranches,
            Integer statusId
    ) {
        this.companyId = companyId;
        this.companyName = companyName;
        this.userId = userId;
        this.ownerName = fullName;
        this.phoneNumber = phone;
        this.totalBranches = totalBranches;
        this.statusId = statusId;
    }

    // ✅ Overload cho primitive long
    public GetListCompanyAndOwnerResponse(
            Integer companyId,
            String companyName,
            Integer userId,
            String fullName,
            String phone,
            long totalBranches,
            Integer statusId
    ) {
        this(companyId, companyName, userId, fullName, phone, Long.valueOf(totalBranches), statusId);
    }

    // ✅ Overload cho primitive int
    public GetListCompanyAndOwnerResponse(
            Integer companyId,
            String companyName,
            Integer userId,
            String fullName,
            String phone,
            int totalBranches,
            Integer statusId
    ) {
        this(companyId, companyName, userId, fullName, phone, Long.valueOf(totalBranches), statusId);
    }

    // ========================
    // Getter & Setter
    // ========================
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

    public Integer getUserId() {
        return userId;
    }

    public void setUserId(Integer userId) {
        this.userId = userId;
    }

    public String getOwnerName() {
        return ownerName;
    }

    public void setOwnerName(String ownerName) {
        this.ownerName = ownerName;
    }

    public String getPhoneNumber() {
        return phoneNumber;
    }

    public void setPhoneNumber(String phoneNumber) {
        this.phoneNumber = phoneNumber;
    }

    public Long getTotalBranches() {
        return totalBranches;
    }

    public void setTotalBranches(Long totalBranches) {
        this.totalBranches = totalBranches;
    }

    public Integer getStatusId() {
        return statusId;
    }

    public void setStatusId(Integer statusId) {
        this.statusId = statusId;
    }
}
