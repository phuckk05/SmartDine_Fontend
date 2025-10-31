package com.smartdine.services;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.smartdine.models.status.OrderItemStatus;
import com.smartdine.repository.OrderItemStatusRepository;

@Service
public class OrderItemStatusServices {
    @Autowired
    private OrderItemStatusRepository orderItemStatusRepository;

    // Get all OrderItemStatus
    public List<OrderItemStatus> getAll() {
        return orderItemStatusRepository.findAll();
    }
    // Get OrderItemStatus by ID
    public OrderItemStatus getById(Integer id) {
        return orderItemStatusRepository.findById(id).orElse(null);
    }
}
    