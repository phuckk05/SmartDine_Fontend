// file: models/order.dart
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

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: int.tryParse(map['id'].toString()) ?? 0,
      tableId: int.tryParse(map['table_id'].toString()) ?? 0,
      companyId: int.tryParse(map['company_id'].toString()) ?? 0,
      branchId: int.tryParse(map['branch_id'].toString()) ?? 0,
      userId: int.tryParse(map['user_id'].toString()) ?? 0,
      promotionId: int.tryParse(map['promotion_id']?.toString() ?? ''),
      note: map['note'],
      statusId: int.tryParse(map['status_id'].toString()) ?? 0,
      createdAt: DateTime.tryParse(map['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(map['updated_at'] ?? '') ?? DateTime.now(),
      deletedAt: DateTime.tryParse(map['deleted_at'] ?? ''),
    );
  }

  String toJson() => json.encode(toMap());

  factory Order.fromJson(String source) => Order.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Order(id: $id, tableId: $tableId, companyId: $companyId, branchId: $branchId, userId: $userId, promotionId: $promotionId, note: $note, statusId: $statusId, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Order &&
        other.id == id &&
        other.tableId == tableId &&
        other.companyId == companyId &&
        other.branchId == branchId &&
        other.userId == userId &&
        other.promotionId == promotionId &&
        other.note == note &&
        other.statusId == statusId &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.deletedAt == deletedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        tableId.hashCode ^
        companyId.hashCode ^
        branchId.hashCode ^
        userId.hashCode ^
        promotionId.hashCode ^
        note.hashCode ^
        statusId.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode ^
        deletedAt.hashCode;
  }
}