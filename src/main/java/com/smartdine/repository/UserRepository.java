package com.smartdine.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import com.smartdine.models.User;

public interface UserRepository extends JpaRepository<User, Integer> {
    boolean existsByEmail(String email);

    User findByEmail(String email);

    boolean existsByPhone(String phone);
}
