package com.smartdine.services;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.smartdine.models.TableStatus;
import com.smartdine.repository.TableStatusRepository;

@Service
public class TableStatusServices {
    @Autowired
    private TableStatusRepository tableStatusRepository;

    public List<TableStatus> getAll() {
        return tableStatusRepository.findAll();
    }

    public TableStatus getById(Integer id) {
        return tableStatusRepository.findById(id).orElse(null);
    }
}
