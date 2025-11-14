package com.smartdine.services;

import java.time.LocalDateTime;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.smartdine.models.Category;
import com.smartdine.repository.CategoryRepository;

@Service
public class CategoryServices {
    @Autowired
    private CategoryRepository categoryRepository;

    public List<Category> getAll(Integer companyId, Integer statusId) {
        if (companyId != null && statusId != null) {
            return categoryRepository.findByCompanyIdAndStatusId(companyId, statusId);
        }
        if (companyId != null) {
            return categoryRepository.findByCompanyId(companyId);
        }
        return categoryRepository.findAll();
    }

    public Category create(Category category) {
        LocalDateTime now = LocalDateTime.now();
        if (category.getCreatedAt() == null) {
            category.setCreatedAt(now);
        }
        category.setUpdatedAt(now);
        return categoryRepository.save(category);
    }

    public Category update(Integer id, Category payload) {
        return categoryRepository.findById(id).map(existing -> {
            if (payload.getName() != null) {
                existing.setName(payload.getName());
            }
            if (payload.getCompanyId() != null) {
                existing.setCompanyId(payload.getCompanyId());
            }
            if (payload.getStatusId() != null) {
                existing.setStatusId(payload.getStatusId());
            }
            existing.setUpdatedAt(LocalDateTime.now());
            return categoryRepository.save(existing);
        }).orElse(null);
    }

    public boolean delete(Integer id) {
        if (!categoryRepository.existsById(id)) {
            return false;
        }
        categoryRepository.deleteById(id);
        return true;
    }
}
