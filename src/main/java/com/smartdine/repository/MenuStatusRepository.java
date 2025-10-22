package com.smartdine.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import com.smartdine.models.MenuStatus;

public interface MenuStatusRepository extends JpaRepository<MenuStatus, Integer> {
}
