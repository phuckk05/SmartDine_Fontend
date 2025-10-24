package com.smartdine.controllers;

import java.math.BigDecimal;
import java.time.LocalDate;

import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

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
}
