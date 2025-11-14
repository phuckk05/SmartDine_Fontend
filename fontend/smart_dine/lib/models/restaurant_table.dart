import 'dart:convert';

class RestaurantTable {
  // Properties - phù hợp với backend RestaurantTable.java
  final int? id;
  final int? branchId;
  final String name;
  final int? typeId;
  final String? description;
  final int? statusId;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Relations - thông tin từ JOIN
  String? branchName;
  String? typeName;
  String? statusName;
  int? currentOrders; // Số order hiện tại trên bàn
  bool? isAvailable; // Tính toán từ status và orders

  RestaurantTable({
    this.id,
    this.branchId,
    required this.name,
    this.typeId,
    this.description,
    this.statusId,
    required this.createdAt,
    required this.updatedAt,
    this.branchName,
    this.typeName,
    this.statusName,
    this.currentOrders,
    this.isAvailable,
  });

  RestaurantTable copyWith({
    int? id,
    int? branchId,
    String? name,
    int? typeId,
    String? description,
    int? statusId,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? branchName,
    String? typeName,
    String? statusName,
    int? currentOrders,
    bool? isAvailable,
  }) {
    return RestaurantTable(
      id: id ?? this.id,
      branchId: branchId ?? this.branchId,
      name: name ?? this.name,
      typeId: typeId ?? this.typeId,
      description: description ?? this.description,
      statusId: statusId ?? this.statusId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      branchName: branchName ?? this.branchName,
      typeName: typeName ?? this.typeName,
      statusName: statusName ?? this.statusName,
      currentOrders: currentOrders ?? this.currentOrders,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'branchId': branchId,
      'branch_id': branchId,
      'name': name,
      'typeId': typeId,
      'type_id': typeId,
      'description': description,
      'statusId': statusId,
      'status_id': statusId,
      'createdAt': createdAt.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      if (branchName != null) 'branchName': branchName,
      if (branchName != null) 'branch_name': branchName,
      if (typeName != null) 'typeName': typeName,
      if (typeName != null) 'type_name': typeName,
      if (statusName != null) 'statusName': statusName,
      if (statusName != null) 'status_name': statusName,
      if (currentOrders != null) 'currentOrders': currentOrders,
      if (currentOrders != null) 'current_orders': currentOrders,
      if (isAvailable != null) 'isAvailable': isAvailable,
      if (isAvailable != null) 'is_available': isAvailable,
    };
  }

  factory RestaurantTable.fromMap(Map<String, dynamic> map) {
    // Helper to parse int safely
    int? _parseInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      return int.tryParse(v.toString());
    }

    // Helper to parse DateTime
    DateTime _parseDate(dynamic v) {
      if (v == null) return DateTime.now();
      if (v is String) {
        final parsed = DateTime.tryParse(v);
        if (parsed != null) return parsed;
      }
      return DateTime.now();
    }

    return RestaurantTable(
      id: _parseInt(map['id']),
      branchId: _parseInt(map['branchId']) ?? _parseInt(map['branch_id']),
      name: map['name']?.toString() ?? '',
      typeId: _parseInt(map['typeId']) ?? _parseInt(map['type_id']),
      description: map['description']?.toString(),
      statusId: _parseInt(map['statusId']) ?? _parseInt(map['status_id']),
      createdAt: _parseDate(map['createdAt'] ?? map['created_at']),
      updatedAt: _parseDate(map['updatedAt'] ?? map['updated_at']),
      branchName: map['branchName']?.toString() ?? map['branch_name']?.toString(),
      typeName: map['typeName']?.toString() ?? map['type_name']?.toString(),
      statusName: map['statusName']?.toString() ?? map['status_name']?.toString(),
      currentOrders: _parseInt(map['currentOrders']) ?? _parseInt(map['current_orders']),
      isAvailable: map['isAvailable'] as bool? ?? map['is_available'] as bool?,
    );
  }

  String toJson() => json.encode(toMap());

  factory RestaurantTable.fromJson(String source) => RestaurantTable.fromMap(json.decode(source));

  // Helper methods
  bool get available => isAvailable ?? true;
  String get displayName => name;
  String get displayType => typeName ?? 'Bàn thường';
  String get displayStatus => statusName ?? 'Hoạt động';
  int get orderCount => currentOrders ?? 0;

  @override
  String toString() {
    return 'RestaurantTable(id: $id, branchId: $branchId, name: $name, typeId: $typeId, statusId: $statusId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is RestaurantTable &&
        other.id == id &&
        other.branchId == branchId &&
        other.name == name &&
        other.typeId == typeId &&
        other.statusId == statusId;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        branchId.hashCode ^
        name.hashCode ^
        typeId.hashCode ^
        statusId.hashCode;
  }
}