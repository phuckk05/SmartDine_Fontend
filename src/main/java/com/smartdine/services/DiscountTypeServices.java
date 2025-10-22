package com.smartdine.services;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.smartdine.models.DiscountType;
import com.smartdine.repository.DiscountTypeRepository;

@Service
public class DiscountTypeServices {
    @Autowired
    private DiscountTypeRepository discountTypeRepository;

    public List<DiscountType> getAll() {
        return discountTypeRepository.findAll();
    }
}
