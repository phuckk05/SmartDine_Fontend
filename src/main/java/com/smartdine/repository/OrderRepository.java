package com.smartdine.repository;

import java.time.LocalDateTime;
import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.smartdine.models.Order;

public interface OrderRepository extends JpaRepository<Order, Integer> {
    // Lấy danh sách order theo tableId
    List<Order> findByTableId(Integer tableId);

    // Lấy danh sách order theo branchId
    List<Order> findByBranchId(Integer branchId);

    // Lấy danh sách order by tableId ngay hôm nay
    List<Order> findByTableIdAndCreatedAtBetween(Integer tableId, LocalDateTime startOfDay, LocalDateTime endOfDay);

    // Lấy danh sách order theo branchId trong khoảng thời gian
    List<Order> findByBranchIdAndCreatedAtBetween(Integer branchId, LocalDateTime startOfDay, LocalDateTime endOfDay);

    // Lấy danh sách tableId đã có order với statusId cụ thể ngay hôm nay by
    // branchId
    @Query("SELECT DISTINCT o.tableId FROM Order o WHERE o.statusId = :statusId AND o.createdAt BETWEEN :startOfDay AND :endOfDay AND o.branchId = :branchId")
    List<Integer> findDistinctTableIdByStatusIdAndCreatedAtBetweenAndBranchId(
            @Param("statusId") Integer statusId,
            @Param("startOfDay") LocalDateTime startOfDay,
            @Param("endOfDay") LocalDateTime endOfDay,
            @Param("branchId") Integer branchId);

    // Lấy danh sách order chưa thanh toán ngay hôm nay by branchId , statusId = 2
    @Query("SELECT o FROM Order o WHERE o.statusId = :statusId AND o.createdAt BETWEEN :startOfDay AND :endOfDay AND o.branchId = :branchId")
    List<Order> findUnpaidOrdersTodayByBranchId(
            @Param("branchId") Integer branchId,
            @Param("statusId") Integer statusId,
            @Param("startOfDay") LocalDateTime startOfDay,
            @Param("endOfDay") LocalDateTime endOfDay);

}
