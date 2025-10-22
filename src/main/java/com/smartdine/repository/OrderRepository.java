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

    // Lấy danh sách tableId đã có order với statusId cụ thể ngay hôm nay
    @Query("SELECT DISTINCT o.tableId FROM orders o WHERE o.statusId = :statusId AND o.createdAt BETWEEN :startOfDay AND :endOfDay")
    List<Integer> findDistinctTableIdByStatusIdAndCreatedAtBetween(
            @Param("statusId") Integer statusId,
            @Param("startOfDay") LocalDateTime startOfDay,
            @Param("endOfDay") LocalDateTime endOfDay);
}
