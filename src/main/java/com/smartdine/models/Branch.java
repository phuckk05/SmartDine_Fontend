package com.smartdine.models;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "branches")
public class Branch {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id; // Mã chi nhánh

    @Column(name = "company_id")
    private Integer companyId; // Mã công ty
    @Column(name = "name")
    private String name; // Tên chi nhánh
    @Column(name = "branch_code")
    private String branchCode; // Mã code để gộp nhân viên
    @Column(name = "address")
    private String address; // Địa chỉ nhà hàng
    @Column(name = "image")
    private String image; // Ảnh (ví dụ: ảnh CCCD hoặc logo)
    @Column(name = "status_id")
    private Integer statusId; // Mã trạng thái
    @Column(name = "manager_id")
    private Integer managerId; // Mã quản lý
    @Column(name = "created_at")
    private LocalDateTime createdAt; // Ngày tạo
    @Column(name = "updated_at")
    private LocalDateTime updatedAt; // Ngày cập nhật

    // ===== Constructor =====
    public Branch() {
    }

    public Branch(Integer id, Integer companyId, String name, String branchCode, String address,
            String image, Integer statusId, Integer managerId,
            LocalDateTime createdAt, LocalDateTime updatedAt) {
        this.id = id;
        this.companyId = companyId;
        this.name = name;
        this.branchCode = branchCode;
        this.address = address;
        this.image = image;
        this.statusId = statusId;
        this.managerId = managerId;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }

    // ===== Getter & Setter =====
    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public Integer getCompanyId() {
        return companyId;
    }

    public void setCompanyId(Integer companyId) {
        this.companyId = companyId;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getBranchCode() {
        return branchCode;
    }

    public void setBranchCode(String branchCode) {
        this.branchCode = branchCode;
    }

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    public String getImage() {
        return image;
    }

    public void setImage(String image) {
        this.image = image;
    }

    public Integer getStatusId() {
        return statusId;
    }

    public void setStatusId(Integer statusId) {
        this.statusId = statusId;
    }

    public Integer getManagerId() {
        return managerId;
    }

    public void setManagerId(Integer managerId) {
        this.managerId = managerId;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(LocalDateTime updatedAt) {
        this.updatedAt = updatedAt;
    }

    @PrePersist
    protected void onCreate() {
        if (this.createdAt == null) {
            this.createdAt = LocalDateTime.now();
        }
        if (this.updatedAt == null) {
            this.updatedAt = LocalDateTime.now();
        }
    }

    @PreUpdate
    protected void onUpdate() {
        this.updatedAt = LocalDateTime.now();
    }

    @Override
    public String toString() {
        return "Branch{" +
                "id=" + id +
                ", companyId='" + companyId + '\'' +
                ", name='" + name + '\'' +
                ", branchCode='" + branchCode + '\'' +
                ", address='" + address + '\'' +
                ", image='" + image + '\'' +
                ", statusId=" + statusId +
                ", managerId=" + managerId +
                ", createdAt=" + createdAt +
                ", updatedAt=" + updatedAt +
                '}';
    }
}
