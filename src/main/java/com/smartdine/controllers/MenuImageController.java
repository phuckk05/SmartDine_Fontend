package com.smartdine.controllers;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.smartdine.models.MenuImage;
import com.smartdine.services.MenuImageServices;

@RestController
@RequestMapping("/api/menu-images")
public class MenuImageController {

    @Autowired
    private MenuImageServices menuImageServices;

    @PostMapping
    public ResponseEntity<?> createMenuImage(@RequestBody MenuImage menuImage) {
        try {
            MenuImage createdImage = menuImageServices.createMenuImage(menuImage);
            return new ResponseEntity<>(createdImage, HttpStatus.CREATED);
        } catch (Exception e) {
            return ResponseEntity.internalServerError().body("Lỗi khi lưu ảnh món ăn: " + e.getMessage());
        }
    }
}