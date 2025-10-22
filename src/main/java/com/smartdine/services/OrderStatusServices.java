package com.smartdine.services;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.smartdine.models.status.OrderStatus;
import com.smartdine.repository.OrderStatusRepository;

@Service
public class OrderStatusServices {
    @Autowired
    private OrderStatusRepository orderStatusRepository;

    public List<OrderStatus> getAll() {
        return orderStatusRepository.findAll();
    }

    public OrderStatus getById(Integer id) {
        return orderStatusRepository.findById(id).orElse(null);
    }
}
