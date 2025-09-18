package com.smartdine.backend.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import com.smartdine.backend.model.User;

public interface UserRepository extends JpaRepository<User, Long> {
}
