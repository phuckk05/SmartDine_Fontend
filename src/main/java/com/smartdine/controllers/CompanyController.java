package com.smartdine.controllers;

import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.smartdine.models.Company;
import com.smartdine.services.CompanyServices;

@RestController
@RequestMapping("/api/companys")
public class CompanyController {
    @Autowired
    CompanyServices companyServices;

    @GetMapping("/all")
    public ResponseEntity<?> getAllCompanys() {
        try {
            List<Company> companys = companyServices.getAll();
            return ResponseEntity.ok(companys);
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.internalServerError().body("Loi " + e.getMessage());
        }
    }

    @PostMapping
    public ResponseEntity<?> createCompany(@RequestBody Company company) {
        try {
            Company create = companyServices.save(company);
            return ResponseEntity.ok(create);
        } catch (Exception e) {
            return ResponseEntity.internalServerError().body(e.getMessage());
        }
    }

}
