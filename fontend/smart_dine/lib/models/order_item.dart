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

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'],
      orderId: json['order_id'],
      itemId: json['item_id'],
      quantity: json['quantity'],
      note: json['note'],
      statusId: json['status_id'],
      addedBy: json['added_by'],
      servedBy: json['served_by'],
      createdAt: DateTime.parse(json['created_at']),
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
}
