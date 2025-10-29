import 'dart:convert';

class OrderStatus {
  final int id;
  final String code; // PENDING, COOKING, DONE, PAID
  final String name;

  OrderStatus({
    required this.id,
    required this.code,
    required this.name,
  });

  factory OrderStatus.fromJson(Map<String, dynamic> json) {
    return OrderStatus(
      id: json['id'] ?? 0,
      code: json['code'] ?? '',
      name: json['name'] ?? '',
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

class Order {
  // Properties - phù hợp với backend model
  final int? id;
  final int? tableId;
  final int? companyId;
  final int? branchId;
  final int? userId;
  final int? promotionId;
  final String? note;
  final int? statusId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  // Relations - thông tin từ JOIN
  OrderStatus? status;
  String? tableName;
  String? userName;
  String? branchName;
  String? companyName;
  List<OrderItem>? items;
  double? totalAmount;

  Order({
    this.id,
    this.tableId,
    this.companyId,
    this.branchId,
    this.userId,
    this.promotionId,
    this.note,
    this.statusId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.status,
    this.tableName,
    this.userName,
    this.branchName,
    this.companyName,
    this.items,
    this.totalAmount,
  });

  Order copyWith({
    int? id,
    int? tableId,
    int? companyId,
    int? branchId,
    int? userId,
    int? promotionId,
    String? note,
    int? statusId,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    OrderStatus? status,
    String? tableName,
    String? userName,
    String? branchName,
    String? companyName,
    List<OrderItem>? items,
    double? totalAmount,
  }) {
    return Order(
      id: id ?? this.id,
      tableId: tableId ?? this.tableId,
      companyId: companyId ?? this.companyId,
      branchId: branchId ?? this.branchId,
      userId: userId ?? this.userId,
      promotionId: promotionId ?? this.promotionId,
      note: note ?? this.note,
      statusId: statusId ?? this.statusId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      status: status ?? this.status,
      tableName: tableName ?? this.tableName,
      userName: userName ?? this.userName,
      branchName: branchName ?? this.branchName,
      companyName: companyName ?? this.companyName,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tableId': tableId,
      'table_id': tableId,
      'companyId': companyId,
      'company_id': companyId,
      'branchId': branchId,
      'branch_id': branchId,
      'userId': userId,
      'user_id': userId,
      'promotionId': promotionId,
      'promotion_id': promotionId,
      'note': note,
      'statusId': statusId,
      'status_id': statusId,
      'createdAt': createdAt.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'deletedAt': deletedAt?.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
      if (status != null) 'status': status!.toJson(),
      if (tableName != null) 'tableName': tableName,
      if (tableName != null) 'table_name': tableName,
      if (userName != null) 'userName': userName,
      if (userName != null) 'user_name': userName,
      if (branchName != null) 'branchName': branchName,
      if (branchName != null) 'branch_name': branchName,
      if (companyName != null) 'companyName': companyName,
      if (companyName != null) 'company_name': companyName,
      if (items != null) 'items': items!.map((item) => item.toMap()).toList(),
      if (totalAmount != null) 'totalAmount': totalAmount,
      if (totalAmount != null) 'total_amount': totalAmount,
    };
  }

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id'] != null ? int.tryParse(map['id'].toString()) : null,
      tableId: map['tableId'] != null ? int.tryParse(map['tableId'].toString()) :
               map['table_id'] != null ? int.tryParse(map['table_id'].toString()) : null,
      companyId: map['companyId'] != null ? int.tryParse(map['companyId'].toString()) :
                 map['company_id'] != null ? int.tryParse(map['company_id'].toString()) : null,
      branchId: map['branchId'] != null ? int.tryParse(map['branchId'].toString()) :
                map['branch_id'] != null ? int.tryParse(map['branch_id'].toString()) :
                (map['table'] != null && map['table']['branchId'] != null ? int.tryParse(map['table']['branchId'].toString()) :
                 map['table'] != null && map['table']['branch_id'] != null ? int.tryParse(map['table']['branch_id'].toString()) : null),
      userId: map['userId'] != null ? int.tryParse(map['userId'].toString()) :
              map['user_id'] != null ? int.tryParse(map['user_id'].toString()) : null,
      promotionId: map['promotionId'] != null ? int.tryParse(map['promotionId'].toString()) :
                   map['promotion_id'] != null ? int.tryParse(map['promotion_id'].toString()) : null,
      note: map['note']?.toString(),
      statusId: map['statusId'] != null ? int.tryParse(map['statusId'].toString()) :
                map['status_id'] != null ? int.tryParse(map['status_id'].toString()) : null,
      createdAt: map['createdAt'] != null 
          ? DateTime.parse(map['createdAt'].toString()) 
          : (map['created_at'] != null 
              ? DateTime.parse(map['created_at'].toString()) 
              : DateTime.now()),
      updatedAt: map['updatedAt'] != null 
          ? DateTime.parse(map['updatedAt'].toString()) 
          : (map['updated_at'] != null 
              ? DateTime.parse(map['updated_at'].toString()) 
              : DateTime.now()),
      deletedAt: map['deletedAt'] != null 
          ? DateTime.parse(map['deletedAt'].toString()) 
          : (map['deleted_at'] != null 
              ? DateTime.parse(map['deleted_at'].toString()) 
              : null),
      status: map['status'] != null ? OrderStatus.fromJson(map['status']) : null,
      tableName: map['tableName']?.toString() ?? map['table_name']?.toString(),
      userName: map['userName']?.toString() ?? map['user_name']?.toString(),
      branchName: map['branchName']?.toString() ?? map['branch_name']?.toString(),
      companyName: map['companyName']?.toString() ?? map['company_name']?.toString(),
      items: map['items'] != null 
          ? (map['items'] as List).map((item) => OrderItem.fromMap(item)).toList()
          : null,
      totalAmount: map['totalAmount'] != null 
          ? double.tryParse(map['totalAmount'].toString())
          : (map['total_amount'] != null 
              ? double.tryParse(map['total_amount'].toString())
              : null),
    );
  }

  String toJson() => json.encode(toMap());

  factory Order.fromJson(String source) => Order.fromMap(json.decode(source));

  // Helper methods
  bool isPending() => status?.code == 'PENDING';
  bool isCooking() => status?.code == 'COOKING';
  bool isDone() => status?.code == 'DONE';
  bool isPaid() => status?.code == 'PAID';
  bool isCancelled() => status?.code == 'CANCELLED';

  String getStatusName() => status?.name ?? 'Unknown';
  
  double getTotalAmount() => totalAmount ?? 0.0;
  
  String getTableDisplayName() => tableName ?? 'Bàn $tableId';
  
  String getFormattedDate() {
    return '${createdAt.day}/${createdAt.month}/${createdAt.year} ${createdAt.hour}:${createdAt.minute.toString().padLeft(2, '0')}';
  }

  @override
  String toString() {
    return 'Order(id: $id, tableId: $tableId, branchId: $branchId, statusId: $statusId, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Order &&
        other.id == id &&
        other.tableId == tableId &&
        other.branchId == branchId &&
        other.statusId == statusId &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        tableId.hashCode ^
        branchId.hashCode ^
        statusId.hashCode ^
        createdAt.hashCode;
  }
}

class OrderItem {
  final int? id;
  final int orderId;
  final int itemId;
  final int quantity;
  final String? note;
  final int? statusId;
  final int? addedBy;
  final int? servedBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Relations
  OrderStatus? status;
  String? itemName;
  double? itemPrice;
  String? addedByName;
  String? servedByName;

