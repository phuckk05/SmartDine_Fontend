package com.smartdine.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import com.smartdine.models.OrderItem;

public interface OrderItemRepository extends JpaRepository<OrderItem, Integer> {

    List<OrderItem> findByOrderIdIn(List<Integer> orderIds);

    @Query("""
            SELECT DISTINCT oi FROM OrderItem oi
            LEFT JOIN FETCH oi.item
            LEFT JOIN FETCH oi.order ord
            LEFT JOIN FETCH ord.table
            WHERE oi.orderId IN :orderIds
            ORDER BY oi.createdAt ASC
            """)
    List<OrderItem> findDetailedByOrderIds(@Param("orderIds") List<Integer> orderIds);

    @Query("""
            SELECT oi FROM OrderItem oi
            LEFT JOIN FETCH oi.item
            LEFT JOIN FETCH oi.order ord
            LEFT JOIN FETCH ord.table
            WHERE oi.id = :id
            """)
    OrderItem findDetailedById(@Param("id") Integer id);
}