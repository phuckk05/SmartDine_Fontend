package com.smartdine.services;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.smartdine.models.Role;
import com.smartdine.repository.RoleRepository;

@Service
public class RoleServices {
    @Autowired
    RoleRepository roleRepository;

    // Lấy tất cả role
    public List<Role> getAll() {
        return roleRepository.findAll();
    }

    // Lấy role theo id
    public Role getById(Integer id) {
        return roleRepository.findById(id).orElse(null);
    }

}
