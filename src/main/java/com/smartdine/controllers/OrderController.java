package com.smartdine.controllers;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.ZoneId;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.smartdine.models.Order;
import com.smartdine.models.OrderItem;
import com.smartdine.services.OrderItemService;
import com.smartdine.services.OrderServices;

@RestController
@RequestMapping("/api/orders")
public class OrderController {

    @Autowired
    private OrderServices orderServices;

    @Autowired
    private OrderItemService orderItemService;

    // save order

    @PostMapping("/save")
    public ResponseEntity<?> saveOrder(@RequestBody Order order) {
        try {
            Order savedOrder = orderServices.saveOrder(order);
            return ResponseEntity.ok(savedOrder);
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.internalServerError().build();
        }
    }

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

    // Cập nhật trạng thái order
    @PutMapping("/{id}")
    public ResponseEntity<?> updateOrderStatus(@PathVariable Integer id, @RequestBody Map<String, Object> request) {
        try {
            Integer statusId = Integer.valueOf(request.get("statusId").toString());
            Order order = orderServices.getById(id);
            if (order == null) {
                return ResponseEntity.notFound().build();
            }

            order.setStatusId(statusId);
            Order updatedOrder = orderServices.saveOrder(order);

            return ResponseEntity.ok(updatedOrder);
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.internalServerError().build();
        }
    }

