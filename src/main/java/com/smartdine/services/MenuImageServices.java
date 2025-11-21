package com.smartdine.services;

import org.springframework.beans.factory.annotation.Autowired;
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
}