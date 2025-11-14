package com.smartdine.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

import com.smartdine.models.User;

public interface UserRepository extends JpaRepository<User, Integer> {
    boolean existsByEmail(String email);

    User findByEmail(String email);

    boolean existsByPhone(String phone);

    // Find users by company and role (used when approving/rejecting a company)
    List<User> findByCompanyIdAndRole(Integer companyId, Integer role);

    // Convenience method to find all users for a company
    List<User> findByCompanyId(Integer companyId);

    // Methods for user approval system
    List<User> findByCompanyIdAndStatusIdOrderByCreatedAtDesc(Integer companyId, Integer statusId);
    
    List<User> findByStatusIdOrderByCreatedAtDesc(Integer statusId);
    
    int countByCompanyIdAndStatusId(Integer companyId, Integer statusId);
    
    int countByCompanyId(Integer companyId);

}
