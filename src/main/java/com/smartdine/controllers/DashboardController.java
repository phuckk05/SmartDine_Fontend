package com.smartdine.controllers;

import java.time.LocalDate;
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
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.smartdine.models.Order;
import com.smartdine.models.RestaurantTable;
import com.smartdine.models.User;
import com.smartdine.models.UserBranch;
import com.smartdine.services.OrderServices;
import com.smartdine.services.PaymentService;
import com.smartdine.services.RestaurantTableServices;
import com.smartdine.services.UserBranchSevices;
import com.smartdine.services.UserService;

@RestController
@RequestMapping("/api/dashboard")
public class DashboardController {

    @Autowired
    private OrderServices orderServices;

    @Autowired
    private RestaurantTableServices restaurantTableServices;

    @Autowired
    private UserService userService;

    @Autowired
    private UserBranchSevices userBranchServices;

    @Autowired
    private PaymentService paymentService;

    // Lấy thống kê tổng quan dashboard theo chi nhánh
    @GetMapping("/overview/branch/{branchId}")
    public ResponseEntity<?> getDashboardOverview(@PathVariable Integer branchId,
                                                @RequestParam(value = "date", required = false) String dateStr) {
        try {
            LocalDate targetDate = dateStr != null ? LocalDate.parse(dateStr) : LocalDate.now();
            LocalDateTime startOfDay = targetDate.atStartOfDay();
            LocalDateTime endOfDay = targetDate.atTime(23, 59, 59);

            // Lấy thống kê orders
            List<Order> allOrders = orderServices.getOrdersByBranchId(branchId);
            List<Order> todayOrders = allOrders.stream()
                .filter(order -> order.getCreatedAt().isAfter(startOfDay) && order.getCreatedAt().isBefore(endOfDay))
                .toList();

            // Lấy thống kê bàn
            List<RestaurantTable> allTables = restaurantTableServices.getByBranchId(branchId);
            List<Integer> unpaidTableIds = orderServices.getUnpaidOrderTableIdsToday();
            int occupiedTables = (int) allTables.stream()
                .filter(table -> unpaidTableIds.contains(table.getId()))
                .count();

            // Lấy thống kê nhân viên
            List<UserBranch> userBranches = userBranchServices.getByBranchId(branchId);
            List<User> employees = userBranches.stream()
                .map(ub -> userService.getUserById(ub.getUserId()))
                .filter(user -> user != null && user.getDeletedAt() == null)
                .toList();

            // Lấy doanh thu
            java.math.BigDecimal revenue = paymentService.getRevenueByDay(targetDate, branchId, null);

            // Tính toán các metrics
            long completedOrders = todayOrders.stream().filter(o -> o.getStatusId() == 3).count();
            long pendingOrders = todayOrders.stream().filter(o -> o.getStatusId() == 1 || o.getStatusId() == 2).count();
            double occupancyRate = !allTables.isEmpty() ? (double) occupiedTables / allTables.size() * 100 : 0;
            int activeEmployees = (int) employees.stream().filter(emp -> emp.getStatusId() == 1).count();

            // Tạo response
            Map<String, Object> overview = new HashMap<>();
            overview.put("branchId", branchId);
            overview.put("date", targetDate.toString());
            overview.put("lastUpdated", LocalDateTime.now(ZoneId.of("Asia/Ho_Chi_Minh")).toString());

            // Orders metrics
            Map<String, Object> orderMetrics = new HashMap<>();
            orderMetrics.put("totalOrders", todayOrders.size());
            orderMetrics.put("completedOrders", completedOrders);
            orderMetrics.put("pendingOrders", pendingOrders);
            orderMetrics.put("completionRate", !todayOrders.isEmpty() ? (double) completedOrders / todayOrders.size() * 100 : 0);

            // Table metrics
            Map<String, Object> tableMetrics = new HashMap<>();
            tableMetrics.put("totalTables", allTables.size());
            tableMetrics.put("occupiedTables", occupiedTables);
            tableMetrics.put("availableTables", allTables.size() - occupiedTables);
            tableMetrics.put("occupancyRate", Math.round(occupancyRate * 100) / 100.0);

            // Staff metrics
            Map<String, Object> staffMetrics = new HashMap<>();
            staffMetrics.put("totalStaff", employees.size());
            staffMetrics.put("activeStaff", activeEmployees);
            staffMetrics.put("inactiveStaff", employees.size() - activeEmployees);

            // Revenue metrics
            Map<String, Object> revenueMetrics = new HashMap<>();
            revenueMetrics.put("todayRevenue", revenue != null ? revenue.doubleValue() : 0.0);
            revenueMetrics.put("avgOrderValue", !todayOrders.isEmpty() && revenue != null ? 
                revenue.doubleValue() / todayOrders.size() : 0.0);

            overview.put("orders", orderMetrics);
            overview.put("tables", tableMetrics);
            overview.put("staff", staffMetrics);
            overview.put("revenue", revenueMetrics);

            return ResponseEntity.ok(overview);
        } catch (Exception ex) {
            return ResponseEntity.internalServerError().body("Lỗi " + ex.getMessage());
        }
    }

