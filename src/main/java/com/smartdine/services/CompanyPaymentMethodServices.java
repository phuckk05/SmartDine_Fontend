package com.smartdine.services;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.smartdine.models.CompanyPaymentMethod;
import com.smartdine.repository.CompanyPaymentMethodRepository;

@Service
public class CompanyPaymentMethodServices {
    @Autowired
    private CompanyPaymentMethodRepository companyPaymentMethodRepository;

    public List<CompanyPaymentMethod> getAll() {
        return companyPaymentMethodRepository.findAll();
    }
}
