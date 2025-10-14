package com.smartdine.models;

import java.io.Serializable;
import java.util.Objects;

public class UserBranchId implements Serializable {
    private Integer user_id;
    private Integer branch_id;

    public UserBranchId() {
    }

    public UserBranchId(Integer user_id, Integer branch_id) {
        this.user_id = user_id;
        this.branch_id = branch_id;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o)
            return true;
        if (!(o instanceof UserBranchId))
            return false;
        UserBranchId that = (UserBranchId) o;
        return Objects.equals(user_id, that.user_id) &&
                Objects.equals(branch_id, that.branch_id);
    }

    @Override
    public int hashCode() {
        return Objects.hash(user_id, branch_id);
    }
}
