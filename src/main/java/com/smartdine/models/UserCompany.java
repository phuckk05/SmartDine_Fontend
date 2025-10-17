package com.smartdine.models;

import jakarta.persistence.*;
import java.time.LocalDateTime;

import com.fasterxml.jackson.annotation.JsonFormat;

@Entity
@Table(name = "user_companys")
@IdClass(UserCompany.class)
public class UserCompany {
    @Id
    private Integer userId;

    @Id
    private Integer companyId;

    @JsonFormat(shape = JsonFormat.Shape.STRING)
    private LocalDateTime assignedAt;

    public UserCompany() {
    }

    public UserCompany(Integer userId, Integer companyId, LocalDateTime assignedAt) {
        this.userId = userId;
        this.companyId = companyId;
        this.assignedAt = assignedAt;
    }

    public Integer getUserId() {
        return userId;
    }

    public void setUserId(Integer userId) {
        this.userId = userId;
    }

    public Integer getBranchId() {
        return companyId;
    }

    public void setBranchId(Integer companyId) {
        this.companyId = companyId;
    }

    public LocalDateTime getAssignedAt() {
        return assignedAt;
    }

    public void setAssignedAt(LocalDateTime assignedAt) {
        this.assignedAt = assignedAt;
    }

    @PrePersist
    protected void onCreate() {
        if (this.assignedAt == null) {
            this.assignedAt = LocalDateTime.now();
        }
    }
}