    // Lấy thống kê theo giờ trong ngày
    @GetMapping("/hourly/branch/{branchId}")
    public ResponseEntity<?> getHourlyStatistics(@PathVariable Integer branchId,
                                               @RequestParam(value = "date", required = false) String dateStr) {
        try {
            LocalDate targetDate = dateStr != null ? LocalDate.parse(dateStr) : LocalDate.now();
            LocalDateTime startOfDay = targetDate.atStartOfDay();
            LocalDateTime endOfDay = targetDate.atTime(23, 59, 59);

            List<Order> todayOrders = orderServices.getOrdersByBranchId(branchId).stream()
                .filter(order -> order.getCreatedAt().isAfter(startOfDay) && order.getCreatedAt().isBefore(endOfDay))
                .toList();

            // Thống kê theo giờ
            Map<Integer, Integer> hourlyOrders = new HashMap<>();
            for (int hour = 0; hour < 24; hour++) {
                final int currentHour = hour;
                int count = (int) todayOrders.stream()
                    .filter(order -> order.getCreatedAt().getHour() == currentHour)
                    .count();
                hourlyOrders.put(hour, count);
            }

            Map<String, Object> result = new HashMap<>();
            result.put("branchId", branchId);
            result.put("date", targetDate.toString());
            result.put("hourlyData", hourlyOrders);
            result.put("peakHour", hourlyOrders.entrySet().stream()
                .max(Map.Entry.comparingByValue())
                .map(Map.Entry::getKey)
                .orElse(12)); // Default to noon

            return ResponseEntity.ok(result);
        } catch (Exception ex) {
            return ResponseEntity.internalServerError().body("Lỗi " + ex.getMessage());
        }
    }

    // Lấy top trending items hôm nay
    @GetMapping("/trending/branch/{branchId}")
    public ResponseEntity<?> getTrendingItems(@PathVariable Integer branchId,
                                            @RequestParam(value = "limit", defaultValue = "5") int limit) {
        try {
            // Mock trending items data - có thể thay bằng dữ liệu thực từ OrderItemService
            Map<String, Object> trending = new HashMap<>();
            trending.put("branchId", branchId);
            trending.put("date", LocalDate.now().toString());
            
            // Mock top dishes
            java.util.List<Map<String, Object>> topDishes = java.util.Arrays.asList(
                Map.of("itemId", 1, "name", "Phở Bò Tái", "orders", 25, "revenue", 1250000),
                Map.of("itemId", 2, "name", "Bún Chả Hà Nội", "orders", 18, "revenue", 900000),
                Map.of("itemId", 3, "name", "Cơm Tấm Sườn", "orders", 15, "revenue", 750000),
                Map.of("itemId", 4, "name", "Bánh Mì Thịt", "orders", 12, "revenue", 360000),
                Map.of("itemId", 5, "name", "Chả Cá Lã Vọng", "orders", 8, "revenue", 640000)
            );
            
            trending.put("topDishes", topDishes.stream().limit(limit).toList());
            trending.put("totalItems", topDishes.size());

            return ResponseEntity.ok(trending);
        } catch (Exception ex) {
            return ResponseEntity.internalServerError().body("Lỗi " + ex.getMessage());
        }
    }
}