package com.smartdine.models;

import java.time.LocalDateTime;

import com.fasterxml.jackson.annotation.JsonFormat;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.PrePersist;
import jakarta.persistence.Table;

@Entity
@Table(name = "user_branches")
public class UserBranch {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer user_id;

    private Integer branch_id;

    @JsonFormat(shape = JsonFormat.Shape.STRING)
    private LocalDateTime assigned_at;

    public UserBranch() {
    }

    public UserBranch(Integer user_id, Integer branch_id, LocalDateTime assigned_At) {
        this.user_id = user_id;
        this.branch_id = branch_id;
        this.assigned_at = assigned_At;
    }

    public Integer getUserId() {
        return user_id;
    }

    public void setUserId(Integer user_id) {
        this.user_id = user_id;
    }

    public Integer getBranchId() {
        return branch_id;
    }

    public void setBranchId(Integer branch_id) {
        this.branch_id = branch_id;
    }

    public LocalDateTime getAssignedAt() {
        return assigned_at;
    }

    public void setAssgnedAt(LocalDateTime assigned_At) {
        this.assigned_at = assigned_At;
    }

    @PrePersist
    protected void onCreate() {
        if (this.assigned_at == null) {
            this.assigned_at = LocalDateTime.now();
        }
    }
}
