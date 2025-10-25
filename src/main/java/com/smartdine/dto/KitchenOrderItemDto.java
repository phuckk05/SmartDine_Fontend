package com.smartdine.dto;

import java.math.BigDecimal;
import java.time.LocalDateTime;

import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.annotation.JsonProperty;

@JsonInclude(JsonInclude.Include.NON_NULL)
public class KitchenOrderItemDto {

    private Integer id;

    @JsonProperty("order_id")
    private Integer orderId;

    @JsonProperty("item_id")
    private Integer itemId;

    private Integer quantity;

    private String note;

    @JsonProperty("status_id")
    private Integer statusId;

    @JsonProperty("added_by")
    private Integer addedBy;

    @JsonProperty("served_by")
    private Integer servedBy;

    @JsonProperty("created_at")
    private LocalDateTime createdAt;

    @JsonProperty("item_name")
    private String itemName;

    @JsonProperty("item_price")
    private BigDecimal itemPrice;

    @JsonProperty("table_id")
    private Integer tableId;

    @JsonProperty("table_name")
    private String tableName;

    @JsonProperty("table_code")
    private String tableCode;

    private ItemSummary item;

    private OrderSummary order;

    public KitchenOrderItemDto() {
    }

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public Integer getOrderId() {
        return orderId;
    }

    public void setOrderId(Integer orderId) {
        this.orderId = orderId;
    }

    public Integer getItemId() {
        return itemId;
    }

    public void setItemId(Integer itemId) {
        this.itemId = itemId;
    }

    public Integer getQuantity() {
        return quantity;
    }

    public void setQuantity(Integer quantity) {
        this.quantity = quantity;
    }

    public String getNote() {
        return note;
    }

    public void setNote(String note) {
        this.note = note;
    }

    public Integer getStatusId() {
        return statusId;
    }

    public void setStatusId(Integer statusId) {
        this.statusId = statusId;
    }

    public Integer getAddedBy() {
        return addedBy;
    }

    public void setAddedBy(Integer addedBy) {
        this.addedBy = addedBy;
    }

    public Integer getServedBy() {
        return servedBy;
    }

    public void setServedBy(Integer servedBy) {
        this.servedBy = servedBy;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public String getItemName() {
        return itemName;
    }

    public void setItemName(String itemName) {
        this.itemName = itemName;
    }

    public BigDecimal getItemPrice() {
        return itemPrice;
    }

    public void setItemPrice(BigDecimal itemPrice) {
        this.itemPrice = itemPrice;
    }

    public Integer getTableId() {
        return tableId;
    }

    public void setTableId(Integer tableId) {
        this.tableId = tableId;
    }

    public String getTableName() {
        return tableName;
    }

    public void setTableName(String tableName) {
        this.tableName = tableName;
    }

    public String getTableCode() {
        return tableCode;
    }

    public void setTableCode(String tableCode) {
        this.tableCode = tableCode;
    }

    public ItemSummary getItem() {
        return item;
    }

    public void setItem(ItemSummary item) {
        this.item = item;
    }

    public OrderSummary getOrder() {
        return order;
    }

    public void setOrder(OrderSummary order) {
        this.order = order;
    }

    public static class ItemSummary {
        private Integer id;
        private String name;
        private BigDecimal price;

        public ItemSummary() {
        }

        public ItemSummary(Integer id, String name, BigDecimal price) {
            this.id = id;
            this.name = name;
            this.price = price;
        }

        public Integer getId() {
            return id;
        }

        public void setId(Integer id) {
            this.id = id;
        }

        public String getName() {
            return name;
        }

        public void setName(String name) {
            this.name = name;
        }

        public BigDecimal getPrice() {
            return price;
        }

        public void setPrice(BigDecimal price) {
            this.price = price;
        }
    }

    public static class OrderSummary {
        private Integer id;

        @JsonProperty("table_id")
        private Integer tableId;

        @JsonProperty("table_name")
        private String tableName;

        public OrderSummary() {
        }

        public OrderSummary(Integer id, Integer tableId, String tableName) {
            this.id = id;
            this.tableId = tableId;
            this.tableName = tableName;
        }

        public Integer getId() {
            return id;
        }

        public void setId(Integer id) {
            this.id = id;
        }

        public Integer getTableId() {
            return tableId;
        }

        public void setTableId(Integer tableId) {
            this.tableId = tableId;
        }

        public String getTableName() {
            return tableName;
        }

        public void setTableName(String tableName) {
            this.tableName = tableName;
        }
    }
}
