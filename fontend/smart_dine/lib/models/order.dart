import 'dart:convert';
import 'package:uuid/uuid.dart';

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

  Order({
    String? id,
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
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

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
      id: map['id']?.toString(),
      tableId: map['table_id']?.toString() ?? map['tableId']?.toString() ?? '',
      companyId:
          map['company_id']?.toString() ?? map['companyId']?.toString() ?? '',
      branchId:
          map['branch_id']?.toString() ?? map['branchId']?.toString() ?? '',
      userId: map['user_id']?.toString() ?? map['userId']?.toString() ?? '',
      promotionId:
          map['promotion_id']?.toString() ?? map['promotionId']?.toString(),
      note: map['note']?.toString(),
      statusId:
          map['status_id']?.toString() ?? map['statusId']?.toString() ?? '',
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

  factory Order.fromJson(String source) => Order.fromMap(json.decode(source));

  String toJson() => json.encode(toMap());

  Order copyWith({
    String? id,
    String? tableId,
    String? companyId,
    String? branchId,
    String? userId,
    String? promotionId,
    String? note,
    String? statusId,
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
