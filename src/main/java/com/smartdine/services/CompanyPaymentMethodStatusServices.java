package com.smartdine.services;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.smartdine.models.CompanyPaymentMethodStatus;
import com.smartdine.repository.CompanyPaymentMethodStatusRepository;

@Service
public class CompanyPaymentMethodStatusServices {
    @Autowired
    private CompanyPaymentMethodStatusRepository statusRepository;

    public List<CompanyPaymentMethodStatus> getAll() {
        return statusRepository.findAll();
    }

    public CompanyPaymentMethodStatus getById(Integer id) {
        return statusRepository.findById(id).orElse(null);
    }
}
