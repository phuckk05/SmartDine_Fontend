package com.smartdine.services;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.smartdine.models.OrderItemAction;
import com.smartdine.repository.OrderItemActionRepository;

@Service
public class OrderItemActionServices {
    @Autowired
    private OrderItemActionRepository orderItemActionRepository;

    public List<OrderItemAction> getAll() {
        return orderItemActionRepository.findAll();
    }

    public OrderItemAction getById(Integer id) {
        return orderItemActionRepository.findById(id).orElse(null);
    }
}
