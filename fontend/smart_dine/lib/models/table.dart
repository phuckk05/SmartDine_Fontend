class TableStatus {
  final String id;
  final String code; // AVAILABLE, OCCUPIED, BROKEN
  final String name;

  TableStatus({
    required this.id,
    required this.code,
    required this.name,
  });

  factory TableStatus.fromJson(Map<String, dynamic> json) {
    return TableStatus(
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

class TableType {
  final String id;
  final String branchId;
  final String code;
  final String name;

  TableType({
    required this.id,
    required this.branchId,
    required this.code,
    required this.name,
  });

  factory TableType.fromJson(Map<String, dynamic> json) {
    return TableType(
      id: json['id'],
      branchId: json['branch_id'],
      code: json['code'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'branch_id': branchId,
      'code': code,
      'name': name,
    };
  }
}

class Table {
  final String id;
  final String branchId;
  final String name;
  final String typeId;
  final String? description;
  final int capacity;
  final String statusId;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Relations
  TableStatus? status;
  TableType? type;

  Table({
    required this.id,
    required this.branchId,
    required this.name,
    required this.typeId,
    this.description,
    required this.capacity,
    required this.statusId,
    required this.createdAt,
    required this.updatedAt,
    this.status,
    this.type,
  });

  factory Table.fromJson(Map<String, dynamic> json) {
    return Table(
      id: json['id'],
      branchId: json['branch_id'],
      name: json['name'],
      typeId: json['type_id'],
      description: json['description'],
      capacity: json['capacity'],
      statusId: json['status_id'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      status: json['status'] != null ? TableStatus.fromJson(json['status']) : null,
      type: json['type'] != null ? TableType.fromJson(json['type']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'branch_id': branchId,
      'name': name,
      'type_id': typeId,
      'description': description,
      'capacity': capacity,
      'status_id': statusId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      if (status != null) 'status': status!.toJson(),
      if (type != null) 'type': type!.toJson(),
    };
  }

  // Helper để lấy status name
  String getStatusName() {
    return status?.name ?? 'Unknown';
  }

  // Helper để lấy type name
  String getTypeName() {
    return type?.name ?? 'Unknown';
  }

  // Helper để check available
  bool isAvailable() {
    return status?.code == 'AVAILABLE';
  }

  // Helper để check occupied
  bool isOccupied() {
    return status?.code == 'OCCUPIED';
  }

  // Helper để check broken
  bool isBroken() {
    return status?.code == 'BROKEN';
  }
}
