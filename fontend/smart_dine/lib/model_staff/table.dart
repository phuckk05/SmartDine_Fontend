import 'dart:convert';

class DiningTable {
  final int id;
  final int branchId;
  final String name;
  final int typeId;
  final String? description;
  final int statusId;
  final DateTime createdAt;
  final DateTime updatedAt;

  DiningTable({
    int? id,
    required this.branchId,
    required this.name,
    required this.typeId,
    this.description,
    required this.statusId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : id = id ?? 0,
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  DiningTable copyWith({
    int? id,
    int? branchId,
    String? name,
    int? typeId,
    String? description,
    int? statusId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DiningTable(
      id: id ?? this.id,
      branchId: branchId ?? this.branchId,
      name: name ?? this.name,
      typeId: typeId ?? this.typeId,
      description: description ?? this.description,
      statusId: statusId ?? this.statusId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'branch_id': branchId,
      'name': name,
      'type_id': typeId,
      'description': description,
      'status_id': statusId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory DiningTable.fromMap(Map<String, dynamic> map) {
    return DiningTable(
      id: _parseInt(map['id']),
      branchId: _parseInt(map['branch_id'] ?? map['branchId']),
      name: map['name']?.toString() ?? '',
      typeId: _parseInt(map['type_id'] ?? map['typeId']),
      description: map['description']?.toString(),
      statusId: _parseInt(map['status_id'] ?? map['statusId']),
      createdAt: _parseDate(map['created_at'] ?? map['createdAt']),
      updatedAt: _parseDate(map['updated_at'] ?? map['updatedAt']),
    );
  }

  String toJson() => json.encode(toMap());

  factory DiningTable.fromJson(String source) =>
      DiningTable.fromMap(json.decode(source));

  static int _parseInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    return int.tryParse(v.toString()) ?? 0;
  }

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

  @override
  String toString() {
    return 'DiningTable(id: $id, branchId: $branchId, name: $name, typeId: $typeId, statusId: $statusId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DiningTable && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
