package com.smartdine.models;

import java.time.LocalDateTime;
import com.fasterxml.jackson.annotation.JsonFormat;
import com.smartdine.models.idclass.UserBranchId;

import jakarta.persistence.*;

@Entity
@Table(name = "user_branches")
@IdClass(UserBranchId.class)
public class UserBranch {

    @Id
    private Integer userId;

    @Id
    private Integer branchId;

    @JsonFormat(shape = JsonFormat.Shape.STRING)
    private LocalDateTime assignedAt;

    public UserBranch() {
    }

    public UserBranch(Integer userId, Integer branchId, LocalDateTime assignedAt) {
        this.userId = userId;
        this.branchId = branchId;
        this.assignedAt = assignedAt;
    }

    public Integer getUserId() {
        return userId;
    }

    public void setUserId(Integer userId) {
        this.userId = userId;
    }

    public Integer getBranchId() {
        return branchId;
    }

    public void setBranchId(Integer branchId) {
        this.branchId = branchId;
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
