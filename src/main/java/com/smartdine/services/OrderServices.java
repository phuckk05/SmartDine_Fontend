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
import com.smartdine.models.OrderItem;
import com.smartdine.models.Branch;
import com.smartdine.models.User;
import com.smartdine.repository.OrderItemRepository;
import com.smartdine.repository.OrderRepository;
import com.smartdine.repository.OrderStatusRepository;
import com.smartdine.repository.UserRepository;
import com.smartdine.repository.BranchRepository;

@Service
public class OrderServices {

    @Autowired
    OrderRepository orderRepository;
    @Autowired
    OrderItemRepository orderItemRepository;
    @Autowired
    OrderStatusRepository orderStatusRepository;
    @Autowired
    UserRepository userRepository;
    @Autowired
    BranchRepository branchRepository;

    // save order
    public Order saveOrder(Order order) {
        return orderRepository.save(order);
    }

    // Lấy tất cả order
    public java.util.List<Order> getAll() {
        return orderRepository.findAll();
    }

    /** Lấy order theo id */
    public Order getById(Integer id) {
        if (id == null)
            return null;
        return orderRepository.findById(id).orElse(null);
    }

    // Lấy danh sách tableId đã có order chưa thanh toán ngay hôm nay
    // statusId = 2 là "SERVING" (đang phục vụ, chưa thanh toán)
    // Sử dụng múi giờ Việt Nam (Asia/Ho_Chi_Minh - GMT+7)
    // by branchID
    public List<Integer> getUnpaidOrderTableIdsTodayByBranch(Integer branchId) {
        LocalDateTime now = LocalDateTime.now(ZoneId.of("Asia/Ho_Chi_Minh"));
        LocalDateTime startOfDay = now.withHour(0).withMinute(0).withSecond(0).withNano(0);
        LocalDateTime endOfDay = now.withHour(23).withMinute(59).withSecond(59).withNano(999999999);

        return orderRepository.findDistinctTableIdByStatusIdAndCreatedAtBetweenAndBranchId(2, startOfDay, endOfDay,
                branchId);
    }

    // Lấy danh sách tableId đã có order chưa thanh toán (tất cả chi nhánh)
    public List<Integer> getUnpaidOrderTableIdsToday() {
        LocalDateTime now = LocalDateTime.now(ZoneId.of("Asia/Ho_Chi_Minh"));
        LocalDateTime startOfDay = now.withHour(0).withMinute(0).withSecond(0).withNano(0);
        LocalDateTime endOfDay = now.withHour(23).withMinute(59).withSecond(59).withNano(999999999);
        return orderRepository.findDistinctTableIdByStatusIdAndCreatedAtBetween(2, startOfDay, endOfDay);
    }

    /** Lấy danh sách order theo tableId ngay hôm nay */
    public List<Order> getOrdersByTableIdToday(Integer tableId) {
        if (tableId == null)
            return List.of();
        LocalDateTime now = LocalDateTime.now(ZoneId.of("Asia/Ho_Chi_Minh"));
        LocalDateTime startOfDay = now.withHour(0).withMinute(0).withSecond(0).withNano(0);
        LocalDateTime endOfDay = now.withHour(23).withMinute(59).withSecond(59).withNano(999999999);
        return orderRepository.findByTableIdAndCreatedAtBetween(tableId, startOfDay, endOfDay);
    }

    // Lấy danh sách order theo branchId ngay hôm nay
    public List<Order> getOrdersByBranchIdToday(Integer branchId) {
        LocalDateTime now = LocalDateTime.now(ZoneId.of("Asia/Ho_Chi_Minh"));
        LocalDateTime startOfDay = now.withHour(0).withMinute(0).withSecond(0).withNano(0);
        LocalDateTime endOfDay = now.withHour(23).withMinute(59).withSecond(59).withNano(999999999);

        return orderRepository.findByBranchIdAndCreatedAtBetween(branchId, startOfDay, endOfDay);
    }

    // Lấy danh sách orders theo branchId
    public List<Order> getOrdersByBranchId(Integer branchId) {
        if (branchId == null)
            return List.of();
        return orderRepository.findByBranchId(branchId);
    }

    /** Lấy xu hướng doanh thu theo branch trong 7 ngày gần đây */
    public List<Map<String, Object>> getRevenueTrendsByBranch(Integer branchId) {
        if (branchId == null)
            return List.of();
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

    /** Lấy doanh thu theo giờ hôm nay */
    public List<Map<String, Object>> getHourlyRevenueByBranch(Integer branchId) {
        if (branchId == null)
            return List.of();
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

    // Lấy danh sách orders theo branchId và trạng thái
    public List<Order> getOrdersByBranchIdAndStatus(Integer branchId, Integer statusId) {
        LocalDateTime now = LocalDateTime.now(ZoneId.of("Asia/Ho_Chi_Minh"));
        LocalDateTime startOfDay = now.withHour(0).withMinute(0).withSecond(0).withNano(0);
        LocalDateTime endOfDay = now.withHour(23).withMinute(59).withSecond(59).withNano(999999999);

        int targetStatus = statusId != null ? statusId : 2;

        return orderRepository.findUnpaidOrdersTodayByBranchId(
                branchId,
                targetStatus,
                startOfDay,
                endOfDay);
    }

    /** Lấy danh sách món theo orderId */
    public List<OrderItem> getOrderItemsByOrderId(Integer orderId) {
        if (orderId == null)
            return List.of();
        return orderItemRepository.findByOrderId(orderId);
    }

    /** Lấy trạng thái đơn hàng */
    public com.smartdine.models.status.OrderStatus getOrderStatusById(Integer statusId) {
        if (statusId == null)
            return null;
        return orderStatusRepository.findById(statusId).orElse(null);
    }

    /** Lấy tên nhân viên */
    public String getUserNameById(Integer userId) {
        if (userId == null)
            return null;
        User user = userRepository.findById(userId).orElse(null);
        return user != null ? user.getFullName() : null;
    }

    /** Lấy tên chi nhánh */
    public String getBranchNameById(Integer branchId) {
        if (branchId == null)
            return null;
        Branch branch = branchRepository.findById(branchId).orElse(null);
        return branch != null ? branch.getName() : null;
    }

    /** Tính tổng tiền đơn hàng */
    public Double getTotalAmountByOrderId(Integer orderId) {
        if (orderId == null)
            return 0.0;
        List<OrderItem> items = getOrderItemsByOrderId(orderId);
        return items.stream()
                .mapToDouble(item -> {
                    try {
                        java.lang.reflect.Method m = item.getClass().getMethod("getItemPrice");
                        Object price = m.invoke(item);
                        return price instanceof Number ? ((Number) price).doubleValue() : 0.0;
                    } catch (Exception e) {
                        return 0.0;
                    }
                })
                .sum();
    }
}
