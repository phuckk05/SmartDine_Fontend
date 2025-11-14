package com.smartdine.controllers;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.smartdine.models.Payment;
import com.smartdine.services.PaymentService;

@RestController
@RequestMapping("/api/payments")
public class PaymentController {

    private final PaymentService paymentService;

    public PaymentController(PaymentService paymentService) {
        this.paymentService = paymentService;
    }

    // Lấy doanh thu theo tuần theo chi nhánh/công ty (tùy chọn)
    @GetMapping("/revenue/week")
    public ResponseEntity<BigDecimal> getRevenueByWeek(
            @RequestParam("week") int week,
            @RequestParam("year") int year,
            @RequestParam(value = "branchId", required = false) Integer branchId,
            @RequestParam(value = "companyId", required = false) Integer companyId) {

        BigDecimal revenue = paymentService.getRevenueByWeek(week, year, branchId, companyId);
        return ResponseEntity.ok(revenue);
    }

    // Doanh thu theo ngày
    @GetMapping("/revenue/day")
    public ResponseEntity<BigDecimal> getRevenueByDay(
            @RequestParam("date") @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date,
            @RequestParam(value = "branchId", required = false) Integer branchId,
            @RequestParam(value = "companyId", required = false) Integer companyId) {

        BigDecimal revenue = paymentService.getRevenueByDay(date, branchId, companyId);
        return ResponseEntity.ok(revenue);
    }

    // Doanh thu theo tháng
    @GetMapping("/revenue/month")
    public ResponseEntity<BigDecimal> getRevenueByMonth(
            @RequestParam("year") int year,
            @RequestParam("month") int month,
            @RequestParam(value = "branchId", required = false) Integer branchId,
            @RequestParam(value = "companyId", required = false) Integer companyId) {

        BigDecimal revenue = paymentService.getRevenueByMonth(year, month, branchId, companyId);
        return ResponseEntity.ok(revenue);
    }

    // Doanh thu theo năm
    @GetMapping("/revenue/year")
    public ResponseEntity<BigDecimal> getRevenueByYear(
            @RequestParam("year") int year,
            @RequestParam(value = "branchId", required = false) Integer branchId,
            @RequestParam(value = "companyId", required = false) Integer companyId) {

        BigDecimal revenue = paymentService.getRevenueByYear(year, branchId, companyId);
        return ResponseEntity.ok(revenue);
    }

