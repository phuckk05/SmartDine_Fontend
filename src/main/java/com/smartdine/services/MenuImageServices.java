package com.smartdine.services;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.stereotype.Service;

import com.smartdine.models.MenuImage;
import com.smartdine.repository.MenuImageRepository;

@Service
public class MenuImageServices {

    @Autowired
    private MenuImageRepository menuImageRepository;

    /**
     * Lưu một đối tượng MenuImage vào cơ sở dữ liệu.
     * @param menuImage Đối tượng chứa itemId và URL ảnh.
     * @return Đối tượng MenuImage đã được lưu.
     */
    public MenuImage createMenuImage(MenuImage menuImage) {
        return menuImageRepository.save(menuImage);
    }

    /**
     * Lấy danh sách các ảnh theo itemId.
     * @param itemId ID của item.
     * @return Danh sách các đối tượng MenuImage.
     */
    public List<MenuImage> getImagesByItemId(Integer itemId) {
        return menuImageRepository.findByItemId(itemId);
    }

    /**
     * Xóa tất cả các ảnh liên quan đến một itemId.
     * @param itemId ID của item.
     */
    public void deleteImagesByItemId(Integer itemId) {
        menuImageRepository.deleteByItemId(itemId);
    }
}