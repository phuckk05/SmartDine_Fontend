package com.smartdine.response;

public class GetListCompanyAndOwnerResponse {
    private String companyName;
    private String ownerName;
    private String phoneNumber;
    private Integer userId;
    private Long totalBranches;

    public GetListCompanyAndOwnerResponse() {
    }

    public GetListCompanyAndOwnerResponse(String companyName, Integer userId, String fullName, String phone, Long totalBranches) {
        this.companyName = companyName;
        this.userId = userId;
        this.ownerName = fullName;
        this.phoneNumber = phone;
        this.totalBranches = totalBranches; // ép sang int nếu cần
    }

    // accept primitive long (JPA may pass primitive long)
    public GetListCompanyAndOwnerResponse(String companyName, Integer userId, String fullName, String phone, long totalBranches) {
        this(companyName, userId, fullName, phone, Long.valueOf(totalBranches));
    }

    // optional: accept int (in case JPA returns int)
    public GetListCompanyAndOwnerResponse(String companyName, Integer userId, String fullName, String phone, int totalBranches) {
        this(companyName, userId, fullName, phone, Long.valueOf(totalBranches));
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
}