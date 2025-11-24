package com.smartdine.services;

import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.smartdine.models.TableType;
import com.smartdine.repository.TableTypeRepository;

@Service
public class TableTypeServices {
    @Autowired
    private TableTypeRepository tableTypeRepository;

    // Method getAll() không còn cần thiết vì tất cả đều branch-specific
    // public List<TableType> getAll() {
    //     return tableTypeRepository.findAll();
    // }

    // Lấy table types theo branch
    public List<TableType> getByBranchId(Integer branchId) {
        return tableTypeRepository.findByBranchId(branchId);
    }

    // Tạo table type mới cho branch
    public TableType createTableType(TableType tableType) {
        // Kiểm tra trùng lặp code trong branch
        if (tableTypeRepository.existsByBranchIdAndCode(tableType.getBranchId(), tableType.getCode())) {
            throw new RuntimeException("Mã loại bàn đã tồn tại trong chi nhánh này");
        }

        // Kiểm tra trùng lặp name trong branch
        if (tableTypeRepository.existsByBranchIdAndName(tableType.getBranchId(), tableType.getName())) {
            throw new RuntimeException("Tên loại bàn đã tồn tại trong chi nhánh này");
        }

        return tableTypeRepository.save(tableType);
    }

    // Cập nhật table type
    public TableType updateTableType(Integer id, TableType tableType) {
        Optional<TableType> existingType = tableTypeRepository.findById(id);
        if (!existingType.isPresent()) {
            throw new RuntimeException("Không tìm thấy loại bàn");
        }

        TableType existing = existingType.get();

        // Kiểm tra trùng lặp code (trừ chính nó)
        if (!existing.getCode().equals(tableType.getCode()) &&
            tableTypeRepository.existsByBranchIdAndCode(existing.getBranchId(), tableType.getCode())) {
            throw new RuntimeException("Mã loại bàn đã tồn tại trong chi nhánh này");
        }

        // Kiểm tra trùng lặp name (trừ chính nó)
        if (!existing.getName().equals(tableType.getName()) &&
            tableTypeRepository.existsByBranchIdAndName(existing.getBranchId(), tableType.getName())) {
            throw new RuntimeException("Tên loại bàn đã tồn tại trong chi nhánh này");
        }

        existing.setCode(tableType.getCode());
        existing.setName(tableType.getName());

        return tableTypeRepository.save(existing);
    }

    // Xóa table type
    public void deleteTableType(Integer id) {
        if (!tableTypeRepository.existsById(id)) {
            throw new RuntimeException("Không tìm thấy loại bàn");
        }
        tableTypeRepository.deleteById(id);
    }

    // Lấy table type theo ID
    public Optional<TableType> getById(Integer id) {
        return tableTypeRepository.findById(id);
    }
}
