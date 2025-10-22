package com.smartdine.services;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.smartdine.models.MenuStatus;
import com.smartdine.repository.MenuStatusRepository;

@Service
public class MenuStatusServices {
    @Autowired
    private MenuStatusRepository menuStatusRepository;

    public List<MenuStatus> getAll() {
        return menuStatusRepository.findAll();
    }

    public MenuStatus getById(Integer id) {
        return menuStatusRepository.findById(id).orElse(null);
    }
}