  OrderItem({
    this.id,
    required this.orderId,
    required this.itemId,
    required this.quantity,
    this.note,
    this.statusId,
    this.addedBy,
    this.servedBy,
    required this.createdAt,
    required this.updatedAt,
    this.status,
    this.itemName,
    this.itemPrice,
    this.addedByName,
    this.servedByName,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'orderId': orderId,
      'order_id': orderId,
      'itemId': itemId,
      'item_id': itemId,
      'quantity': quantity,
      'note': note,
      'statusId': statusId,
      'status_id': statusId,
      'addedBy': addedBy,
      'added_by': addedBy,
      'servedBy': servedBy,
      'served_by': servedBy,
      'createdAt': createdAt.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      if (status != null) 'status': status!.toJson(),
      if (itemName != null) 'itemName': itemName,
      if (itemName != null) 'item_name': itemName,
      if (itemPrice != null) 'itemPrice': itemPrice,
      if (itemPrice != null) 'item_price': itemPrice,
      if (addedByName != null) 'addedByName': addedByName,
      if (addedByName != null) 'added_by_name': addedByName,
      if (servedByName != null) 'servedByName': servedByName,
      if (servedByName != null) 'served_by_name': servedByName,
    };
  }

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      id: map['id'] != null ? int.tryParse(map['id'].toString()) : null,
      orderId: int.tryParse(map['orderId']?.toString() ?? map['order_id']?.toString() ?? '0') ?? 0,
      itemId: int.tryParse(map['itemId']?.toString() ?? map['item_id']?.toString() ?? '0') ?? 0,
      quantity: int.tryParse(map['quantity']?.toString() ?? '0') ?? 0,
      note: map['note']?.toString(),
      statusId: map['statusId'] != null ? int.tryParse(map['statusId'].toString()) :
                map['status_id'] != null ? int.tryParse(map['status_id'].toString()) : null,
      addedBy: map['addedBy'] != null ? int.tryParse(map['addedBy'].toString()) :
               map['added_by'] != null ? int.tryParse(map['added_by'].toString()) : null,
      servedBy: map['servedBy'] != null ? int.tryParse(map['servedBy'].toString()) :
                map['served_by'] != null ? int.tryParse(map['served_by'].toString()) : null,
      createdAt: map['createdAt'] != null 
          ? DateTime.parse(map['createdAt'].toString()) 
          : (map['created_at'] != null 
              ? DateTime.parse(map['created_at'].toString()) 
              : DateTime.now()),
      updatedAt: map['updatedAt'] != null 
          ? DateTime.parse(map['updatedAt'].toString()) 
          : (map['updated_at'] != null 
              ? DateTime.parse(map['updated_at'].toString()) 
              : DateTime.now()),
      status: map['status'] != null ? OrderStatus.fromJson(map['status']) : null,
      itemName: map['itemName']?.toString() ?? map['item_name']?.toString(),
      itemPrice: map['itemPrice'] != null 
          ? double.tryParse(map['itemPrice'].toString())
          : (map['item_price'] != null 
              ? double.tryParse(map['item_price'].toString())
              : null),
      addedByName: map['addedByName']?.toString() ?? map['added_by_name']?.toString(),
      servedByName: map['servedByName']?.toString() ?? map['served_by_name']?.toString(),
    );
  }

  String toJson() => json.encode(toMap());

  factory OrderItem.fromJson(String source) => OrderItem.fromMap(json.decode(source));

  @override
  String toString() {
    return 'OrderItem(id: $id, orderId: $orderId, itemId: $itemId, quantity: $quantity)';
  }
}