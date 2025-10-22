package com.smartdine.controllers;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.smartdine.models.Order;
import com.smartdine.services.OrderServices;

@RestController
@RequestMapping("/api/orders")
public class OrderController {

    @Autowired
    OrderServices orderServices;

    // Lấy tất cả order
    @GetMapping("/all")
    public List<Order> getAll() {
        return orderServices.getAll();
    }

    // Lấy order theo id
    @GetMapping("/{id}")
    public Order getById(@PathVariable Integer id) {
        return orderServices.getById(id);
    }

    // Lấy danh sách tableId đã có order chưa thanh toán ngay hôm nay
    @GetMapping("/unpaid-tables/today")
    public List<Integer> getUnpaidOrderTableIdsToday() {
        return orderServices.getUnpaidOrderTableIdsToday();
    }

    // Lấy danh sách order theo tableId ngay hôm nay
    @GetMapping("/table-order/{tableId}/today")
    public List<Order> getOrdersByTableIdToday(@PathVariable Integer tableId) {
        return orderServices.getOrdersByTableIdToday(tableId);
    }

}
