package com.smartdine.services;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.YearMonth;

import org.springframework.stereotype.Service;

import com.smartdine.repository.PaymentRepository;

@Service
public class PaymentService {

    private final PaymentRepository paymentRepository;

    public PaymentService(PaymentRepository paymentRepository) {
        this.paymentRepository = paymentRepository;
    }

    // Thống kê doanh thu theo tuần dựa trên bảng payments
    public BigDecimal getRevenueByWeek(int isoWeek, int year, Integer branchId, Integer companyId) {
        if (isoWeek < 1 || isoWeek > 53) {
            throw new IllegalArgumentException("isoWeek must be between 1 and 53");
        }

        return paymentRepository.sumFinalAmountByWeek(isoWeek, year, branchId, companyId);
    }

    // Doanh thu theo ngày cụ thể
    public BigDecimal getRevenueByDay(LocalDate date, Integer branchId, Integer companyId) {
        if (date == null) {
            throw new IllegalArgumentException("date must not be null");
        }

        LocalDateTime start = date.atStartOfDay();
        LocalDateTime end = date.atTime(LocalTime.MAX);
        return sumWithinRange(start, end, branchId, companyId);
    }

    // Doanh thu theo tháng
    public BigDecimal getRevenueByMonth(int year, int month, Integer branchId, Integer companyId) {
        YearMonth yearMonth = YearMonth.of(year, month);
        LocalDateTime start = yearMonth.atDay(1).atStartOfDay();
        LocalDateTime end = yearMonth.atEndOfMonth().atTime(LocalTime.MAX);
        return sumWithinRange(start, end, branchId, companyId);
    }

    // Doanh thu theo năm
    public BigDecimal getRevenueByYear(int year, Integer branchId, Integer companyId) {
        LocalDate startDate = LocalDate.of(year, 1, 1);
        LocalDate endDate = LocalDate.of(year, 12, 31);
        LocalDateTime start = startDate.atStartOfDay();
        LocalDateTime end = endDate.atTime(LocalTime.MAX);
        return sumWithinRange(start, end, branchId, companyId);
    }

    private BigDecimal sumWithinRange(
            LocalDateTime start,
            LocalDateTime end,
            Integer branchId,
            Integer companyId) {
        return paymentRepository.sumFinalAmountBetween(start, end, branchId, companyId);
    }
}
