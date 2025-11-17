package com.smartdine.response;

public class GetListCompanyAndOwnerResponse {
    private Integer companyId;
    private String companyName;
    private String ownerName;
    private String phoneNumber;
    private Integer userId;
    private Integer statusId;
    private Long totalBranches;

    // 🔥 Thêm 3 trường mới
    private String email;
    private String frontImage;
    private String backImage;

    public GetListCompanyAndOwnerResponse() {
    }

    // ✅ Constructor đầy đủ (có trường mới)
    public GetListCompanyAndOwnerResponse(
            Integer companyId,
            String companyName,
            Integer userId,
            String fullName,
            String phone,
            Long totalBranches,
            Integer statusId,
            String email,
            String frontImage,
            String backImage
    ) {
        this.companyId = companyId;
        this.companyName = companyName;
        this.userId = userId;
        this.ownerName = fullName;
        this.phoneNumber = phone;
        this.totalBranches = totalBranches;
        this.statusId = statusId;
        this.email = email;
        this.frontImage = frontImage;
        this.backImage = backImage;
    }

    // Overload long
    public GetListCompanyAndOwnerResponse(
            Integer companyId,
            String companyName,
            Integer userId,
            String fullName,
            String phone,
            long totalBranches,
            Integer statusId,
            String email,
            String frontImage,
            String backImage
    ) {
        this(companyId, companyName, userId, fullName, phone, Long.valueOf(totalBranches), statusId, email, frontImage, backImage);
    }

    // Overload int
    public GetListCompanyAndOwnerResponse(
            Integer companyId,
            String companyName,
            Integer userId,
            String fullName,
            String phone,
            int totalBranches,
            Integer statusId,
            String email,
            String frontImage,
            String backImage
    ) {
        this(companyId, companyName, userId, fullName, phone, Long.valueOf(totalBranches), statusId, email, frontImage, backImage);
    }

    // ========================
    // Getter & Setter
    // ========================
    public Integer getCompanyId() { return companyId; }
    public void setCompanyId(Integer companyId) { this.companyId = companyId; }

    public String getCompanyName() { return companyName; }
    public void setCompanyName(String companyName) { this.companyName = companyName; }

    public Integer getUserId() { return userId; }
    public void setUserId(Integer userId) { this.userId = userId; }

    public String getOwnerName() { return ownerName; }
    public void setOwnerName(String ownerName) { this.ownerName = ownerName; }

    public String getPhoneNumber() { return phoneNumber; }
    public void setPhoneNumber(String phoneNumber) { this.phoneNumber = phoneNumber; }

    public Long getTotalBranches() { return totalBranches; }
    public void setTotalBranches(Long totalBranches) { this.totalBranches = totalBranches; }

    public Integer getStatusId() { return statusId; }
    public void setStatusId(Integer statusId) { this.statusId = statusId; }

    // ⭐ Getter – Setter mới
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getFrontImage() { return frontImage; }
    public void setFrontImage(String frontImage) { this.frontImage = frontImage; }

    public String getBackImage() { return backImage; }
    public void setBackImage(String backImage) { this.backImage = backImage; }
}