    // Get Revenue Trends theo spec - đơn giản hơn
    @GetMapping("/revenue/trends")
    public ResponseEntity<?> getRevenueTrendsSimple(
            @RequestParam("branchId") Integer branchId,
            @RequestParam("period") String period,
            @RequestParam(value = "days", defaultValue = "7") int days) {

        try {
            List<Map<String, Object>> trends = new ArrayList<>();
            LocalDate endDate = LocalDate.now();
            LocalDate startDate;

            switch (period.toLowerCase()) {
                case "day":
                case "daily":
                    startDate = endDate.minusDays(days - 1);
                    LocalDate currentDay = startDate;
                    while (!currentDay.isAfter(endDate)) {
                        BigDecimal revenue = paymentService.getRevenueByDay(currentDay, branchId, null);
                        Map<String, Object> dayData = new HashMap<>();
                        dayData.put("date", currentDay.toString());
                        dayData.put("revenue", revenue != null ? revenue.doubleValue() : 0.0);
                        dayData.put("orders", 25); // Mock data - should get from OrderService
                        trends.add(dayData);
                        currentDay = currentDay.plusDays(1);
                    }
                    break;

                case "week":
                case "weekly":
                    startDate = endDate.minusWeeks(days);
                    LocalDate currentWeek = startDate;
                    while (!currentWeek.isAfter(endDate)) {
                        int weekOfYear = currentWeek.get(java.time.temporal.IsoFields.WEEK_OF_WEEK_BASED_YEAR);
                        int year = currentWeek.getYear();
                        BigDecimal revenue = paymentService.getRevenueByWeek(weekOfYear, year, branchId, null);
                        Map<String, Object> weekData = new HashMap<>();
                        weekData.put("date", currentWeek.toString());
                        weekData.put("revenue", revenue != null ? revenue.doubleValue() : 0.0);
                        weekData.put("orders", 150); // Mock data
                        trends.add(weekData);
                        currentWeek = currentWeek.plusWeeks(1);
                    }
                    break;

                case "month":
                case "monthly":
                    startDate = endDate.minusMonths(days);
                    LocalDate currentMonth = startDate.withDayOfMonth(1);
                    while (!currentMonth.isAfter(endDate)) {
                        BigDecimal revenue = paymentService.getRevenueByMonth(currentMonth.getYear(),
                                currentMonth.getMonthValue(), branchId, null);
                        Map<String, Object> monthData = new HashMap<>();
                        monthData.put("date", currentMonth.toString());
                        monthData.put("revenue", revenue != null ? revenue.doubleValue() : 0.0);
                        monthData.put("orders", 650); // Mock data
                        trends.add(monthData);
                        currentMonth = currentMonth.plusMonths(1);
                    }
                    break;

                case "year":
                case "yearly":
                    startDate = endDate.minusYears(days);
                    LocalDate currentYear = startDate.withDayOfYear(1);
                    while (!currentYear.isAfter(endDate)) {
                        BigDecimal revenue = paymentService.getRevenueByYear(currentYear.getYear(), branchId, null);
                        Map<String, Object> yearData = new HashMap<>();
                        yearData.put("date", currentYear.toString());
                        yearData.put("revenue", revenue != null ? revenue.doubleValue() : 0.0);
                        yearData.put("orders", 7800); // Mock data
                        trends.add(yearData);
                        currentYear = currentYear.plusYears(1);
                    }
                    break;

                default:
                    return ResponseEntity.badRequest().body("Period không hợp lệ. Sử dụng: day, week, month, year");
            }

            return ResponseEntity.ok(trends);
        } catch (Exception ex) {
            return ResponseEntity.internalServerError().body("Lỗi " + ex.getMessage());
        }
    }

    // Xu hướng doanh thu theo kỳ - version cũ
    @GetMapping("/revenue/trends/{period}")
    public ResponseEntity<?> getRevenueTrends(
            @PathVariable String period,
            @RequestParam("startDate") @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam("endDate") @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate,
            @RequestParam(value = "branchId", required = false) Integer branchId,
            @RequestParam(value = "companyId", required = false) Integer companyId) {

        try {
            List<Map<String, Object>> trends = new ArrayList<>();

            switch (period.toLowerCase()) {
                case "daily":
                    // Xu hướng theo ngày
                    LocalDate current = startDate;
                    while (!current.isAfter(endDate)) {
                        BigDecimal revenue = paymentService.getRevenueByDay(current, branchId, companyId);
                        Map<String, Object> trendData = new HashMap<>();
                        trendData.put("date", current.toString());
                        trendData.put("revenue", revenue);
                        trends.add(trendData);
                        current = current.plusDays(1);
                    }
                    break;

                case "weekly":
                    // Xu hướng theo tuần
                    LocalDate weekStart = startDate;
                    while (!weekStart.isAfter(endDate)) {
                        int weekOfYear = weekStart.get(java.time.temporal.IsoFields.WEEK_OF_WEEK_BASED_YEAR);
                        int year = weekStart.getYear();
                        BigDecimal revenue = paymentService.getRevenueByWeek(weekOfYear, year, branchId, companyId);
                        Map<String, Object> trendData = new HashMap<>();
                        trendData.put("week", weekOfYear);
                        trendData.put("year", year);
                        trendData.put("weekStart", weekStart.toString());
                        trendData.put("revenue", revenue);
                        trends.add(trendData);
                        weekStart = weekStart.plusWeeks(1);
                    }
                    break;

                case "monthly":
                    // Xu hướng theo tháng
                    LocalDate monthStart = startDate.withDayOfMonth(1);
                    while (!monthStart.isAfter(endDate)) {
                        BigDecimal revenue = paymentService.getRevenueByMonth(monthStart.getYear(),
                                monthStart.getMonthValue(), branchId, companyId);
                        Map<String, Object> trendData = new HashMap<>();
                        trendData.put("month", monthStart.getMonthValue());
                        trendData.put("year", monthStart.getYear());
                        trendData.put("monthName", monthStart.getMonth().toString());
                        trendData.put("revenue", revenue);
                        trends.add(trendData);
                        monthStart = monthStart.plusMonths(1);
                    }
                    break;

                default:
                    return ResponseEntity.badRequest().body("Period không hợp lệ. Sử dụng: daily, weekly, monthly");
            }

            return ResponseEntity.ok(trends);
        } catch (Exception ex) {
            return ResponseEntity.internalServerError().body("Lỗi " + ex.getMessage());
        }
    }

