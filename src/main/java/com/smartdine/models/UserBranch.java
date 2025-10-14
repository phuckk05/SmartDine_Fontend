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

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer branch_id;

    @JsonFormat(shape = JsonFormat.Shape.STRING)
    private LocalDateTime assgned_at;

    public UserBranch() {
    }

    public UserBranch(Integer user_id, Integer branch_id, LocalDateTime assgneed_At) {
        this.user_id = user_id;
        this.branch_id = branch_id;
        this.assgned_at = assgneed_At;
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

    public LocalDateTime getAssgnedAt() {
        return assgned_at;
    }

    public void setAssgnedAt(LocalDateTime assgned_At) {
        this.assgned_at = assgned_At;
    }

    @PrePersist
    protected void onCreate() {
        if (this.assgned_at == null) {
            this.assgned_at = LocalDateTime.now();
        }
    }
}