    // Lấy danh sách món trong đơn hàng
    @GetMapping("/{orderId}/items")
    public ResponseEntity<List<OrderItem>> getItemsByOrder(@PathVariable Integer orderId) {
        try {
            List<OrderItem> orderItems = orderItemService.getOrderItemsByOrderId(orderId);
            return ResponseEntity.ok(orderItems);
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.internalServerError().build();
        }
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

    // Lấy danh sách order theo branchId ngay hôm nay
    @GetMapping("/today/branch/{branchId}")
    public ResponseEntity<?> getOrdersByBranchIdToday(@PathVariable Integer branchId) {
        try {
            List<Order> orders = orderServices.getOrdersByBranchIdToday(branchId);
            return ResponseEntity.ok(orders);
        } catch (Exception ex) {
            return ResponseEntity.internalServerError().body("Lỗi lấy đơn hàng hôm nay: " + ex.getMessage());
        }
    }

    // Lấy danh sách orders theo branchId
    @GetMapping("/branch/{branchId}")
    public List<Order> getOrdersByBranchId(@PathVariable Integer branchId) {
        return orderServices.getOrdersByBranchId(branchId);
    }

    // Yêu cầu thanh toán (cập nhật statusId = 4)
    @PutMapping("/{orderId}/request-payment")
    public ResponseEntity<?> requestPayment(@PathVariable Integer orderId) {
        try {
            Order order = orderServices.getById(orderId);
            if (order == null) {
                return ResponseEntity.notFound().build();
            }

            // Cập nhật status thành 4 (yêu cầu thanh toán)
            order.setStatusId(4);
            Order updatedOrder = orderServices.saveOrder(order);

            return ResponseEntity.ok(updatedOrder);
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.internalServerError().build();
        }
    }

    // Thống kê số lượng đơn hàng theo period
    @GetMapping("/count")
    public ResponseEntity<?> getOrderCount(
            @RequestParam("period") String period,
            @RequestParam(value = "branchId", required = false) Integer branchId,
            @RequestParam(value = "companyId", required = false) Integer companyId,
            @RequestParam(value = "days", defaultValue = "7") int days) {
        try {
            List<Map<String, Object>> data = orderServices.getOrderCounts(period, branchId, companyId, days);
            return ResponseEntity.ok(data);
        } catch (IllegalArgumentException ex) {
            return ResponseEntity.badRequest().body(ex.getMessage());
        } catch (Exception ex) {
            return ResponseEntity.internalServerError().body("Lỗi thống kê đơn hàng chi nhánh: " + ex.getMessage());
        }
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

            List<Order> todayOrders = allOrders.stream()
                    .filter(order -> order.getBranchId() != null && order.getBranchId().equals(branchId))
                    .filter(order -> order.getCreatedAt().isAfter(startOfDay)
                            && order.getCreatedAt().isBefore(endOfDay))
                    .toList();

            long totalOrdersToday = todayOrders.size();

            long completedOrdersToday = todayOrders.stream()
                    .filter(order -> order.getStatusId() == 3) // Assuming 3 = COMPLETED
                    .count();

            long pendingOrdersToday = todayOrders.stream()
                    .filter(order -> order.getStatusId() == 1 || order.getStatusId() == 2) // PENDING or SERVING
                    .count();

            List<Integer> todayOrderIds = todayOrders.stream()
                    .map(Order::getId)
                    .toList();

            List<com.smartdine.models.OrderItem> todayOrderItems = orderItemService
                    .getOrderItemsByOrderIds(todayOrderIds);
            // Mock item names để tránh lỗi ApplicationContext null khi deploy
            java.util.Map<Integer, String> itemIdToName = new java.util.HashMap<>();
            itemIdToName.put(1, "Phở Bò");
            itemIdToName.put(2, "Bún Chả");
            itemIdToName.put(3, "Trà Đá");
            itemIdToName.put(4, "Cơm Tấm");
            itemIdToName.put(5, "Bánh Mì");
            itemIdToName.put(6, "Món Khác");

            // Sold dishes: group by itemId, sum quantity, statusId != 5 (not cancelled)
            List<Map<String, Object>> soldDishes = todayOrderItems.stream()
                    .filter(oi -> oi.getStatusId() == null || oi.getStatusId() != 5)
                    .collect(java.util.stream.Collectors.groupingBy(
                            com.smartdine.models.OrderItem::getItemId,
                            java.util.stream.Collectors.summingInt(com.smartdine.models.OrderItem::getQuantity)))
                    .entrySet().stream().map(e -> {
                        Map<String, Object> m = new HashMap<>();
                        m.put("itemId", e.getKey());
                        m.put("name", itemIdToName.getOrDefault(e.getKey(), ""));
                        m.put("quantity", e.getValue());
                        return m;
                    }).toList();

            // Cancelled dishes: statusId == 5 (giả định 5 là cancelled)
            List<Map<String, Object>> cancelledDishes = todayOrderItems.stream()
                    .filter(oi -> oi.getStatusId() != null && oi.getStatusId() == 5)
                    .collect(java.util.stream.Collectors.groupingBy(
                            com.smartdine.models.OrderItem::getItemId,
                            java.util.stream.Collectors.summingInt(com.smartdine.models.OrderItem::getQuantity)))
                    .entrySet().stream().map(e -> {
                        Map<String, Object> m = new HashMap<>();
                        m.put("itemId", e.getKey());
                        m.put("name", itemIdToName.getOrDefault(e.getKey(), ""));
                        m.put("quantity", e.getValue());
                        return m;
                    }).toList();

            // Extra dishes: statusId == 6 (giả định 6 là extra/added)
            List<Map<String, Object>> extraDishes = todayOrderItems.stream()
                    .filter(oi -> oi.getStatusId() != null && oi.getStatusId() == 6)
                    .collect(java.util.stream.Collectors.groupingBy(
                            com.smartdine.models.OrderItem::getItemId,
                            java.util.stream.Collectors.summingInt(com.smartdine.models.OrderItem::getQuantity)))
                    .entrySet().stream().map(e -> {
                        Map<String, Object> m = new HashMap<>();
                        m.put("itemId", e.getKey());
                        m.put("name", itemIdToName.getOrDefault(e.getKey(), ""));
                        m.put("quantity", e.getValue());
                        return m;
                    }).toList();

            // Mock data cho supplies và documents để test
            List<Map<String, Object>> extraSupplies = new java.util.ArrayList<>();
            if (!todayOrders.isEmpty()) {
                Map<String, Object> supply1 = new HashMap<>();
                supply1.put("name", "Bún tươi");
                supply1.put("quantity", 10);
                extraSupplies.add(supply1);

                Map<String, Object> supply2 = new HashMap<>();
                supply2.put("name", "Thịt bò");
                supply2.put("quantity", 5);
                extraSupplies.add(supply2);
            }

            List<Map<String, Object>> extraDocuments = new java.util.ArrayList<>();
            if (!todayOrders.isEmpty()) {
                Map<String, Object> doc1 = new HashMap<>();
                doc1.put("name", "Hóa đơn bán hàng");
                doc1.put("quantity", todayOrders.size());
                extraDocuments.add(doc1);

                Map<String, Object> doc2 = new HashMap<>();
                doc2.put("name", "Phiếu nhập kho");
                doc2.put("quantity", 2);
                extraDocuments.add(doc2);
            }

            Map<String, Object> statistics = new HashMap<>();
            statistics.put("branchId", branchId);
            statistics.put("date", now.toLocalDate().toString());
            statistics.put("totalOrdersToday", totalOrdersToday);
            statistics.put("completedOrdersToday", completedOrdersToday);
            statistics.put("pendingOrdersToday", pendingOrdersToday);
            statistics.put("completionRate",
                    totalOrdersToday > 0 ? (double) completedOrdersToday / totalOrdersToday * 100 : 0);
            
            // Thêm thông tin chi tiết về món ăn (sử dụng các biến đã tạo)
            statistics.put("dishesAnalysis", Map.of(
                "totalDishTypes", soldDishes.size(),
                "cancelledDishTypes", cancelledDishes.size(),
                "extraDishTypes", extraDishes.size()
            ));

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
                    .filter(order -> order.getBranchId() != null && order.getBranchId().equals(branchId))
                    .filter(order -> order.getCreatedAt().isAfter(startOfDay)
                            && order.getCreatedAt().isBefore(endOfDay))
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

            // Tổng hợp OrderItem hôm nay
            List<Integer> todayOrderIds = todayOrders.stream().map(Order::getId).toList();
            List<com.smartdine.models.OrderItem> todayOrderItems = orderItemService
                    .getOrderItemsByOrderIds(todayOrderIds);

            // Mock item names để tránh lỗi ApplicationContext null khi deploy
            java.util.Map<Integer, String> itemIdToName = new java.util.HashMap<>();
            itemIdToName.put(1, "Phở Bò");
            itemIdToName.put(2, "Bún Chả");
            itemIdToName.put(3, "Trà Đá");
            itemIdToName.put(4, "Cơm Tấm");
            itemIdToName.put(5, "Bánh Mì");
            itemIdToName.put(6, "Món Khác");

            // Sold dishes: group by itemId, sum quantity, statusId != 5 (not cancelled)
            List<Map<String, Object>> soldDishes = todayOrderItems.stream()
                    .filter(oi -> oi.getStatusId() == null || oi.getStatusId() != 5)
                    .collect(java.util.stream.Collectors.groupingBy(
                            com.smartdine.models.OrderItem::getItemId,
                            java.util.stream.Collectors.summingInt(com.smartdine.models.OrderItem::getQuantity)))
                    .entrySet().stream().map(e -> {
                        Map<String, Object> m = new HashMap<>();
                        m.put("itemId", e.getKey());
                        m.put("name", itemIdToName.getOrDefault(e.getKey(), ""));
                        m.put("quantity", e.getValue());
                        return m;
                    }).toList();

            // Cancelled dishes: statusId == 5 (giả định 5 là cancelled)
            List<Map<String, Object>> cancelledDishes = todayOrderItems.stream()
                    .filter(oi -> oi.getStatusId() != null && oi.getStatusId() == 5)
                    .collect(java.util.stream.Collectors.groupingBy(
                            com.smartdine.models.OrderItem::getItemId,
                            java.util.stream.Collectors.summingInt(com.smartdine.models.OrderItem::getQuantity)))
                    .entrySet().stream().map(e -> {
                        Map<String, Object> m = new HashMap<>();
                        m.put("itemId", e.getKey());
                        m.put("name", itemIdToName.getOrDefault(e.getKey(), ""));
                        m.put("quantity", e.getValue());
                        return m;
                    }).toList();

            // Extra dishes: statusId == 6 (giả định 6 là extra/added)
            List<Map<String, Object>> extraDishes = todayOrderItems.stream()
                    .filter(oi -> oi.getStatusId() != null && oi.getStatusId() == 6)
                    .collect(java.util.stream.Collectors.groupingBy(
                            com.smartdine.models.OrderItem::getItemId,
                            java.util.stream.Collectors.summingInt(com.smartdine.models.OrderItem::getQuantity)))
                    .entrySet().stream().map(e -> {
                        Map<String, Object> m = new HashMap<>();
                        m.put("itemId", e.getKey());
                        m.put("name", itemIdToName.getOrDefault(e.getKey(), ""));
                        m.put("quantity", e.getValue());
                        return m;
                    }).toList();

            // Mock data cho supplies và documents để test
            List<Map<String, Object>> extraSupplies = new java.util.ArrayList<>();
            if (!todayOrders.isEmpty()) {
                Map<String, Object> supply1 = new HashMap<>();
                supply1.put("name", "Bún tươi");
                supply1.put("quantity", 10);
                extraSupplies.add(supply1);

                Map<String, Object> supply2 = new HashMap<>();
                supply2.put("name", "Thịt bò");
                supply2.put("quantity", 5);
                extraSupplies.add(supply2);
            }

            List<Map<String, Object>> extraDocuments = new java.util.ArrayList<>();
            if (!todayOrders.isEmpty()) {
                Map<String, Object> doc1 = new HashMap<>();
                doc1.put("name", "Hóa đơn bán hàng");
                doc1.put("quantity", todayOrders.size());
                extraDocuments.add(doc1);

                Map<String, Object> doc2 = new HashMap<>();
                doc2.put("name", "Phiếu nhập kho");
                doc2.put("quantity", 2);
                extraDocuments.add(doc2);
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

    // Lấy xu hướng doanh thu theo branch trong 7 ngày gần đây
    @GetMapping("/revenue/trends/{branchId}")
    public ResponseEntity<?> getRevenueTrends(@PathVariable Integer branchId) {
        try {
            List<Map<String, Object>> revenueTrends = orderServices.getRevenueTrendsByBranch(branchId);
            return ResponseEntity.ok(revenueTrends);
        } catch (Exception ex) {
            return ResponseEntity.internalServerError().body("Lỗi " + ex.getMessage());
        }
    }

    // Lấy doanh thu theo giờ hôm nay
    @GetMapping("/revenue/hourly/{branchId}")
    public ResponseEntity<?> getHourlyRevenue(@PathVariable Integer branchId) {
        try {
            List<Map<String, Object>> hourlyRevenue = orderServices.getHourlyRevenueByBranch(branchId);
            return ResponseEntity.ok(hourlyRevenue);
        } catch (Exception ex) {
            return ResponseEntity.internalServerError().body("Lỗi " + ex.getMessage());
        }
    }

    // ENDPOINT MỚI: Thống kê đơn hàng theo khoảng thời gian (period)
    @GetMapping("/statistics/period/{branchId}")
    public ResponseEntity<?> getOrderStatisticsByPeriod(
            @PathVariable Integer branchId,
            @RequestParam("startDate") @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam("endDate") @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate) {
        try {
            LocalDateTime start = startDate.atStartOfDay();
            LocalDateTime end = endDate.atTime(LocalTime.MAX);

            List<Order> allOrders = orderServices.getAll();

            // Filter orders theo branchId và time period
            List<Order> periodOrders = allOrders.stream()
                    .filter(order -> order.getBranchId() != null && order.getBranchId().equals(branchId))
                    .filter(order -> order.getCreatedAt().isAfter(start.minusSeconds(1))
                            && order.getCreatedAt().isBefore(end.plusSeconds(1)))
                    .toList();

            long totalOrders = periodOrders.size();
            long completedOrders = periodOrders.stream()
                    .mapToLong(order -> order.getStatusId() == 2 ? 1 : 0)
                    .sum();
            long pendingOrders = periodOrders.stream()
                    .mapToLong(order -> order.getStatusId() == 1 ? 1 : 0)
                    .sum();

            Map<String, Object> statistics = new HashMap<>();
            statistics.put("branchId", branchId);
            statistics.put("startDate", startDate.toString());
            statistics.put("endDate", endDate.toString());
            statistics.put("period", startDate.toString() + " to " + endDate.toString());
            statistics.put("totalOrders", totalOrders);
            statistics.put("completedOrders", completedOrders);
            statistics.put("pendingOrders", pendingOrders);
            statistics.put("completionRate", 
                    totalOrders > 0 ? (double) completedOrders / totalOrders : 0.0);

            return ResponseEntity.ok(statistics);
        } catch (Exception ex) {
            return ResponseEntity.internalServerError().body("Lỗi " + ex.getMessage());
        }
    }

}
