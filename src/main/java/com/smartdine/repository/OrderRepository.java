package com.smartdine.repository;

import java.time.LocalDateTime;
import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

import com.smartdine.models.Order;

public interface OrderRepository extends JpaRepository<Order, Integer> {
    // Lấy danh sách order theo tableId
    List<Order> findByTableId(Integer tableId);

    // Lấy danh sách order theo branchId
    List<Order> findByBranchId(Integer branchId);

    // Lấy danh sách order by tableId ngay hôm nay
    List<Order> findByTableIdAndCreatedAtBetween(Integer tableId, LocalDateTime startOfDay, LocalDateTime endOfDay);

    // Lấy danh sách tableId đã có order chưa thanh toán ngay hôm nay
    List<Integer> findDistinctTableIdByStatusIdNotAndCreatedAtBetween(Integer statusId, LocalDateTime startOfDay,
            LocalDateTime endOfDay);
}
