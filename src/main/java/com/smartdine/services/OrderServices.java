package com.smartdine.services;

import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

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

    // Lấy danh sách orders theo branchId
    public List<Order> getOrdersByBranchId(Integer branchId) {
        return orderRepository.findByBranchId(branchId);
    }

    // Lấy xu hướng doanh thu theo branch trong 7 ngày gần đây
    public List<Map<String, Object>> getRevenueTrendsByBranch(Integer branchId) {
        LocalDateTime now = LocalDateTime.now(ZoneId.of("Asia/Ho_Chi_Minh"));
        LocalDateTime sevenDaysAgo = now.minusDays(7).withHour(0).withMinute(0).withSecond(0).withNano(0);
        
        List<Order> orders = orderRepository.findByBranchIdAndCreatedAtBetween(branchId, sevenDaysAgo, now);
        
        // Nhóm theo ngày và tính tổng doanh thu (giả định mỗi order = 500,000 VND)
        Map<String, Double> dailyRevenue = orders.stream()
            .filter(order -> order.getStatusId() == 3) // Chỉ tính orders đã hoàn thành
            .collect(Collectors.groupingBy(
                order -> order.getCreatedAt().toLocalDate().toString(),
                Collectors.summingDouble(order -> 500000.0) // Giá trị giả định cho mỗi order
            ));
        
        return dailyRevenue.entrySet().stream()
            .map(entry -> {
                Map<String, Object> dayData = new HashMap<>();
                dayData.put("date", entry.getKey());
                dayData.put("revenue", entry.getValue());
                return dayData;
            })
            .collect(Collectors.toList());
    }

    // Lấy doanh thu theo giờ hôm nay
    public List<Map<String, Object>> getHourlyRevenueByBranch(Integer branchId) {
        LocalDateTime now = LocalDateTime.now(ZoneId.of("Asia/Ho_Chi_Minh"));
        LocalDateTime startOfDay = now.withHour(0).withMinute(0).withSecond(0).withNano(0);
        LocalDateTime endOfDay = now.withHour(23).withMinute(59).withSecond(59).withNano(999999999);
        
        List<Order> todayOrders = orderRepository.findByBranchIdAndCreatedAtBetween(branchId, startOfDay, endOfDay);
        
        // Nhóm theo giờ và tính tổng doanh thu (giả định mỗi order = 500,000 VND)
        Map<Integer, Double> hourlyRevenue = todayOrders.stream()
            .filter(order -> order.getStatusId() == 3) // Chỉ tính orders đã hoàn thành
            .collect(Collectors.groupingBy(
                order -> order.getCreatedAt().getHour(),
                Collectors.summingDouble(order -> 500000.0) // Giá trị giả định cho mỗi order
            ));
        
        return hourlyRevenue.entrySet().stream()
            .map(entry -> {
                Map<String, Object> hourData = new HashMap<>();
                hourData.put("hour", entry.getKey());
                hourData.put("revenue", entry.getValue());
                hourData.put("timeRange", String.format("%02d:00 - %02d:59", entry.getKey(), entry.getKey()));
                return hourData;
            })
            .collect(Collectors.toList());
    }

}
