package com.smartdine.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

import com.smartdine.models.MenuItem;
import com.smartdine.models.idclass.MenuItemId;

public interface MenuItemRepository extends JpaRepository<MenuItem, MenuItemId> {
    boolean existsByCategoryIdAndItemId(Integer categoryId, Integer itemId);

    void deleteByCategoryIdAndItemId(Integer categoryId, Integer itemId);

    List<MenuItem> findByCategoryId(Integer categoryId);
}
