package com.smartdine.response;

public class GetListCompanyAndOwnerResponse {
    private String companyName;
    private Integer userId;
    private String ownerName;
    private String phoneNumber;

    public GetListCompanyAndOwnerResponse() {
    }

    public GetListCompanyAndOwnerResponse(String companyName, Integer userId, String ownerName, String phoneNumber) {
        this.companyName = companyName;
        this.userId = userId;
        this.ownerName = ownerName;
        this.phoneNumber = phoneNumber;
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
}