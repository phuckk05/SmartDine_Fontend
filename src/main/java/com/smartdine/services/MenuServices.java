package com.smartdine.services;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.smartdine.models.Menu;
import com.smartdine.repository.MenuRepository;

@Service
public class MenuServices {

    @Autowired
    private MenuRepository menuRepository;

    public List<Menu> getAll() {
        return menuRepository.findAll();
    }
    
    //Lay menu theo company id
    public List<Menu> getByCompanyId(Integer companyId) {
        return menuRepository.findByCompanyId(companyId);
    }
    public Menu getById(Integer id) {
        return menuRepository.findById(id).orElse(null);
    }

    public Menu create(Menu menu) {
        return menuRepository.save(menu);
    }

    public Menu update(Integer id, Menu updatedMenu) {
        Optional<Menu> existingOptional = menuRepository.findById(id);
        if (existingOptional.isEmpty()) {
            return null;
        }

        Menu existingMenu = existingOptional.get();
        existingMenu.setCompanyId(updatedMenu.getCompanyId());
        existingMenu.setName(updatedMenu.getName());
        existingMenu.setDescription(updatedMenu.getDescription());
        existingMenu.setStatusId(updatedMenu.getStatusId());
        existingMenu.setDeletedAt(updatedMenu.getDeletedAt());
        existingMenu.setUpdatedAt(LocalDateTime.now());

        return menuRepository.save(existingMenu);
    }

    public boolean delete(Integer id) {
        Optional<Menu> existingOptional = menuRepository.findById(id);
        if (existingOptional.isEmpty()) {
            return false;
        }

        menuRepository.deleteById(id);
        return true;
    }
}
