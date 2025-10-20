// File: mart_dine/models/table.dart

import 'package:flutter/material.dart'; // Import Material cho Color (nếu cần dùng Color trong model)
import 'package:mart_dine/models/menu.dart'; // Đảm bảo đã import MenuItemModel

// Enum trạng thái bàn
enum TableStatus {
  available, // trống
  reserved, // đã đặt trước
  serving, // đang phục vụ
}

// ✅ Thêm Enum cho khu vực bàn
enum TableZone {
  all, // Mới: Để đại diện cho "Tất cả" trong bộ lọc
  vip,
  quiet, // Yên tĩnh
  indoor, // Trong nhà
  outdoor, // Ngoài trời
}

class TableModel {
  final String id;
  final String name;
  final int seats;
  final TableStatus status;
  final int? customerCount;
  final double totalAmount;
  final List<MenuItemModel> existingItems;
  final TableZone zone; // ✅ Thêm thuộc tính khu vực

  TableModel({
    required this.id,
    required this.name,
    required this.seats,
    this.status = TableStatus.available,
    this.customerCount,
    this.totalAmount = 0.0,
    this.existingItems = const [],
    this.zone = TableZone.indoor, 
  });

  TableModel copyWith({ 
    String? id,
    String? name,
    int? seats,
    TableStatus? status,
    int? customerCount,
    double? totalAmount,
    List<MenuItemModel>? existingItems,
    TableZone? zone, 
  }) {
    return TableModel(
      id: id ?? this.id,
      name: name ?? this.name,
      seats: seats ?? this.seats,
      status: status ?? this.status,
      customerCount: customerCount ?? this.customerCount,
      totalAmount: totalAmount ?? this.totalAmount,
      existingItems: existingItems ?? this.existingItems,
      zone: zone ?? this.zone, 
    );
  }
}