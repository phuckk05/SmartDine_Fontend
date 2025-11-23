package com.smartdine.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

import com.smartdine.models.TableType;

public interface TableTypeRepository extends JpaRepository<TableType, Integer> {

    // Lấy table types theo branch
    List<TableType> findByBranchId(Integer branchId);

    // Kiểm tra xem table type code đã tồn tại trong branch chưa
    boolean existsByBranchIdAndCode(Integer branchId, String code);

    // Kiểm tra xem table type name đã tồn tại trong branch chưa
    boolean existsByBranchIdAndName(Integer branchId, String name);

    // Tìm table type theo branch và code
    TableType findByBranchIdAndCode(Integer branchId, String code);

    // Tìm table type theo branch và name
    TableType findByBranchIdAndName(Integer branchId, String name);
}
