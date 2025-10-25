import 'dart:convert';
import 'package:uuid/uuid.dart';

class OrderItem {
  final String id;
  final String orderId;
  final String itemId;
  final int quantity;
  final String? note;
  final String statusId;
  final String? addedBy;
  final String? servedBy;
  final DateTime createdAt;

  OrderItem({
    String? id,
    required this.orderId,
    required this.itemId,
    required this.quantity,
    this.note,
    required this.statusId,
    this.addedBy,
    this.servedBy,
    DateTime? createdAt,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now();

  // Robust parsers
  static int _parseInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    return int.tryParse(v.toString()) ?? 0;
  }

  static DateTime _parseDate(dynamic v) {
    if (v == null) return DateTime.now();
    if (v is DateTime) return v;
    if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
    if (v is String) {
      final parsed = DateTime.tryParse(v);
      if (parsed != null) return parsed;
      final i = int.tryParse(v);
      if (i != null) return DateTime.fromMillisecondsSinceEpoch(i);
    }
    return DateTime.now();
  }

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      id: map['id']?.toString(),
      orderId: map['order_id']?.toString() ?? map['orderId']?.toString() ?? '',
      itemId: map['item_id']?.toString() ?? map['itemId']?.toString() ?? '',
      quantity: _parseInt(map['quantity'] ?? map['qty']),
      note: map['note']?.toString(),
      statusId:
          map['status_id']?.toString() ?? map['statusId']?.toString() ?? '',
      addedBy: map['added_by']?.toString() ?? map['addedBy']?.toString(),
      servedBy: map['served_by']?.toString() ?? map['servedBy']?.toString(),
      createdAt: _parseDate(
        map['created_at'] ?? map['createdAt'] ?? map['created'],
      ),
    );
  }

  Map<String, dynamic> toMap() {
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

  factory OrderItem.fromJson(String source) =>
      OrderItem.fromMap(json.decode(source));

  String toJson() => json.encode(toMap());

  OrderItem copyWith({
    String? id,
    String? orderId,
    String? itemId,
    int? quantity,
    String? note,
    String? statusId,
    String? addedBy,
    String? servedBy,
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

  @override
  String toString() {
    return 'OrderItem(id: $id, orderId: $orderId, itemId: $itemId, qty: $quantity)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OrderItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
