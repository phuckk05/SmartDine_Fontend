package com.smartdine.models;

import java.time.LocalDateTime;

import com.fasterxml.jackson.annotation.JsonFormat;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

import jakarta.persistence.*;

@Entity
@Table(name = "users")
@JsonIgnoreProperties(ignoreUnknown = true)
public class User {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(name = "full_name")
    private String fullName;

    private String email;

    private String phone;

    @Column(name = "passwork_hash")
    private String passworkHash;

    @Column(name = "font_image")
    private String fontImage;

    @Column(name = "back_image")
    private String backImage;

    @Column(name = "status_id")
    private Integer statusId;

    @Column(name = "role")
    private Integer role;

    @Column(name = "company_id")
    private Integer companyId;

    @JsonFormat(shape = JsonFormat.Shape.STRING)
    @Column(name = "created_at")
    private LocalDateTime createdAt;
    @JsonFormat(shape = JsonFormat.Shape.STRING)
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
    @JsonFormat(shape = JsonFormat.Shape.STRING)
    @Column(name = "deleted_at")
    private LocalDateTime deletedAt;

    // Constructor
    public User() {
    }

    public User(Integer id, String fullName, String email, String phone,
            String passworkHash, String fontImage, String backImage,
            Integer statusId, Integer role,
            Integer companyId,
            LocalDateTime createdAt, LocalDateTime updatedAt, LocalDateTime deletedAt) {
        this.id = id;
        this.fullName = fullName;
        this.email = email;
        this.phone = phone;
        this.passworkHash = passworkHash;
        this.fontImage = fontImage;
        this.backImage = backImage;
        this.statusId = statusId;
        this.role = role;

        this.companyId = companyId;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
        this.deletedAt = deletedAt;
    }

    public Integer getRole() {
        return role;
    }

    public void setRole(Integer role) {
        this.role = role;
    }

    // Getters & Setters
    public Integer getId() {
        return id;
    }

    public Integer getCompanyId() {
        return companyId;
    }

    public void setCompanyId(Integer companyId) {
        this.companyId = companyId;
    }

    public void setId(Integer id) {
        this.id = id;
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

    public String getPassworkHash() {
        return passworkHash;
    }

    public void setPassworkHash(String passworkHash) {
        this.passworkHash = passworkHash;
    }

    public String getFontImage() {
        return fontImage;
    }

    public void setFontImage(String fontImage) {
        this.fontImage = fontImage;
    }

    public String getBackImage() {
        return backImage;
    }

    public void setBackImage(String backImage) {
        this.backImage = backImage;
    }

    public Integer getStatusId() {
        return statusId;
    }

    public void setStatusId(Integer statusId) {
        this.statusId = statusId;
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

    public LocalDateTime getDeletedAt() {
        return deletedAt;
    }

    public void setDeletedAt(LocalDateTime deletedAt) {
        this.deletedAt = deletedAt;
    }

    @PrePersist
    protected void onCreate() {
        if (this.createdAt == null)
            this.createdAt = LocalDateTime.now();
        if (this.updatedAt == null)
            this.updatedAt = LocalDateTime.now();
    }

    @PreUpdate
    protected void onUpdate() {
        this.updatedAt = LocalDateTime.now();
    }
}