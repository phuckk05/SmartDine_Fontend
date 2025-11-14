package com.smartdine.services;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.smartdine.models.TableType;
import com.smartdine.repository.TableTypeRepository;

@Service
public class TableTypeServices {
    @Autowired
    private TableTypeRepository tableTypeRepository;

    public List<TableType> getAll() {
        return tableTypeRepository.findAll();
    }
}
