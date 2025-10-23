class OrderItemAction {
  final String id;
  final String code; // ADD, UPDATE, CANCEL, REMOVE, OUT_OF_STOCK
  final String name;

  OrderItemAction({required this.id, required this.code, required this.name});

  factory OrderItemAction.fromJson(Map<String, dynamic> json) {
    return OrderItemAction(
      id: json['id'],
      code: json['code'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'code': code, 'name': name};
  }
}

// Model cho order item logs
class OrderItemLog {
  final String id;
  final String orderItemId;
  final String userId;
  final String actionId;
  final String? note;
  final DateTime createdAt;

  OrderItemLog({
    required this.id,
    required this.orderItemId,
    required this.userId,
    required this.actionId,
    this.note,
    required this.createdAt,
  });

  factory OrderItemLog.fromJson(Map<String, dynamic> json) {
    return OrderItemLog(
      id: json['id'],
      orderItemId: json['order_item_id'],
      userId: json['user_id'],
      actionId: json['action_id'],
      note: json['note'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_item_id': orderItemId,
      'user_id': userId,
      'action_id': actionId,
      'note': note,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