    // So sánh doanh thu với kỳ trước
    @GetMapping("/revenue/compare/{period}")
    public ResponseEntity<?> compareRevenue(
            @PathVariable String period,
            @RequestParam("currentDate") @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate currentDate,
            @RequestParam(value = "branchId", required = false) Integer branchId,
            @RequestParam(value = "companyId", required = false) Integer companyId) {

        try {
            BigDecimal currentRevenue = BigDecimal.ZERO;
            BigDecimal previousRevenue = BigDecimal.ZERO;
            String currentPeriodName = "";
            String previousPeriodName = "";

            switch (period.toLowerCase()) {
                case "day":
                    currentRevenue = paymentService.getRevenueByDay(currentDate, branchId, companyId);
                    previousRevenue = paymentService.getRevenueByDay(currentDate.minusDays(1), branchId, companyId);
                    currentPeriodName = currentDate.toString();
                    previousPeriodName = currentDate.minusDays(1).toString();
                    break;

                case "week":
                    int currentWeek = currentDate.get(java.time.temporal.IsoFields.WEEK_OF_WEEK_BASED_YEAR);
                    int currentYear = currentDate.getYear();
                    currentRevenue = paymentService.getRevenueByWeek(currentWeek, currentYear, branchId, companyId);

                    LocalDate previousWeekDate = currentDate.minusWeeks(1);
                    int previousWeek = previousWeekDate.get(java.time.temporal.IsoFields.WEEK_OF_WEEK_BASED_YEAR);
                    int previousYear = previousWeekDate.getYear();
                    previousRevenue = paymentService.getRevenueByWeek(previousWeek, previousYear, branchId, companyId);

                    currentPeriodName = "Tuần " + currentWeek + "/" + currentYear;
                    previousPeriodName = "Tuần " + previousWeek + "/" + previousYear;
                    break;

                case "month":
                    currentRevenue = paymentService.getRevenueByMonth(currentDate.getYear(),
                            currentDate.getMonthValue(), branchId, companyId);
                    LocalDate previousMonth = currentDate.minusMonths(1);
                    previousRevenue = paymentService.getRevenueByMonth(previousMonth.getYear(),
                            previousMonth.getMonthValue(), branchId, companyId);

                    currentPeriodName = "Tháng " + currentDate.getMonthValue() + "/" + currentDate.getYear();
                    previousPeriodName = "Tháng " + previousMonth.getMonthValue() + "/" + previousMonth.getYear();
                    break;

                default:
                    return ResponseEntity.badRequest().body("Period không hợp lệ. Sử dụng: day, week, month");
            }

            // Tính phần trăm thay đổi
            BigDecimal changeAmount = currentRevenue.subtract(previousRevenue);
            BigDecimal changePercent = BigDecimal.ZERO;
            if (previousRevenue.compareTo(BigDecimal.ZERO) > 0) {
                changePercent = changeAmount.divide(previousRevenue, 4, java.math.RoundingMode.HALF_UP)
                        .multiply(BigDecimal.valueOf(100));
            }

            Map<String, Object> comparison = new HashMap<>();
            comparison.put("currentPeriod", currentPeriodName);
            comparison.put("currentRevenue", currentRevenue);
            comparison.put("previousPeriod", previousPeriodName);
            comparison.put("previousRevenue", previousRevenue);
            comparison.put("changeAmount", changeAmount);
            comparison.put("changePercent", changePercent);
            comparison.put("isIncrease", changeAmount.compareTo(BigDecimal.ZERO) >= 0);

            return ResponseEntity.ok(comparison);
        } catch (Exception ex) {
            return ResponseEntity.internalServerError().body("Lỗi " + ex.getMessage());
        }
    }

