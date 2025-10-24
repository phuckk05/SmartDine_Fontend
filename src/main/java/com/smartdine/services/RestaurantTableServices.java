package com.smartdine.services;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

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

    // Lấy bàn theo id
    public RestaurantTable getById(Integer id) {
        return restaurantTableRepository.findById(id).orElse(null);
    }

    // Tạo mới bàn
    public RestaurantTable create(RestaurantTable table) {
        return restaurantTableRepository.save(table);
    }

    // Cập nhật bàn
    public RestaurantTable update(Integer id, RestaurantTable updatedTable) {
        Optional<RestaurantTable> existingOptional = restaurantTableRepository.findById(id);
        if (existingOptional.isEmpty()) {
            return null;
        }

        RestaurantTable existingTable = existingOptional.get();
        existingTable.setBranchId(updatedTable.getBranchId());
        existingTable.setName(updatedTable.getName());
        existingTable.setTypeId(updatedTable.getTypeId());
        existingTable.setDescription(updatedTable.getDescription());
        existingTable.setStatusId(updatedTable.getStatusId());
        existingTable.setUpdatedAt(LocalDateTime.now());

        return restaurantTableRepository.save(existingTable);
    }

    // Xóa bàn
    public boolean delete(Integer id) {
        Optional<RestaurantTable> existingOptional = restaurantTableRepository.findById(id);
        if (existingOptional.isEmpty()) {
            return false;
        }

        restaurantTableRepository.deleteById(id);
        return true;
    }

    // Lấy bàn theo branchId
    public List<RestaurantTable> getByBranchId(Integer branchId) {
        return restaurantTableRepository.findByBranchId(branchId);
    }
}
