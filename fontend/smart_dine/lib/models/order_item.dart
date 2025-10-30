// File: order_item.dart
import 'dart:convert';

/// 🧩 Mô tả:
/// Dùng cho API /api/order-items/save của backend Spring Boot.
/// Backend yêu cầu object con (order, item, status, user) chứ không nhận các ID rời.

class OrderItem {
  int? id;
  final int orderId;
  final int itemId;
  final int quantity;
  final String? note;
  final int statusId;
  final int? addedBy;
  final int? servedBy;
  final DateTime createdAt;

  OrderItem({
    this.id,
    required this.orderId,
    required this.itemId,
    required this.quantity,
    this.note,
    required this.statusId,
    this.addedBy,
    this.servedBy,
    required this.createdAt,
  });

  /// ✅ Tạo nhanh một OrderItem mới
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
    return OrderItem(
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

  // ----------------------
  //  SAFE PARSE UTILITIES
  // ----------------------

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
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString()) ?? DateTime.now();
  }

  // ----------------------
  //  JSON PARSING
  // ----------------------

  /// ✅ Parse từ JSON trả về từ backend
  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'],
      orderId: json['order']?['id'] ?? 0,
      itemId: json['item']?['id'] ?? 0,
      quantity: _asInt(json['quantity']),
      note: json['note'],
      statusId: json['status']?['id'] ?? 0,
      addedBy: json['addedBy']?['id'],
      servedBy: json['servedBy']?['id'],
      createdAt: _parseDate(json['createdAt']),
    );
  }

  factory OrderItem.fromMap(Map<String, dynamic> map) =>
      OrderItem.fromJson(map);

  /// ✅ JSON gửi lên backend
  Map<String, dynamic> toJson() {
    return {
      'order': {'id': orderId},
      'item': {'id': itemId},
      'quantity': quantity,
      'note': note,
      'status': {'id': statusId},
      'addedBy': addedBy != null ? {'id': addedBy} : null,
      'servedBy': servedBy != null ? {'id': servedBy} : null,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// ✅ Dành cho debug log
  @override
  String toString() => jsonEncode(toJson());

  // ----------------------
  //  COPY UTIL
  // ----------------------

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
