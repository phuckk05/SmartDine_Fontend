package com.smartdine.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.smartdine.models.OrderItem;

public interface OrderItemRepository extends JpaRepository<OrderItem, Integer> {

    List<OrderItem> findByOrderIdIn(List<Integer> orderIds);

    @Query(value = """
            SELECT
                oi.id,
                oi.order_id,
                oi.item_id,
                oi.quantity,
                oi.note,
                oi.status_id,
                oi.added_by,
                oi.served_by,
                oi.created_at,
                i.name AS item_name,
                i.price AS item_price,
                o.table_id,
                t.name AS table_name,
                t.description AS table_code
            FROM order_items oi
            JOIN items i ON oi.item_id = i.id
            JOIN orders o ON oi.order_id = o.id
            LEFT JOIN tables t ON o.table_id = t.id
            WHERE oi.order_id IN (:orderIds)
            ORDER BY oi.created_at ASC
            """, nativeQuery = true)
    List<Object[]> findDetailedByOrderIds(@Param("orderIds") List<Integer> orderIds);

    @Query(value = """
            SELECT
                oi.id,
                oi.order_id,
                oi.item_id,
                oi.quantity,
                oi.note,
                oi.status_id,
                oi.added_by,
                oi.served_by,
                oi.created_at,
                i.name AS item_name,
                i.price AS item_price,
                o.table_id,
                t.name AS table_name,
                t.description AS table_code
            FROM order_items oi
            JOIN items i ON oi.item_id = i.id
            JOIN orders o ON oi.order_id = o.id
            LEFT JOIN tables t ON o.table_id = t.id
            WHERE oi.id = :id
            LIMIT 1
            """, nativeQuery = true)
    Object[] findDetailedById(@Param("id") Integer id);
}