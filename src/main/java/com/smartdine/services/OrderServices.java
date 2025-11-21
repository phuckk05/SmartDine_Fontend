package com.smartdine.services;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.ZoneId;
import java.time.temporal.IsoFields;
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

    // save order
    public Order saveOrder(Order order) {
        return orderRepository.save(order);
    }

    // Lấy tất cả order
    public List<Order> getAll() {// public java.util.List<Order> getAll() {
        return orderRepository.findAll();
    }

    // Lấy order theo id
    public Order getById(Integer id) {
        return orderRepository.findById(id).orElseThrow(null);
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

    // Lấy danh sách order theo branchId ngay hôm nay
    public List<Order> getOrdersByBranchIdToday(Integer branchId) {
        LocalDateTime now = LocalDateTime.now(ZoneId.of("Asia/Ho_Chi_Minh"));
        LocalDateTime startOfDay = now.withHour(0).withMinute(0).withSecond(0).withNano(0);
        LocalDateTime endOfDay = now.withHour(23).withMinute(59).withSecond(59).withNano(999999999);

        return orderRepository.findByBranchIdAndCreatedAtBetween(branchId, startOfDay, endOfDay);
    }

    // Lấy danh sách orders theo branchId
    public List<Order> getOrdersByBranchId(Integer branchId) {
        return orderRepository.findByBranchId(branchId);
    }

    // Lấy danh sách orders theo companyId
    public List<Order> getOrdersByCompanyId(Integer companyId) {
        return orderRepository.findByCompanyId(companyId);
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

    // Đếm số lượng đơn hàng theo period và chi nhánh/công ty
    public List<Map<String, Object>> getOrderCounts(String period, Integer branchId, Integer companyId, int units) {
        if (branchId == null && companyId == null) {
            throw new IllegalArgumentException("Cần truyền branchId hoặc companyId");
        }
        if (units <= 0) {
            throw new IllegalArgumentException("Giá trị days phải lớn hơn 0");
        }

        ZoneId zoneId = ZoneId.of("Asia/Ho_Chi_Minh");
        LocalDate today = LocalDate.now(zoneId);

        return switch (period.toLowerCase()) {
            case "day", "daily" -> buildDailyCounts(branchId, companyId, units, zoneId, today);
            case "week", "weekly" -> buildWeeklyCounts(branchId, companyId, units, zoneId, today);
            case "month", "monthly" -> buildMonthlyCounts(branchId, companyId, units, zoneId, today);
            default -> throw new IllegalArgumentException("Period không hợp lệ. Sử dụng: day, week, month");
        };
    }

    private List<Map<String, Object>> buildDailyCounts(Integer branchId, Integer companyId, int days, ZoneId zoneId,
            LocalDate today) {
        return java.util.stream.IntStream.range(0, days)
                .mapToObj(offset -> today.minusDays(days - 1L - offset))
                .map(date -> {
                    LocalDateTime start = date.atStartOfDay();
                    LocalDateTime end = date.atTime(LocalTime.MAX);
                    long count = findOrdersBetween(start, end, branchId, companyId).size();
                    Map<String, Object> row = new HashMap<>();
                    row.put("date", date.toString());
                    row.put("orders", count);
                    return row;
                })
                .toList();
    }

    private List<Map<String, Object>> buildWeeklyCounts(Integer branchId, Integer companyId, int weeks, ZoneId zoneId,
            LocalDate today) {
        return java.util.stream.IntStream.range(0, weeks)
                .mapToObj(offset -> today.minusWeeks(weeks - 1L - offset))
                .map(weekStart -> {
                    LocalDate startDate = weekStart.with(java.time.DayOfWeek.MONDAY);
                    LocalDate endDate = startDate.plusDays(6);
                    LocalDateTime start = startDate.atStartOfDay();
                    LocalDateTime end = endDate.atTime(LocalTime.MAX);
                    long count = findOrdersBetween(start, end, branchId, companyId).size();
                    Map<String, Object> row = new HashMap<>();
                    row.put("week", startDate.get(IsoFields.WEEK_OF_WEEK_BASED_YEAR));
                    row.put("year", startDate.getYear());
                    row.put("startDate", startDate.toString());
                    row.put("endDate", endDate.toString());
                    row.put("orders", count);
                    return row;
                })
                .toList();
    }

    private List<Map<String, Object>> buildMonthlyCounts(Integer branchId, Integer companyId, int months, ZoneId zoneId,
            LocalDate today) {
        return java.util.stream.IntStream.range(0, months)
                .mapToObj(offset -> today.minusMonths(months - 1L - offset).withDayOfMonth(1))
                .map(firstDay -> {
                    LocalDate lastDay = firstDay.withDayOfMonth(firstDay.lengthOfMonth());
                    LocalDateTime start = firstDay.atStartOfDay();
                    LocalDateTime end = lastDay.atTime(LocalTime.MAX);
                    long count = findOrdersBetween(start, end, branchId, companyId).size();
                    Map<String, Object> row = new HashMap<>();
                    row.put("month", firstDay.getMonthValue());
                    row.put("year", firstDay.getYear());
                    row.put("orders", count);
                    row.put("label", firstDay.getMonth().toString());
                    return row;
                })
                .toList();
    }

    private List<Order> findOrdersBetween(LocalDateTime start, LocalDateTime end, Integer branchId, Integer companyId) {
        if (branchId != null) {
            return orderRepository.findByBranchIdAndCreatedAtBetween(branchId, start, end);
        }
        if (companyId != null) {
            return orderRepository.findByCompanyIdAndCreatedAtBetween(companyId, start, end);
        }
        return orderRepository.findAll().stream()
                .filter(order -> order.getCreatedAt() != null
                        && !order.getCreatedAt().isBefore(start)
                        && !order.getCreatedAt().isAfter(end))
                .toList();
    }

    // Lấy số đơn xử lý bởi nhân viên trong khoảng thời gian
    public Long getOrdersHandledByEmployee(Integer userId, Integer branchId, LocalDateTime start, LocalDateTime end) {
        return orderRepository.countByUserIdAndBranchIdAndCreatedAtBetween(userId, branchId, start, end);
    }

    // Lấy danh sách orders xử lý bởi nhân viên trong khoảng thời gian
    public List<Order> getOrdersByEmployee(Integer userId, Integer branchId, LocalDateTime start, LocalDateTime end) {
        return orderRepository.findByUserIdAndBranchIdAndCreatedAtBetween(userId, branchId, start, end);
    }
}
