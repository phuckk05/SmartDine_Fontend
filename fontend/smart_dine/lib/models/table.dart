// File: mart_dine/models/table.dart

import 'package:flutter/material.dart'; 
import 'package:mart_dine/models/menu.dart'; 

// Enum trạng thái bàn (KHÔNG THAY ĐỔI)
enum TableStatus {
  available, 
  reserved, 
  serving, 
}

enum TableZone {
  all, 
  vip,
  quiet,
  indoor, 
  outdoor, 
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
  final bool isPendingPayment; // ✅ THÊM CỜ (FLAG) NÀY

  TableModel({
    required this.id,
    required this.name,
    required this.seats,
    this.status = TableStatus.available,
    this.customerCount,
    this.totalAmount = 0.0,
    this.existingItems = const [],
    this.zone = TableZone.indoor, 
    this.isPendingPayment = false, // ✅ Thêm giá trị mặc định
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
    bool? isPendingPayment, // ✅ Thêm vào copyWith
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