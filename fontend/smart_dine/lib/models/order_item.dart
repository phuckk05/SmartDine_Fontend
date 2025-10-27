import 'dart:convert';

class OrderItem {
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
    int? id,
    required this.orderId,
    required this.itemId,
    required this.quantity,
    this.note,
    required this.statusId,
    this.addedBy,
    this.servedBy,
    DateTime? createdAt,
  }) : id = id ?? 0,
       createdAt = createdAt ?? DateTime.now();

  // Robust parsers
  static int _parseInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    return int.tryParse(v.toString()) ?? 0;
  }

  static int? _parseNullableInt(dynamic v) {
    if (v == null || (v is String && v.trim().isEmpty)) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
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
      id: _parseInt(map['id']),
      orderId: _parseInt(map['order_id'] ?? map['orderId']),
      itemId: _parseInt(map['item_id'] ?? map['itemId']),
      quantity: _parseInt(map['quantity'] ?? map['qty']),
      note: map['note']?.toString(),
      statusId: _parseInt(map['status_id'] ?? map['statusId']),
      addedBy: _parseNullableInt(map['added_by'] ?? map['addedBy']),
      servedBy: _parseNullableInt(map['served_by'] ?? map['servedBy']),
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
