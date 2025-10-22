package com.smartdine.services;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.smartdine.models.MenuItemStatus;
import com.smartdine.repository.MenuItemStatusRepository;

@Service
public class MenuItemStatusServices {
    @Autowired
    private MenuItemStatusRepository menuItemStatusRepository;

    public List<MenuItemStatus> getAll() {
        return menuItemStatusRepository.findAll();
    }

    public MenuItemStatus getById(Integer id) {
        return menuItemStatusRepository.findById(id).orElse(null);
    }
}
