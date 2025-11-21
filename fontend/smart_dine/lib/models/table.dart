import 'dart:convert';

class TableStatus {
  final int id;
  final String code; // ACTIVE, MAINTENANCE, INACTIVE, DELETED
  final String name;

  TableStatus({required this.id, required this.code, required this.name});

  factory TableStatus.fromJson(Map<String, dynamic> json) {
    return TableStatus(
      id: json['id'] ?? 0,
      code: json['code'] ?? '',
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'code': code, 'name': name};
  }
}

class TableType {
  final int id;
  final String code;
  final String name;

  TableType({required this.id, required this.code, required this.name});

  factory TableType.fromJson(Map<String, dynamic> json) {
    return TableType(
      id: json['id'] ?? 0,
      code: json['code'] ?? '',
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'code': code, 'name': name};
  }
}

class Table {
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
  TableStatus? status;
  TableType? type;
  String? branchName;
  String? typeName;
  String? statusName;
  int? currentOrders; // Số order hiện tại trên bàn
  bool? isAvailable; // Tính toán từ status và orders

  Table({
    this.id,
    this.branchId,
    required this.name,
    this.typeId,
    this.description,
    this.statusId,
    required this.createdAt,
    required this.updatedAt,
    this.status,
    this.type,
    this.branchName,
    this.typeName,
    this.statusName,
    this.currentOrders,
    this.isAvailable,
  });

  Table copyWith({
    int? id,
    int? branchId,
    String? name,
    int? typeId,
    String? description,
    int? statusId,
    DateTime? createdAt,
    DateTime? updatedAt,
    TableStatus? status,
    TableType? type,
    String? branchName,
    String? typeName,
    String? statusName,
    int? currentOrders,
    bool? isAvailable,
  }) {
    return Table(
      id: id ?? this.id,
      branchId: branchId ?? this.branchId,
      name: name ?? this.name,
      typeId: typeId ?? this.typeId,
      description: description ?? this.description,
      statusId: statusId ?? this.statusId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
      type: type ?? this.type,
      branchName: branchName ?? this.branchName,
      typeName: typeName ?? this.typeName,
      statusName: statusName ?? this.statusName,
      currentOrders: currentOrders ?? this.currentOrders,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }

  factory Table.fromJson(Map<String, dynamic> json) {
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

    return Table(
      id: _parseInt(json['id']),
      branchId: _parseInt(json['branchId']) ?? _parseInt(json['branch_id']),
      name: json['name']?.toString() ?? '',
      typeId: _parseInt(json['typeId']) ?? _parseInt(json['type_id']),
      description: json['description']?.toString(),
      statusId: _parseInt(json['statusId']) ?? _parseInt(json['status_id']),
      createdAt: _parseDate(json['createdAt'] ?? json['created_at']),
      updatedAt: _parseDate(json['updatedAt'] ?? json['updated_at']),
      status:
          json['status'] != null ? TableStatus.fromJson(json['status']) : null,
      type: json['type'] != null ? TableType.fromJson(json['type']) : null,
      branchName:
          json['branchName']?.toString() ?? json['branch_name']?.toString(),
      typeName: json['typeName']?.toString() ?? json['type_name']?.toString(),
      statusName:
          json['statusName']?.toString() ?? json['status_name']?.toString(),
      currentOrders:
          _parseInt(json['currentOrders']) ?? _parseInt(json['current_orders']),
      isAvailable:
          json['isAvailable'] as bool? ?? json['is_available'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
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
      if (status != null) 'status': status!.toJson(),
      if (type != null) 'type': type!.toJson(),
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

  String toJsonString() => json.encode(toJson());

  factory Table.fromMap(Map<String, dynamic> map) => Table.fromJson(map);

  // Helper methods
  bool get available => isAvailable ?? (statusId == 1); // Active status
  String get displayName => name;
  String get displayType => typeName ?? type?.name ?? 'Bàn thường';
  String get displayStatus => statusName ?? status?.name ?? 'Hoạt động';
  int get orderCount => currentOrders ?? 0;

  bool isActive() => statusId == 1;
  bool isMaintenance() => statusId == 2;
  bool isInactive() => statusId == 3;
  bool isDeleted() => statusId == 4;

  @override
  String toString() {
    return 'Table(id: $id, branchId: $branchId, name: $name, typeId: $typeId, statusId: $statusId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Table &&
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
