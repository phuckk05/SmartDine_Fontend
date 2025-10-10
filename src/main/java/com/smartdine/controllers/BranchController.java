package com.smartdine.controllers;

import com.smartdine.models.Branch;
import com.smartdine.services.*;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/branchs")
public class BranchController {

    @Autowired
    private BranchServices branchServices;

    @GetMapping("/{branchCode}")
    public ResponseEntity<Branch> getBranchByCode(@PathVariable String branchCode) {
        Branch branch = branchServices.findBranch(branchCode);
        if (branch == null) {
            // Trả về 404
            return ResponseEntity.notFound().build();
        }
        return ResponseEntity.ok(branch);
    }
}
