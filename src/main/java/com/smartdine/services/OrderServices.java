package com.smartdine.services;

import java.time.LocalDateTime;
import java.time.ZoneId;
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

    // Lấy danh sách tableId đã có order chưa thanh toán ngay hôm nay
    // statusId = 2 là "SERVING" (đang phục vụ, chưa thanh toán)
    // Sử dụng múi giờ Việt Nam (Asia/Ho_Chi_Minh - GMT+7)
    public List<Integer> getUnpaidOrderTableIdsToday() {
        LocalDateTime now = LocalDateTime.now(ZoneId.of("Asia/Ho_Chi_Minh"));
        LocalDateTime startOfDay = now.withHour(0).withMinute(0).withSecond(0).withNano(0);
        LocalDateTime endOfDay = now.withHour(23).withMinute(59).withSecond(59).withNano(999999999);

        return orderRepository.findDistinctTableIdByStatusIdAndCreatedAtBetween(2, startOfDay, endOfDay);
    }

    // Lấy danh sách order theo tableId ngay hôm nay
    public List<Order> getOrdersByTableIdToday(Integer tableId) {
        LocalDateTime now = LocalDateTime.now(ZoneId.of("Asia/Ho_Chi_Minh"));
        LocalDateTime startOfDay = now.withHour(0).withMinute(0).withSecond(0).withNano(0);
        LocalDateTime endOfDay = now.withHour(23).withMinute(59).withSecond(59).withNano(999999999);

        return orderRepository.findByTableIdAndCreatedAtBetween(tableId, startOfDay, endOfDay);
    }

<<<<<<< HEAD
    // Lấy danh sách order theo branchId ngay hôm nay
    public List<Order> getOrdersByBranchIdToday(Integer branchId) {
        LocalDateTime now = LocalDateTime.now(ZoneId.of("Asia/Ho_Chi_Minh"));
        LocalDateTime startOfDay = now.withHour(0).withMinute(0).withSecond(0).withNano(0);
        LocalDateTime endOfDay = now.withHour(23).withMinute(59).withSecond(59).withNano(999999999);

        return orderRepository.findByBranchIdAndCreatedAtBetween(branchId, startOfDay, endOfDay);
    }
=======
    // Lấy danh sách orders theo branchId
    public List<Order> getOrdersByBranchId(Integer branchId) {
        return orderRepository.findByBranchId(branchId);
    }

>>>>>>> origin/branch-management-api-v1.2
}
