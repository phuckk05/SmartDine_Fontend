package com.smartdine.response;

public class GetListCompanyAndOwnerResponse {
    private String companyName;
    private String ownerName;
    private String phoneNumber;
    private Integer userId;
    private Integer statusId;
    private Long totalBranches;

    public GetListCompanyAndOwnerResponse() {
    }

    // Constructor đầy đủ (với statusId)
    public GetListCompanyAndOwnerResponse(
            String companyName,
            Integer userId,
            String fullName,
            String phone,
            Long totalBranches,
            Integer statusId
    ) {
        this.companyName = companyName;
        this.userId = userId;
        this.ownerName = fullName;
        this.phoneNumber = phone;
        this.totalBranches = totalBranches;
        this.statusId = statusId;
    }

    // Overload để tương thích JPA (primitive long)
    public GetListCompanyAndOwnerResponse(
            String companyName,
            Integer userId,
            String fullName,
            String phone,
            long totalBranches,
            Integer statusId
    ) {
        this(companyName, userId, fullName, phone, Long.valueOf(totalBranches), statusId);
    }

    // Overload để tương thích JPA (primitive int)
    public GetListCompanyAndOwnerResponse(
            String companyName,
            Integer userId,
            String fullName,
            String phone,
            int totalBranches,
            Integer statusId
    ) {
        this(companyName, userId, fullName, phone, Long.valueOf(totalBranches), statusId);
    }

    // ========================
    // Getter & Setter
    // ========================
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
