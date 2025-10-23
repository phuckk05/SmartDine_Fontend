// File: mart_dine/models/table.dart

import 'package:flutter/material.dart'; 
import 'package:mart_dine/models/menu.dart'; // Đảm bảo đã import MenuItemModel

// Enum trạng thái bàn (KHÔNG THAY ĐỔI)
enum TableStatus {
  available, // trống
  reserved, // đã đặt trước
  serving, // đang phục vụ
}

// Enum cho khu vực bàn
enum TableZone {
  all, 
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
  final TableZone zone; 
  final bool isPendingPayment; // ✅ THÊM TRƯỜNG NÀY

  TableModel({
    required this.id,
    required this.name,
    required this.seats,
    this.status = TableStatus.available,
    this.customerCount,
    this.totalAmount = 0.0,
    this.existingItems = const [],
    this.zone = TableZone.indoor, 
    this.isPendingPayment = false, // ✅ THÊM GIÁ TRỊ MẶC ĐỊNH
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
    bool? isPendingPayment, // ✅ THÊM VÀO COPYWITH
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
      isPendingPayment: isPendingPayment ?? this.isPendingPayment, // ✅
    );
  }
}