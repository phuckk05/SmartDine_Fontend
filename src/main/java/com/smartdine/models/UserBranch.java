package com.smartdine.models;

import java.time.LocalDateTime;
import com.fasterxml.jackson.annotation.JsonFormat;
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

    public Integer getUser_id() {
        return userId;
    }

    public void setUser_id(Integer userId) {
        this.userId = userId;
    }

    public Integer getBranch_id() {
        return branchId;
    }

    public void setBranch_id(Integer branchId) {
        this.branchId = branchId;
    }

    public LocalDateTime getAssigned_at() {
        return assignedAt;
    }

    public void setAssigned_at(LocalDateTime assignedAt) {
        this.assignedAt = assignedAt;
    }

    @PrePersist
    protected void onCreate() {
        if (this.assignedAt == null) {
            this.assignedAt = LocalDateTime.now();
        }
    }
}