    // So sánh doanh thu giữa các chi nhánh
    @GetMapping("/revenue/branch-comparison")
    public ResponseEntity<?> compareBranchRevenue(
            @RequestParam("startDate") @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam("endDate") @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate,
            @RequestParam("branchIds") List<Integer> branchIds,
            @RequestParam(value = "companyId", required = false) Integer companyId) {

        try {
            List<Map<String, Object>> branchComparison = new ArrayList<>();

            for (Integer branchId : branchIds) {
                BigDecimal totalRevenue = BigDecimal.ZERO;
                LocalDate current = startDate;

                // Tính tổng doanh thu trong khoảng thời gian
                while (!current.isAfter(endDate)) {
                    BigDecimal dailyRevenue = paymentService.getRevenueByDay(current, branchId, companyId);
                    totalRevenue = totalRevenue.add(dailyRevenue != null ? dailyRevenue : BigDecimal.ZERO);
                    current = current.plusDays(1);
                }

                Map<String, Object> branchData = new HashMap<>();
                branchData.put("branchId", branchId);
                branchData.put("totalRevenue", totalRevenue);
                branchData.put("startDate", startDate.toString());
                branchData.put("endDate", endDate.toString());

                branchComparison.add(branchData);
            }

            // Sắp xếp theo doanh thu giảm dần
            branchComparison.sort((a, b) -> {
                BigDecimal revenueA = (BigDecimal) a.get("totalRevenue");
                BigDecimal revenueB = (BigDecimal) b.get("totalRevenue");
                return revenueB.compareTo(revenueA);
            });

            return ResponseEntity.ok(branchComparison);
        } catch (Exception ex) {
            return ResponseEntity.internalServerError().body("Lỗi " + ex.getMessage());
        }
    }

    // Tạo payment mới
    @PostMapping
    public ResponseEntity<?> createPayment(@RequestBody Payment payment) {
        try {
            Payment createdPayment = paymentService.createPayment(payment);
            return ResponseEntity.ok(Map.of("payment", createdPayment));
        } catch (Exception ex) {
            return ResponseEntity.badRequest().body("Lỗi tạo payment: " + ex.getMessage());
        }
    }

    // Lấy payments theo orderId
    @GetMapping("/order/{orderId}")
    public ResponseEntity<?> getPaymentsByOrderId(@PathVariable Integer orderId) {
        try {
            List<Payment> payments = paymentService.getPaymentsByOrderId(orderId);
            return ResponseEntity.ok(payments);
        } catch (Exception ex) {
            return ResponseEntity.badRequest().body("Lỗi lấy payments: " + ex.getMessage());
        }
    }

    // Lấy payments theo branchId hôm nay
    @GetMapping("/branch/{branchId}/today")
    public ResponseEntity<?> getPaymentsByBranchToday(@PathVariable Integer branchId) {
        try {
            List<Payment> payments = paymentService.getPaymentsByBranchToday(branchId);
            return ResponseEntity.ok(payments);
        } catch (Exception ex) {
            return ResponseEntity.badRequest().body("Lỗi lấy payments: " + ex.getMessage());
        }
    }
}
