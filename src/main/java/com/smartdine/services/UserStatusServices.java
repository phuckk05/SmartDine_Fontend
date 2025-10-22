package com.smartdine.services;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.smartdine.models.UserStatus;
import com.smartdine.repository.UserStatusRepository;

@Service
public class UserStatusServices {
    @Autowired
    private UserStatusRepository userStatusRepository;

    public List<UserStatus> getAll() {
        return userStatusRepository.findAll();
    }

    public UserStatus getById(Integer id) {
        return userStatusRepository.findById(id).orElse(null);
    }
}
