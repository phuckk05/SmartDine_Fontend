package com.smartdine.services;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.smartdine.models.OrderItemStatus;
import com.smartdine.repository.OrderItemStatusRepository;

@Service
public class OrderItemStatusServices {
    @Autowired
    private OrderItemStatusRepository orderItemStatusRepository;

    public List<OrderItemStatus> getAll() {
        return orderItemStatusRepository.findAll();
    }

    public OrderItemStatus getById(Integer id) {
        return orderItemStatusRepository.findById(id).orElse(null);
    }
}
