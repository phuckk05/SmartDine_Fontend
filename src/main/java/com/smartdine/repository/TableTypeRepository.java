package com.smartdine.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

import com.smartdine.models.TableType;

public interface TableTypeRepository extends JpaRepository<TableType, Integer> {
	List<TableType> findByBranchId(Integer branchId);
}
