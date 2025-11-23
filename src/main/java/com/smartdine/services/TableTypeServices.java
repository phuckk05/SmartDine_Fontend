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

    public List<TableType> getByBranchId(Integer branchId) {
        return tableTypeRepository.findByBranchId(branchId);
    }

    public TableType getById(Integer id) {
        return tableTypeRepository.findById(id).orElse(null);
    }

    public TableType create(TableType tableType) {
        return tableTypeRepository.save(tableType);
    }

    public TableType update(Integer id, TableType updatedTableType) {
        Optional<TableType> existingOptional = tableTypeRepository.findById(id);
        if (existingOptional.isEmpty()) {
            return null;
        }

        TableType existing = existingOptional.get();
        existing.setName(updatedTableType.getName());
        existing.setCode(updatedTableType.getCode());

        return tableTypeRepository.save(existing);
    }

    public boolean delete(Integer id) {
        Optional<TableType> existingOptional = tableTypeRepository.findById(id);
        if (existingOptional.isEmpty()) {
            return false;
        }

        tableTypeRepository.deleteById(id);
        return true;
    }
}
