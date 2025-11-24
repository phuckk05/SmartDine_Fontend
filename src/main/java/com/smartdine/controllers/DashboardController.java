package com.smartdine.controllers;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.ArrayList;
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
import com.smartdine.models.OrderItem;
import com.smartdine.models.RestaurantTable;
import com.smartdine.models.User;
import com.smartdine.models.UserBranch;
import com.smartdine.services.OrderItemService;
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
    private OrderItemService orderItemService;

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
            LocalDate today = LocalDate.now();
            LocalDateTime startOfDay = today.atStartOfDay();
            LocalDateTime endOfDay = today.atTime(23, 59, 59);

            // Lấy orders hôm nay theo branch
            List<Order> todayOrders = orderServices.getOrdersByBranchId(branchId).stream()
                .filter(order -> order.getCreatedAt().isAfter(startOfDay) && order.getCreatedAt().isBefore(endOfDay))
                .toList();

            // Lấy order items từ các orders hôm nay
            List<Integer> orderIds = todayOrders.stream().map(Order::getId).toList();
            List<OrderItem> orderItems = orderItemService.getOrderItemsByOrderIds(orderIds);

            // Thống kê món ăn
            Map<Integer, Map<String, Object>> itemStats = new HashMap<>();
            for (OrderItem item : orderItems) {
                Integer itemId = item.getItemId();
                itemStats.putIfAbsent(itemId, new HashMap<>());
                Map<String, Object> stats = itemStats.get(itemId);

                // Tăng số lượng
                stats.put("orders", ((Integer) stats.getOrDefault("orders", 0)) + item.getQuantity());

                // Lưu thông tin item
                stats.put("itemId", itemId);
                stats.put("name", "Món " + itemId); // Placeholder name
            }

            // Chuyển thành list và sắp xếp theo số lượng giảm dần
            List<Map<String, Object>> topDishes = itemStats.values().stream()
                .sorted((a, b) -> ((Integer) b.get("orders")).compareTo((Integer) a.get("orders")))
                .limit(limit)
                .collect(java.util.stream.Collectors.toList());

            Map<String, Object> trending = new HashMap<>();
            trending.put("branchId", branchId);
            trending.put("date", today.toString());
            trending.put("topDishes", topDishes);
            trending.put("totalItems", topDishes.size());

            return ResponseEntity.ok(trending);
        } catch (Exception ex) {
            return ResponseEntity.internalServerError().body("Lỗi " + ex.getMessage());
        }
    }

    // Lấy revenue trends theo branch
    @GetMapping("/revenue-trends/branch/{branchId}")
    public ResponseEntity<?> getRevenueTrends(@PathVariable Integer branchId,
                                            @RequestParam(value = "days", defaultValue = "7") int days) {
        try {
            LocalDate endDate = LocalDate.now();
            LocalDate startDate = endDate.minusDays(days - 1);

            List<Map<String, Object>> trends = new ArrayList<>();

            for (LocalDate date = startDate; !date.isAfter(endDate); date = date.plusDays(1)) {
                LocalDateTime startOfDay = date.atStartOfDay();
                LocalDateTime endOfDay = date.atTime(23, 59, 59);

                // Lấy orders trong ngày
                List<Order> dayOrders = orderServices.getOrdersByBranchId(branchId).stream()
                    .filter(order -> order.getCreatedAt().isAfter(startOfDay) && order.getCreatedAt().isBefore(endOfDay))
                    .toList();

                // Tính revenue từ payments trong ngày
                BigDecimal dayRevenue = paymentService.getRevenueByDay(date, branchId, null);

                Map<String, Object> trend = new HashMap<>();
                trend.put("date", date.toString());
                trend.put("revenue", dayRevenue.doubleValue());
                trend.put("orders", dayOrders.size());
                trends.add(trend);
            }

            Map<String, Object> result = new HashMap<>();
            result.put("branchId", branchId);
            result.put("period", days + " days");
            result.put("trends", trends);

            return ResponseEntity.ok(result);
        } catch (Exception ex) {
            return ResponseEntity.internalServerError().body("Lỗi lấy revenue trends: " + ex.getMessage());
        }
    }

    // Lấy dish statistics theo branch
    @GetMapping("/dish-statistics/branch/{branchId}")
    public ResponseEntity<?> getDishStatistics(@PathVariable Integer branchId,
                                             @RequestParam(value = "period", defaultValue = "week") String period) {
        try {
            LocalDate startDate;
            LocalDate endDate = LocalDate.now();

            // Xác định khoảng thời gian
            switch (period.toLowerCase()) {
                case "day":
                    startDate = endDate;
                    break;
                case "week":
                    startDate = endDate.minusDays(6);
                    break;
                case "month":
                    startDate = endDate.minusDays(29);
                    break;
                default:
                    startDate = endDate.minusDays(6); // Default to week
            }

            LocalDateTime startOfPeriod = startDate.atStartOfDay();
            LocalDateTime endOfPeriod = endDate.atTime(23, 59, 59);

            // Lấy orders trong khoảng thời gian
            List<Order> periodOrders = orderServices.getOrdersByBranchId(branchId).stream()
                .filter(order -> order.getCreatedAt().isAfter(startOfPeriod) && order.getCreatedAt().isBefore(endOfPeriod))
                .toList();

            // Lấy order items
            List<Integer> orderIds = periodOrders.stream().map(Order::getId).toList();
            List<OrderItem> orderItems = orderItemService.getOrderItemsByOrderIds(orderIds);

            // Thống kê theo món ăn
            Map<Integer, Map<String, Object>> dishStats = new HashMap<>();
            for (OrderItem item : orderItems) {
                Integer itemId = item.getItemId();
                dishStats.putIfAbsent(itemId, new HashMap<>());
                Map<String, Object> stats = dishStats.get(itemId);

                // Tăng số lượng bán
                int currentQuantity = (Integer) stats.getOrDefault("quantity", 0);
                stats.put("quantity", currentQuantity + item.getQuantity());

                // Lưu itemId
                stats.put("itemId", itemId);
                stats.put("name", "Món " + itemId); // Placeholder
            }

            // Chuyển thành list và sắp xếp theo quantity giảm dần
            List<Map<String, Object>> topDishes = dishStats.values().stream()
                .sorted((a, b) -> ((Integer) b.get("quantity")).compareTo((Integer) a.get("quantity")))
                .limit(10) // Top 10 dishes
                .collect(java.util.stream.Collectors.toList());

            Map<String, Object> result = new HashMap<>();
            result.put("branchId", branchId);
            result.put("period", period);
            result.put("startDate", startDate.toString());
            result.put("endDate", endDate.toString());
            result.put("topDishes", topDishes);

            return ResponseEntity.ok(result);
        } catch (Exception ex) {
            return ResponseEntity.internalServerError().body("Lỗi lấy dish statistics: " + ex.getMessage());
        }
    }
}