// order_item.dart

import 'package:firebase_auth/firebase_auth.dart';

class OrderItem {
  // SỬA TẤT CẢ CÁC ID TỪ String SANG int
  final int id;
  final int orderId;
  final int itemId;
  final int quantity;
  final String? note;
  final int statusId;
  final int? addedBy;
  final int? servedBy;
  final DateTime createdAt;

  OrderItem({
    required this.id,
    required this.orderId,
    required this.itemId,
    required this.quantity,
    this.note,
    required this.statusId,
    this.addedBy,
    this.servedBy,
    required this.createdAt,
  });

factory OrderItem.create({
    required int orderId,
    required int itemId,
    required int quantity,
    String? note,
    required int statusId,
    int? addedBy,
    int? servedBy,
    required DateTime createdAt,  
  }) {
    // 

    return OrderItem(
      id: 0, // id sẽ được gán bởi backend
      orderId: orderId,
      itemId: itemId,
      quantity: quantity,
      note: note,
      statusId: statusId,
      addedBy: addedBy,
      servedBy: servedBy,
      createdAt: createdAt,
    );
  }
  // HÀM PARSE AN TOÀN (RẤT QUAN TRỌNG)
  static int _asInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }
  

  static int? _asIntNullable(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  static DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.now(); // Trả về ngày giờ hiện tại nếu null
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString()) ?? DateTime.now();
  }

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: _asInt(json['id']),
      orderId: _asInt(json['order_id']),
      itemId: _asInt(json['item_id']),
      quantity: _asInt(json['quantity']),
      note: json['note']?.toString(),
      statusId: _asInt(json['status_id']),
      addedBy: _asIntNullable(json['added_by']),
      servedBy: _asIntNullable(json['served_by']),
      createdAt: _parseDate(json['created_at']), // Dùng hàm parse an toàn
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'item_id': itemId,
      'quantity': quantity,
      'note': note,
      'status_id': statusId,
      'added_by': addedBy,
      'served_by': servedBy,
      'created_at': createdAt.toIso8601String(),
    };
  }

  OrderItem copyWith({
    int? id,
    int? orderId,
    int? itemId,
    int? quantity,
    String? note,
    int? statusId,
    int? addedBy,
    int? servedBy,
    DateTime? createdAt,
  }) {
    return OrderItem(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      itemId: itemId ?? this.itemId,
      quantity: quantity ?? this.quantity,
      note: note ?? this.note,
      statusId: statusId ?? this.statusId,
      addedBy: addedBy ?? this.addedBy,
      servedBy: servedBy ?? this.servedBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}