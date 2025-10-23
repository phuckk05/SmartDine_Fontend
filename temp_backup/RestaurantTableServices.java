package com.smartdine.services;

import java.time.LocalDateTime;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.smartdine.models.RestaurantTable;
import com.smartdine.repository.RestaurantTableRepository;

@Service
public class RestaurantTableServices {

    @Autowired
    private RestaurantTableRepository restaurantTableRepository;

    // Lấy tất cả bàn
    public List<RestaurantTable> getAll() {
        return restaurantTableRepository.findAll();
    }

    // Lấy bàn theo ID
    public RestaurantTable findById(Integer id) {
        return restaurantTableRepository.findById(id).orElse(null);
    }

    // Lấy bàn theo branch
    public List<RestaurantTable> getTablesByBranch(Integer branchId) {
        return restaurantTableRepository.findByBranchId(branchId);
    }

    // Lấy bàn theo trạng thái
    public List<RestaurantTable> getTablesByStatus(Integer statusId) {
        return restaurantTableRepository.findByStatusId(statusId);
    }

    // Lấy bàn theo loại
    public List<RestaurantTable> getTablesByType(Integer typeId) {
        return restaurantTableRepository.findByTypeId(typeId);
    }

    // Tạo bàn mới
    public RestaurantTable create(RestaurantTable table) {
        table.setCreatedAt(LocalDateTime.now());
        table.setUpdatedAt(LocalDateTime.now());
        return restaurantTableRepository.save(table);
    }

    // Cập nhật bàn
    public RestaurantTable update(Integer id, RestaurantTable table) {
        RestaurantTable existingTable = findById(id);
        if (existingTable == null) {
            return null;
        }
        
        table.setId(id);
        table.setCreatedAt(existingTable.getCreatedAt());
        table.setUpdatedAt(LocalDateTime.now());
        return restaurantTableRepository.save(table);
    }

    // Xóa bàn
    public boolean delete(Integer id) {
        RestaurantTable table = findById(id);
        if (table == null) {
            return false;
        }
        restaurantTableRepository.deleteById(id);
        return true;
    }
}