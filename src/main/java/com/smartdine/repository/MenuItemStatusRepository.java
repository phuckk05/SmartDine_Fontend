package com.smartdine.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import com.smartdine.models.MenuItemStatus;

public interface MenuItemStatusRepository extends JpaRepository<MenuItemStatus, Integer> {
}
