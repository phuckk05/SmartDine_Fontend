package com.smartdine.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import com.smartdine.models.status.TableStatus;

public interface TableStatusRepository extends JpaRepository<TableStatus, Integer> {
}
