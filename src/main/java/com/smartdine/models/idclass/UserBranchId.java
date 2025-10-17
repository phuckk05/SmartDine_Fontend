package com.smartdine.models.idclass;

import java.io.Serializable;
import java.util.Objects;

public class UserBranchId implements Serializable {
    private Integer userId;
    private Integer branchId;

    public UserBranchId() {
    }

    public UserBranchId(Integer userId, Integer branchId) {
        this.userId = userId;
        this.branchId = branchId;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o)
            return true;
        if (!(o instanceof UserBranchId))
            return false;
        UserBranchId that = (UserBranchId) o;
        return Objects.equals(userId, that.userId) &&
                Objects.equals(branchId, that.branchId);
    }

    @Override
    public int hashCode() {
        return Objects.hash(userId, branchId);
    }
}
