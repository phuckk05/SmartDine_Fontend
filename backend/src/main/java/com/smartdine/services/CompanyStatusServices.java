package com.smartdine.services;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.smartdine.models.status.CompanyStatus;
import com.smartdine.repository.CompanyStatusRepository;

@Service
public class CompanyStatusServices {

    @Autowired
    private CompanyStatusRepository companyStatusRepository;

    public List<CompanyStatus> getAll() {
        return companyStatusRepository.findAll();
    }

    public CompanyStatus getById(Integer id) {
        return companyStatusRepository.findById(id).orElse(null);
    }
}
