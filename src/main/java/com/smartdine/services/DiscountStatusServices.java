package com.smartdine.services;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.smartdine.models.status.DiscountStatus;
import com.smartdine.repository.DiscountStatusRepository;

@Service
public class DiscountStatusServices {
    @Autowired
    private DiscountStatusRepository discountStatusRepository;

    public List<DiscountStatus> getAll() {
        return discountStatusRepository.findAll();
    }

    public DiscountStatus getById(Integer id) {
        return discountStatusRepository.findById(id).orElse(null);
    }
}
