class OrderStatus {
  final String id;
  final String code; // PENDING, COOKING, DONE, PAID
  final String name;

  OrderStatus({
    required this.id,
    required this.code,
    required this.name,
  });

  factory OrderStatus.fromJson(Map<String, dynamic> json) {
    return OrderStatus(
      id: json['id'],
      code: json['code'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
    };
  }
}

class OrderItemStatus {
  final String id;
  final String code; // PENDING, COOKING, SERVED
  final String name;

  OrderItemStatus({
    required this.id,
    required this.code,
    required this.name,
  });

  factory OrderItemStatus.fromJson(Map<String, dynamic> json) {
    return OrderItemStatus(
      id: json['id'],
      code: json['code'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
    };
  }
}

class OrderItem {
  final String id;
  final String orderId;
  final String itemId;
  final int quantity;
  final String? note;
  final String statusId;
  final String addedBy;
  final String? servedBy;
  final DateTime createdAt;

  // Relations
  OrderItemStatus? status;
  String? itemName;
  double? itemPrice;

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
    this.status,
    this.itemName,
    this.itemPrice,
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
      status: json['status'] != null ? OrderItemStatus.fromJson(json['status']) : null,
      itemName: json['item_name'],
      itemPrice: json['item_price']?.toDouble(),
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
      if (status != null) 'status': status!.toJson(),
      if (itemName != null) 'item_name': itemName,
      if (itemPrice != null) 'item_price': itemPrice,
    };
  }

  // Calculate total price for this item
  double getTotalPrice() {
    return (itemPrice ?? 0) * quantity;
  }

  // Get status name
  String getStatusName() {
    return status?.name ?? 'Unknown';
  }

  // Check status
  bool isPending() => status?.code == 'PENDING';
  bool isCooking() => status?.code == 'COOKING';
  bool isServed() => status?.code == 'SERVED';
}

class Order {
  final String id;
  final String tableId;
  final String companyId;
  final String branchId;
  final String userId;
  final String? promotionId;
  final String? note;
  final String statusId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  // Relations
  OrderStatus? status;
  List<OrderItem>? items;
  String? tableName;
  String? userName;

  Order({
    required this.id,
    required this.tableId,
    required this.companyId,
    required this.branchId,
    required this.userId,
    this.promotionId,
    this.note,
    required this.statusId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.status,
    this.items,
    this.tableName,
    this.userName,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      tableId: json['table_id'],
      companyId: json['company_id'],
      branchId: json['branch_id'],
      userId: json['user_id'],
      promotionId: json['promotion_id'],
      note: json['note'],
      statusId: json['status_id'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      deletedAt: json['deleted_at'] != null ? DateTime.parse(json['deleted_at']) : null,
      status: json['status'] != null ? OrderStatus.fromJson(json['status']) : null,
      items: json['items'] != null
          ? (json['items'] as List).map((item) => OrderItem.fromJson(item)).toList()
          : null,
      tableName: json['table_name'],
      userName: json['user_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'table_id': tableId,
      'company_id': companyId,
      'branch_id': branchId,
      'user_id': userId,
      'promotion_id': promotionId,
      'note': note,
      'status_id': statusId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
      if (status != null) 'status': status!.toJson(),
      if (items != null) 'items': items!.map((item) => item.toJson()).toList(),
      if (tableName != null) 'table_name': tableName,
      if (userName != null) 'user_name': userName,
    };
  }

  // Calculate total order amount
  double getTotalAmount() {
    if (items == null || items!.isEmpty) return 0;
    return items!.fold(0, (sum, item) => sum + item.getTotalPrice());
  }

  // Get total items count
  int getTotalItemsCount() {
    if (items == null || items!.isEmpty) return 0;
    return items!.fold(0, (sum, item) => sum + item.quantity);
  }

  // Get status name
  String getStatusName() {
    return status?.name ?? 'Unknown';
  }

  // Check status
  bool isPending() => status?.code == 'PENDING';
  bool isCooking() => status?.code == 'COOKING';
  bool isDone() => status?.code == 'DONE';
  bool isPaid() => status?.code == 'PAID';

  // Helper methods for display
  String getOrderCode() {
    if (id.startsWith('order-')) {
      final number = id.substring(6).padLeft(3, '0');
      return '#ĐH$number';
    }
    return '#${id.substring(0, 6).toUpperCase()}';
  }

  String getTableDisplayName() {
    return tableName ?? 'Bàn $tableId';
  }

  String getFormattedDate() {
    return '${createdAt.day.toString().padLeft(2, '0')}-${createdAt.month.toString().padLeft(2, '0')}-${createdAt.year} ${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}';
  }
}
