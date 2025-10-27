package com.smartdine.controllers;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.smartdine.models.Item;
import com.smartdine.services.ItemServices;

@RestController
@RequestMapping("/api/items")
public class ItemController {
    @Autowired
    private ItemServices itemServices;

    //lay item by comapnyId
    @GetMapping("/company/{companyId}")
    public ResponseEntity<?> getByCompanyId(@PathVariable Integer companyId){
        try {
            List<Item> getItems = itemServices.getByCompanyId(companyId);
            return ResponseEntity.ok(getItems);
        }catch(Exception e){
            e.printStackTrace();
            return ResponseEntity.internalServerError().body(e.getMessage());
        }
        
    }
}
