package com.smartdine.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import com.smartdine.models.Role;

public interface RoleRepository extends JpaRepository<Role, Integer> {

}
