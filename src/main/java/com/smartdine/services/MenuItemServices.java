package com.smartdine.services;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.smartdine.models.MenuItem;
import com.smartdine.models.idclass.MenuItemId;
import com.smartdine.repository.MenuItemRepository;

@Service
public class MenuItemServices {

    @Autowired
    private MenuItemRepository menuItemRepository;

    public MenuItem assignMenuItem(MenuItem menuItem) {
        if (menuItemRepository.existsByCategoryIdAndItemId(menuItem.getCategoryId(), menuItem.getItemId())) {
            throw new IllegalArgumentException("Item đã được gán vào nhóm này");
        }
        // Ensure timestamps maintained via entity if needed (not present now)
        return menuItemRepository.save(menuItem);
    }

    // Lấy menu-item theo theo id
    public List<MenuItem> getMenuById(Integer id) {
        return menuItemRepository.findByMenuId(id);
    }

    public boolean removeMenuItem(Integer categoryId, Integer itemId) {
        if (!menuItemRepository.existsByCategoryIdAndItemId(categoryId, itemId)) {
            return false;
        }
        menuItemRepository.deleteByCategoryIdAndItemId(categoryId, itemId);
        return true;
    }

    public List<MenuItem> getByCategory(Integer categoryId) {
        return menuItemRepository.findByCategoryId(categoryId);
    }

    public MenuItem getById(Integer menuId, Integer itemId) {
        return menuItemRepository.findById(new MenuItemId(menuId, itemId)).orElse(null);
    }
}
