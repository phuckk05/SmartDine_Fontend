package com.smartdine.services;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.YearMonth;
import java.util.List;

import org.springframework.stereotype.Service;

import com.smartdine.models.Payment;
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

    // PHƯƠNG THỨC MỚI: Lấy doanh thu theo khoảng thời gian (period)
    public BigDecimal getRevenueByPeriod(Integer branchId, LocalDate startDate, LocalDate endDate) {
        if (branchId == null) {
            throw new IllegalArgumentException("branchId must not be null");
        }
        if (startDate == null) {
            throw new IllegalArgumentException("startDate must not be null");
        }
        if (endDate == null) {
            throw new IllegalArgumentException("endDate must not be null");
        }
        if (startDate.isAfter(endDate)) {
            throw new IllegalArgumentException("startDate must not be after endDate");
        }

        LocalDateTime start = startDate.atStartOfDay();
        LocalDateTime end = endDate.atTime(LocalTime.MAX);
        return sumWithinRange(start, end, branchId, null);
    }

    // Tạo payment mới
    public Payment createPayment(Payment payment) {
        if (payment.getOrderId() == null) {
            throw new IllegalArgumentException("orderId must not be null");
        }
        if (payment.getCashierId() == null) {
            throw new IllegalArgumentException("cashierId must not be null");
        }
        if (payment.getCompanyId() == null) {
            throw new IllegalArgumentException("companyId must not be null");
        }
        if (payment.getBranchId() == null) {
            throw new IllegalArgumentException("branchId must not be null");
        }
        if (payment.getTotalAmount() == null) {
            throw new IllegalArgumentException("totalAmount must not be null");
        }
        if (payment.getFinalAmount() == null) {
            throw new IllegalArgumentException("finalAmount must not be null");
        }
        if (payment.getStatusId() == null) {
            throw new IllegalArgumentException("statusId must not be null");
        }

        return paymentRepository.save(payment);
    }

    // Lấy payments theo orderId
    public List<Payment> getPaymentsByOrderId(Integer orderId) {
        if (orderId == null) {
            throw new IllegalArgumentException("orderId must not be null");
        }
        return paymentRepository.findByOrderId(orderId);
    }

    // Lấy payments theo branchId hôm nay
    public List<Payment> getPaymentsByBranchToday(Integer branchId) {
        if (branchId == null) {
            throw new IllegalArgumentException("branchId must not be null");
        }
        return paymentRepository.findByBranchIdAndToday(branchId);
    }

    // Tính tổng doanh thu theo cashierId và branchId trong khoảng thời gian
    public BigDecimal getRevenueByCashierAndBranch(Integer cashierId, Integer branchId, LocalDateTime start, LocalDateTime end) {
        if (cashierId == null) {
            throw new IllegalArgumentException("cashierId must not be null");
        }
        if (branchId == null) {
            throw new IllegalArgumentException("branchId must not be null");
        }
        return paymentRepository.sumFinalAmountByCashierAndBranchBetween(cashierId, branchId, start, end);
    }
}
