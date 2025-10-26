package com.smartdine.controllers;

import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
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
    @GetMapping
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

    // Lấy danh sách orders theo branchId
    @GetMapping("/branch/{branchId}")
    public List<Order> getOrdersByBranchId(@PathVariable Integer branchId) {
        return orderServices.getOrdersByBranchId(branchId);
    }

    // Thống kê đơn hàng theo chi nhánh
    @GetMapping("/statistics/branch/{branchId}")
    public ResponseEntity<?> getOrderStatisticsByBranch(@PathVariable Integer branchId) {
        try {
            // Lấy tất cả orders
            List<Order> allOrders = orderServices.getAll();
            
            // Filter orders theo branchId (thông qua RestaurantTable)
            // TODO: Cần implement method trong OrderServices để filter theo branchId
            
            // Thống kê cơ bản
            LocalDateTime now = LocalDateTime.now(ZoneId.of("Asia/Ho_Chi_Minh"));
            LocalDateTime startOfDay = now.withHour(0).withMinute(0).withSecond(0).withNano(0);
            LocalDateTime endOfDay = now.withHour(23).withMinute(59).withSecond(59).withNano(999999999);
            
            long totalOrdersToday = allOrders.stream()
                .filter(order -> order.getCreatedAt().isAfter(startOfDay) && order.getCreatedAt().isBefore(endOfDay))
                .count();
                
            long completedOrdersToday = allOrders.stream()
                .filter(order -> order.getCreatedAt().isAfter(startOfDay) && order.getCreatedAt().isBefore(endOfDay))
                .filter(order -> order.getStatusId() == 3) // Assuming 3 = COMPLETED
                .count();
                
            long pendingOrdersToday = allOrders.stream()
                .filter(order -> order.getCreatedAt().isAfter(startOfDay) && order.getCreatedAt().isBefore(endOfDay))
                .filter(order -> order.getStatusId() == 1 || order.getStatusId() == 2) // PENDING or SERVING
                .count();
            
            Map<String, Object> statistics = new HashMap<>();
            statistics.put("branchId", branchId);
            statistics.put("date", now.toLocalDate().toString());
            statistics.put("totalOrdersToday", totalOrdersToday);
            statistics.put("completedOrdersToday", completedOrdersToday);
            statistics.put("pendingOrdersToday", pendingOrdersToday);
            statistics.put("completionRate", totalOrdersToday > 0 ? (double) completedOrdersToday / totalOrdersToday * 100 : 0);
            
            return ResponseEntity.ok(statistics);
        } catch (Exception ex) {
            return ResponseEntity.internalServerError().body("Lỗi " + ex.getMessage());
        }
    }

    // Tóm tắt đơn hàng hôm nay theo chi nhánh
    @GetMapping("/summary/today/{branchId}")
    public ResponseEntity<?> getTodayOrderSummary(@PathVariable Integer branchId) {
        try {
            LocalDateTime now = LocalDateTime.now(ZoneId.of("Asia/Ho_Chi_Minh"));
            LocalDateTime startOfDay = now.withHour(0).withMinute(0).withSecond(0).withNano(0);
            LocalDateTime endOfDay = now.withHour(23).withMinute(59).withSecond(59).withNano(999999999);
            
            List<Order> allOrders = orderServices.getAll();
            
            // Filter orders hôm nay
            List<Order> todayOrders = allOrders.stream()
                .filter(order -> order.getCreatedAt().isAfter(startOfDay) && order.getCreatedAt().isBefore(endOfDay))
                .toList();
            
            // Thống kê theo trạng thái
            Map<String, Long> statusCounts = new HashMap<>();
            statusCounts.put("pending", todayOrders.stream().filter(o -> o.getStatusId() == 1).count());
            statusCounts.put("serving", todayOrders.stream().filter(o -> o.getStatusId() == 2).count());
            statusCounts.put("completed", todayOrders.stream().filter(o -> o.getStatusId() == 3).count());
            statusCounts.put("cancelled", todayOrders.stream().filter(o -> o.getStatusId() == 4).count());
            
            // Thống kê theo giờ
            Map<Integer, Long> hourlyOrders = new HashMap<>();
            for (int hour = 0; hour < 24; hour++) {
                final int currentHour = hour;
                long count = todayOrders.stream()
                    .filter(order -> order.getCreatedAt().getHour() == currentHour)
                    .count();
                hourlyOrders.put(hour, count);
            }
            
            Map<String, Object> summary = new HashMap<>();
            summary.put("branchId", branchId);
            summary.put("date", now.toLocalDate().toString());
            summary.put("totalOrders", todayOrders.size());
            summary.put("statusBreakdown", statusCounts);
            summary.put("hourlyBreakdown", hourlyOrders);
            summary.put("lastUpdated", now.toString());
            
            return ResponseEntity.ok(summary);
        } catch (Exception ex) {
            return ResponseEntity.internalServerError().body("Lỗi " + ex.getMessage());
        }
    }

    // Giờ cao điểm đặt hàng theo chi nhánh
    @GetMapping("/peak-hours/{branchId}")
    public ResponseEntity<?> getPeakHours(@PathVariable Integer branchId) {
        try {
            LocalDateTime now = LocalDateTime.now(ZoneId.of("Asia/Ho_Chi_Minh"));
            LocalDateTime startOfWeek = now.minusDays(7).withHour(0).withMinute(0).withSecond(0).withNano(0);
            
            List<Order> allOrders = orderServices.getAll();
            
            // Lấy orders trong 7 ngày qua
            List<Order> weekOrders = allOrders.stream()
                .filter(order -> order.getCreatedAt().isAfter(startOfWeek))
                .toList();
            
            // Thống kê theo giờ trong tuần
            Map<Integer, Long> hourlyStats = new HashMap<>();
            for (int hour = 0; hour < 24; hour++) {
                final int currentHour = hour;
                long count = weekOrders.stream()
                    .filter(order -> order.getCreatedAt().getHour() == currentHour)
                    .count();
                hourlyStats.put(hour, count);
            }
            
            // Tìm giờ cao điểm (top 3 giờ có nhiều order nhất)
            List<Map.Entry<Integer, Long>> sortedHours = hourlyStats.entrySet().stream()
                .sorted(Map.Entry.<Integer, Long>comparingByValue().reversed())
                .limit(3)
                .toList();
            
            Map<String, Object> peakHours = new HashMap<>();
            peakHours.put("branchId", branchId);
            peakHours.put("analysisPeriod", "Last 7 days");
            peakHours.put("hourlyStats", hourlyStats);
            peakHours.put("top3PeakHours", sortedHours.stream()
                .map(entry -> {
                    Map<String, Object> hourData = new HashMap<>();
                    hourData.put("hour", entry.getKey());
                    hourData.put("orderCount", entry.getValue());
                    hourData.put("timeRange", String.format("%02d:00 - %02d:59", entry.getKey(), entry.getKey()));
                    return hourData;
                })
                .toList());
            
            return ResponseEntity.ok(peakHours);
        } catch (Exception ex) {
            return ResponseEntity.internalServerError().body("Lỗi " + ex.getMessage());
        }
    }

}
