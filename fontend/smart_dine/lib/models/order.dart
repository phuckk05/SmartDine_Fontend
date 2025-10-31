import 'dart:convert';

class Order {
  final int id;
  final int tableId;
  final int companyId;
  final int branchId;
  final int userId;
  final int? promotionId;
  final String? note;
  final int statusId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  Order({
    int? id,
    required this.tableId,
    required this.companyId,
    required this.branchId,
    required this.userId,
    this.promotionId,
    this.note,
    required this.statusId,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.deletedAt,
  }) : id = id ?? 0,
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

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

  // Helpers for parsing
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

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: _parseInt(map['id']),
      tableId: _parseInt(map['table_id'] ?? map['tableId']),
      companyId: _parseInt(map['company_id'] ?? map['companyId']),
      branchId: _parseInt(map['branch_id'] ?? map['branchId']),
      userId: _parseInt(map['user_id'] ?? map['userId']),
      promotionId: _parseNullableInt(map['promotion_id'] ?? map['promotionId']),
      note: map['note']?.toString(),
      statusId: _parseInt(map['status_id'] ?? map['statusId']),
      createdAt: _parseDate(map['created_at'] ?? map['createdAt']),
      updatedAt: _parseDate(map['updated_at'] ?? map['updatedAt']),
      deletedAt:
          map['deleted_at'] != null ? _parseDate(map['deleted_at']) : null,
    );
  }

  Map<String, dynamic> toMap() {
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
    };
  }

  Map<String, dynamic> toCreatePayload() {
    return {
      'tableId': tableId,
      'companyId': companyId,
      'branchId': branchId,
      'userId': userId,
      if (promotionId != null) 'promotionId': promotionId,
      if (note != null && note!.isNotEmpty) 'note': note,
      'statusId': statusId,
    };
  }

  factory Order.fromJson(String source) => Order.fromMap(json.decode(source));

  String toJson() => json.encode(toMap());

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

  @override
  String toString() {
    return 'Order(id: $id, tableId: $tableId, companyId: $companyId, branchId: $branchId, userId: $userId, statusId: $statusId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Order && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
