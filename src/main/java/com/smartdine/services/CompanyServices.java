package com.smartdine.services;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.smartdine.models.Company;
import com.smartdine.repository.CompanyRepository;

@Service
public class CompanyServices {
    @Autowired
    CompanyRepository companyRepository;

    public List<Company> getAll() {
        return companyRepository.findAll();
    }
}
