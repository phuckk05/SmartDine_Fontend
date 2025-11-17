// file: models/order_item.dart
import 'dart:convert';

class OrderItem {
  final int id;
  final int orderId;
  final int itemId;
  final int quantity;
  final String? note;
  final int statusId;
  final int addedBy;
  final int? servedBy;
  final DateTime createdAt;

  OrderItem({
    required this.id,
    required this.orderId,
    required this.itemId,
    required this.quantity,
    this.note,
    required this.statusId,
    required this.addedBy,
    this.servedBy,
    required this.createdAt,
  });

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

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      id: int.tryParse(map['id'].toString()) ?? 0,
      orderId: int.tryParse(map['order_id'].toString()) ?? 0,
      itemId: int.tryParse(map['item_id'].toString()) ?? 0,
      quantity: int.tryParse(map['quantity'].toString()) ?? 0,
      note: map['note'],
      statusId: int.tryParse(map['status_id'].toString()) ?? 0,
      addedBy: int.tryParse(map['added_by'].toString()) ?? 0,
      servedBy: int.tryParse(map['served_by']?.toString() ?? ''),
      createdAt: DateTime.tryParse(map['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  String toJson() => json.encode(toMap());

  factory OrderItem.fromJson(String source) =>
      OrderItem.fromMap(json.decode(source));

  @override
  String toString() {
    return 'OrderItem(id: $id, orderId: $orderId, itemId: $itemId, quantity: $quantity, note: $note, statusId: $statusId, addedBy: $addedBy, servedBy: $servedBy, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is OrderItem &&
        other.id == id &&
        other.orderId == orderId &&
        other.itemId == itemId &&
        other.quantity == quantity &&
        other.note == note &&
        other.statusId == statusId &&
        other.addedBy == addedBy &&
        other.servedBy == servedBy &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        orderId.hashCode ^
        itemId.hashCode ^
        quantity.hashCode ^
        note.hashCode ^
        statusId.hashCode ^
        addedBy.hashCode ^
        servedBy.hashCode ^
        createdAt.hashCode;
  }
}