package com.smartdine.services;

import java.math.BigDecimal;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.smartdine.dto.KitchenOrderItemDto;
import com.smartdine.models.OrderItem;
import com.smartdine.repository.OrderItemRepository;

@Service
public class OrderItemService {
    @Autowired
    private OrderItemRepository orderItemRepository;

    // Lấy danh sách OrderItem theo các orderId kèm thông tin món và bàn
    public List<KitchenOrderItemDto> getOrderItemsByOrderIds(List<Integer> orderIds) {
        if (orderIds == null || orderIds.isEmpty()) {
            return List.of();
        }
        Set<Integer> uniqueIds = new LinkedHashSet<>(orderIds);
        List<Object[]> rows = orderItemRepository.findDetailedByOrderIds(List.copyOf(uniqueIds));
        List<KitchenOrderItemDto> results = new ArrayList<>();
        for (Object[] row : rows) {
            results.add(mapRowToDto(row));
        }
        return results;
    }

    // Cap̉̀ nhật trạng thái của order item
    public KitchenOrderItemDto updateOrderItemStatus(Integer id, Integer statusId) {
        OrderItem orderItem = orderItemRepository.findById(id).orElse(null);
        if (orderItem == null) {
            throw new IllegalArgumentException("OrderItem not found with id: " + id);
        }
        orderItem.setStatusId(statusId);
        orderItemRepository.save(orderItem);
        return getDetailedById(id);
    }

    // Cập nhật người đã phục vụ món lên
    public KitchenOrderItemDto updateServedBy(Integer id, Integer servedBy) {
        OrderItem orderItem = orderItemRepository.findById(id).orElse(null);
        if (orderItem == null) {
            throw new IllegalArgumentException("OrderItem not found with id: " + id);
        }
        orderItem.setServedBy(servedBy);
        orderItemRepository.save(orderItem);
        return getDetailedById(id);
    }

    private KitchenOrderItemDto getDetailedById(Integer id) {
        Object[] row = orderItemRepository.findDetailedById(id);
        if (row == null) {
            throw new IllegalArgumentException("OrderItem not found with id: " + id);
        }
        return mapRowToDto(row);
    }

    private KitchenOrderItemDto mapRowToDto(Object[] row) {
        int index = 0;
        KitchenOrderItemDto dto = new KitchenOrderItemDto();
        dto.setId(asInteger(row[index++]));
        Integer orderId = asInteger(row[index++]);
        dto.setOrderId(orderId);
        Integer itemId = asInteger(row[index++]);
        dto.setItemId(itemId);
        dto.setQuantity(asInteger(row[index++]));
        dto.setNote(asString(row[index++]));
        dto.setStatusId(asInteger(row[index++]));
        dto.setAddedBy(asInteger(row[index++]));
        dto.setServedBy(asInteger(row[index++]));
        dto.setCreatedAt(asDateTime(row[index++]));
        String itemName = asString(row[index++]);
        dto.setItemName(itemName);
        BigDecimal itemPrice = asBigDecimal(row[index++]);
        dto.setItemPrice(itemPrice);
        Integer tableId = asInteger(row[index++]);
        dto.setTableId(tableId);
        String tableName = asString(row[index++]);
        dto.setTableName(tableName);
        String tableCode = asString(row[index++]);
        dto.setTableCode(tableCode);

        KitchenOrderItemDto.ItemSummary itemSummary = new KitchenOrderItemDto.ItemSummary(itemId, itemName, itemPrice);
        dto.setItem(itemSummary);

        KitchenOrderItemDto.OrderSummary orderSummary = new KitchenOrderItemDto.OrderSummary(orderId, tableId,
                tableName);
        dto.setOrder(orderSummary);

        return dto;
    }

    private static Integer asInteger(Object value) {
        if (value == null) {
            return null;
        }
        if (value instanceof Integer integer) {
            return integer;
        }
        if (value instanceof Number number) {
            return number.intValue();
        }
        return Integer.valueOf(value.toString());
    }

    private static String asString(Object value) {
        return value == null ? null : value.toString();
    }

    private static LocalDateTime asDateTime(Object value) {
        if (value == null) {
            return null;
        }
        if (value instanceof LocalDateTime dateTime) {
            return dateTime;
        }
        if (value instanceof Timestamp timestamp) {
            return timestamp.toLocalDateTime();
        }
        return LocalDateTime.parse(value.toString());
    }

    private static BigDecimal asBigDecimal(Object value) {
        if (value == null) {
            return null;
        }
        if (value instanceof BigDecimal bigDecimal) {
            return bigDecimal;
        }
        if (value instanceof Number number) {
            return BigDecimal.valueOf(number.doubleValue());
        }
        return new BigDecimal(value.toString());
    }
}