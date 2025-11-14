package com.smartdine.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import com.smartdine.models.User;
import java.util.List;

public interface UserRepository extends JpaRepository<User, Integer> {
    boolean existsByEmail(String email);

    User findByEmail(String email);

    boolean existsByPhone(String phone);

    // Find users by company and role (used when approving/rejecting a company)
    List<User> findByCompanyIdAndRole(Integer companyId, Integer role);

    // Convenience method to find all users for a company
    List<User> findByCompanyId(Integer companyId);

}
