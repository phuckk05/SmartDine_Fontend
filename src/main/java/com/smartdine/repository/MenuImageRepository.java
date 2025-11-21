package com.smartdine.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.smartdine.models.MenuImage;

@Repository
public interface MenuImageRepository extends JpaRepository<MenuImage, Integer> {
    List<MenuImage> findByItemId(Integer itemId);
}