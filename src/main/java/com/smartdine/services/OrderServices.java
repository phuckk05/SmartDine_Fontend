package com.smartdine.services;

import java.time.LocalDateTime;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.smartdine.models.Order;
import com.smartdine.repository.OrderRepository;

@Service
public class OrderServices {

    @Autowired
    OrderRepository orderRepository;

    // Lấy tất cả order
    public java.util.List<Order> getAll() {
        return orderRepository.findAll();
    }

    // Lấy order theo id
    public Order getById(Integer id) {
        return orderRepository.findById(id).orElse(null);
    }

    // Lấy danh sách tableId đã có order chưa thanh toán ngay hôm nayzx
    public List<Integer> getUnpaidOrderTableIdsToday() {
        return orderRepository.findDistinctTableIdByStatusIdNotAndCreatedAtBetween(2,
                LocalDateTime.now().withHour(0).withMinute(0).withSecond(0),
                LocalDateTime.now().withHour(23).withMinute(59).withSecond(59));
    }

    // Lấy danh sách order theo tableId ngay hôm nay
    public List<Order> getOrdersByTableIdToday(Integer tableId) {
        return orderRepository.findByTableIdAndCreatedAtBetween(tableId,
                LocalDateTime.now().withHour(0).withMinute(0).withSecond(0),
                LocalDateTime.now().withHour(23).withMinute(59).withSecond(59));
    }

}
