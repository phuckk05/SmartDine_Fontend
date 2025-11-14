package com.smartdine.services;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.smartdine.models.status.PromotionStatus;
import com.smartdine.repository.PromotionStatusRepository;

@Service
public class PromotionStatusServices {
    @Autowired
    private PromotionStatusRepository promotionStatusRepository;

    public List<PromotionStatus> getAll() {
        return promotionStatusRepository.findAll();
    }

    public PromotionStatus getById(Integer id) {
        return promotionStatusRepository.findById(id).orElse(null);
    }
}
