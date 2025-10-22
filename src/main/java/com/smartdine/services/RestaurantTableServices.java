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

    public List<RestaurantTable> getAll() {
        return restaurantTableRepository.findAll();
    }

    public RestaurantTable getById(Integer id) {
        return restaurantTableRepository.findById(id).orElse(null);
    }

    public RestaurantTable create(RestaurantTable table) {
        return restaurantTableRepository.save(table);
    }

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

    public boolean delete(Integer id) {
        Optional<RestaurantTable> existingOptional = restaurantTableRepository.findById(id);
        if (existingOptional.isEmpty()) {
            return false;
        }

        restaurantTableRepository.deleteById(id);
        return true;
    }
}
