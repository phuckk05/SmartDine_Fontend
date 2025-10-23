import 'dart:convert';

class Order {
  final int? id;
  final int tableId;
  final int companyId;
  final int branchId;
  final int userId;
  final int? promotionId;
  final String? note;
  final int statusId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;

  const Order({
    this.id,
    required this.tableId,
    required this.companyId,
    required this.branchId,
    required this.userId,
    this.promotionId,
    this.note,
    required this.statusId,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
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
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tableId': tableId,
      'companyId': companyId,
      'branchId': branchId,
      'userId': userId,
      'promotionId': promotionId,
      'note': note,
      'statusId': statusId,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'deletedAt': deletedAt?.toIso8601String(),
    };
  }

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: _asInt(map['id']),
      tableId: _asInt(map['tableId'] ?? map['table_id']),
      companyId: _asInt(map['companyId'] ?? map['company_id']),
      branchId: _asInt(map['branchId'] ?? map['branch_id']),
      userId: _asInt(map['userId'] ?? map['user_id']),
      promotionId: _asInt(map['promotionId'] ?? map['promotion_id']),
      note: map['note']?.toString(),
      statusId: _asInt(map['statusId'] ?? map['status_id']),
      createdAt: _parseDate(map['createdAt'] ?? map['created_at']),
      updatedAt: _parseDate(map['updatedAt'] ?? map['updated_at']),
      deletedAt: _parseDate(map['deletedAt'] ?? map['deleted_at']),
    );
  }

  String toJson() => jsonEncode(toMap());

  factory Order.fromJson(String source) =>
      Order.fromMap(jsonDecode(source) as Map<String, dynamic>);

  static int _asInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }
}
