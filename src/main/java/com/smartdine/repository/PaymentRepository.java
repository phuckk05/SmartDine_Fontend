package com.smartdine.repository;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.smartdine.models.Payment;

public interface PaymentRepository extends JpaRepository<Payment, Integer> {

        @Query(value = """
                            SELECT COALESCE(SUM(p.final_amount), 0)
                            FROM payments p
                            WHERE (:branchId IS NULL OR p.branch_id = :branchId)
                              AND (:companyId IS NULL OR p.company_id = :companyId)
                              AND DATE_PART('week', p.created_at) = :week
                              AND DATE_PART('year', p.created_at) = :year
                        """, nativeQuery = true)
        BigDecimal sumFinalAmountByWeek(
                        @Param("week") int week,
                        @Param("year") int year,
                        @Param("branchId") Integer branchId,
                        @Param("companyId") Integer companyId);

        @Query("""
                        SELECT COALESCE(SUM(p.finalAmount), 0)
                        FROM Payment p
                        WHERE (:branchId IS NULL OR p.branchId = :branchId)
                          AND (:companyId IS NULL OR p.companyId = :companyId)
                          AND p.createdAt BETWEEN :start AND :end
                        """)
        BigDecimal sumFinalAmountBetween(
                        @Param("start") LocalDateTime start,
                        @Param("end") LocalDateTime end,
                        @Param("branchId") Integer branchId,
                        @Param("companyId") Integer companyId);

        // Tìm payments theo orderId
        List<Payment> findByOrderId(Integer orderId);

        // Tìm payments theo branchId và ngày hôm nay
        @Query(value = """
                        SELECT * FROM payments p
                        WHERE p.branch_id = :branchId
                                AND DATE(p.created_at) = CURRENT_DATE
                        """, nativeQuery = true)
        List<Payment> findByBranchIdAndToday(@Param("branchId") Integer branchId);
}
