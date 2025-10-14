package com.smartdine.models;

import java.time.LocalDateTime;
import com.fasterxml.jackson.annotation.JsonFormat;
import jakarta.persistence.*;

@Entity
@Table(name = "user_branches")
@IdClass(UserBranchId.class)
public class UserBranch {

    @Id
    private Integer user_id;

    @Id
    private Integer branch_id;

    @JsonFormat(shape = JsonFormat.Shape.STRING)
    private LocalDateTime assigned_at;

    public UserBranch() {
    }

    public UserBranch(Integer user_id, Integer branch_id, LocalDateTime assigned_at) {
        this.user_id = user_id;
        this.branch_id = branch_id;
        this.assigned_at = assigned_at;
    }

    public Integer getUser_id() {
        return user_id;
    }

    public void setUser_id(Integer user_id) {
        this.user_id = user_id;
    }

    public Integer getBranch_id() {
        return branch_id;
    }

    public void setBranch_id(Integer branch_id) {
        this.branch_id = branch_id;
    }

    public LocalDateTime getAssigned_at() {
        return assigned_at;
    }

    public void setAssigned_at(LocalDateTime assigned_at) {
        this.assigned_at = assigned_at;
    }

    @PrePersist
    protected void onCreate() {
        if (this.assigned_at == null) {
            this.assigned_at = LocalDateTime.now();
        }
    }
}
