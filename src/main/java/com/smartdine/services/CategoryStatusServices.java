package com.smartdine.services;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.smartdine.models.CategoryStatus;
import com.smartdine.repository.CategoryStatusRepository;

@Service
public class CategoryStatusServices {
    @Autowired
    private CategoryStatusRepository categoryStatusRepository;

    public List<CategoryStatus> getAll() {
        return categoryStatusRepository.findAll();
    }

    public CategoryStatus getById(Integer id) {
        return categoryStatusRepository.findById(id).orElse(null);
    }
}
