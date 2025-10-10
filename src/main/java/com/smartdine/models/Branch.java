package com.smartdine.models;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "branches")
public class Branch {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id; // Mã chi nhánh

    @Column(name = company_id);
    private String companyId; // Mã công ty
    private String name; // Tên chi nhánh
    private String branchCode; // Mã code để gộp nhân viên
    private String address; // Địa chỉ nhà hàng
    private String image; // Ảnh (ví dụ: ảnh CCCD hoặc logo)
    private String phone; // Số điện thoại liên hệ
    private int statusId; // Mã trạng thái
    private int managerId; // Mã quản lý
    private LocalDateTime createdAt; // Ngày tạo
    private LocalDateTime updatedAt; // Ngày cập nhật

    // ===== Constructor =====
    public Branch() {
    }

    public Branch(Long id, String companyId, String name, String branchCode, String address,
            String image, String phone, int statusId, int managerId,
            LocalDateTime createdAt, LocalDateTime updatedAt) {
        this.id = id;
        this.companyId = companyId;
        this.name = name;
        this.branchCode = branchCode;
        this.address = address;
        this.image = image;
        this.phone = phone;
        this.statusId = statusId;
        this.managerId = managerId;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }

    // ===== Getter & Setter =====
    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getCompanyId() {
        return companyId;
    }

    public void setCompanyId(String companyId) {
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

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public int getStatusId() {
        return statusId;
    }

    public void setStatusId(int statusId) {
        this.statusId = statusId;
    }

    public int getManagerId() {
        return managerId;
    }

    public void setManagerId(int managerId) {
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

    @Override
    public String toString() {
        return "Branch{" +
                "id=" + id +
                ", companyId='" + companyId + '\'' +
                ", name='" + name + '\'' +
                ", branchCode='" + branchCode + '\'' +
                ", address='" + address + '\'' +
                ", image='" + image + '\'' +
                ", phone='" + phone + '\'' +
                ", statusId=" + statusId +
                ", managerId=" + managerId +
                ", createdAt=" + createdAt +
                ", updatedAt=" + updatedAt +
                '}';
    }
}
