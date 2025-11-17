package com.smartdine.response;

public class GetListPendingCompanyAndOwnerResponse {
    private Integer companyId;
    private String companyName;
    private String companyCode;
    private String address;
    private String createdAt;
    private String updatedAt;
    private String companyStatus;

    private Integer userId;
    private String phoneNumber;
    private String fullName;
    private String email;
    private String phone;

    private String frontImage;  // NEW
    private String backImage;   // NEW
    private String ownerStatus; // NEW

    public GetListPendingCompanyAndOwnerResponse() {}

    // === Getters & Setters ===

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

    public String getCompanyCode() {
        return companyCode;
    }
    public void setCompanyCode(String companyCode) {
        this.companyCode = companyCode;
    }

    public String getAddress() {
        return address;
    }
    public void setAddress(String address) {
        this.address = address;
    }

    public String getCreatedAt() {
        return createdAt;
    }
    public void setCreatedAt(String createdAt) {
        this.createdAt = createdAt;
    }

    public String getUpdatedAt() {
        return updatedAt;
    }
    public void setUpdatedAt(String updatedAt) {
        this.updatedAt = updatedAt;
    }

    public String getCompanyStatus() {
        return companyStatus;
    }
    public void setCompanyStatus(String companyStatus) {
        this.companyStatus = companyStatus;
    }

    public Integer getUserId() {
        return userId;
    }
    public void setUserId(Integer userId) {
        this.userId = userId;
    }

    public String getFullName() {
        return fullName;
    }
    public void setFullName(String fullName) {
        this.fullName = fullName;
    }

    public String getEmail() {
        return email;
    }
    public void setEmail(String email) {
        this.email = email;
    }

    public String getPhone() {
        return phone;
    }
    public void setPhone(String phone) {
        this.phone = phone;
    }

    public String getFrontImage() {
        return frontImage;
    }
    public void setFrontImage(String frontImage) {
        this.frontImage = frontImage;
    }

    public String getBackImage() {
        return backImage;
    }
    public void setBackImage(String backImage) {
        this.backImage = backImage;
    }

    public String getOwnerStatus() {
        return ownerStatus;
    }
    public void setOwnerStatus(String ownerStatus) {
        this.ownerStatus = ownerStatus;
    }

    public String getPhoneNumber() {
        return phoneNumber;
    }
    public void setPhoneNumber(String phoneNumber) {
        this.phoneNumber = phoneNumber;
    }
}
