package com.smartdine.controllers;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.smartdine.models.MenuImage;
import com.smartdine.services.MenuImageServices;

import java.util.List;

@RestController
@RequestMapping("/api/menu-images")
public class MenuImageController {

    @Autowired
    private MenuImageServices menuImageServices;

    // API để frontend lấy ảnh về
    @GetMapping
    public ResponseEntity<List<MenuImage>> getImages(@RequestParam Integer itemId) {
        List<MenuImage> images = menuImageServices.getImagesByItemId(itemId);
        return ResponseEntity.ok(images);
    }

    // API để frontend xóa ảnh khi cập nhật món
    @DeleteMapping("/by-item/{itemId}")
    public ResponseEntity<Void> deleteImagesByItemId(@PathVariable Integer itemId) {
        menuImageServices.deleteImagesByItemId(itemId);
        return ResponseEntity.noContent().build();
    }
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