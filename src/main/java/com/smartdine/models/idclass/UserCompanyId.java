package com.smartdine.models.idclass;

import java.io.Serializable;
import java.util.Objects;

public class UserCompanyId implements Serializable {
    private Integer userId;
    private Integer companyId;

    public UserCompanyId() {
    }

    public UserCompanyId(Integer userId, Integer companyId) {
        this.userId = userId;
        this.companyId = companyId;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o)
            return true;
        if (!(o instanceof UserCompanyId))
            return false;
        UserCompanyId that = (UserCompanyId) o;
        return Objects.equals(userId, that.userId) &&
                Objects.equals(companyId, that.companyId);
    }

    @Override
    public int hashCode() {
        return Objects.hash(userId, companyId);
    }
}
