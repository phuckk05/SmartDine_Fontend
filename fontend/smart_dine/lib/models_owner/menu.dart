import 'dart:convert';

class Menu {
  final int? id;
  final int companyId;
  final String name;
  final String? description;
  final int statusId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;

  const Menu({
    this.id,
    required this.companyId,
    required this.name,
    this.description,
    required this.statusId,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  Menu copyWith({
    int? id,
    int? companyId,
    String? name,
    String? description,
    int? statusId,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return Menu(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      name: name ?? this.name,
      description: description ?? this.description,
      statusId: statusId ?? this.statusId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'companyId': companyId, // SỬA: Khớp với backend Spring (companyId)
      'name': name,
      'description': description,
      'statusId': statusId, // SỬA: Khớp với backend Spring (statusId)
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }

  factory Menu.fromMap(Map<String, dynamic> map) {
    return Menu(
      id: _asInt(map['id']),
      companyId: _asInt(map['companyId'] ?? map['company_id']),
      name: map['name']?.toString() ?? '',
      description: map['description']?.toString(),
      statusId: _asInt(map['statusId'] ?? map['status_id']),
      createdAt: _parseDate(map['createdAt'] ?? map['created_at']),
      updatedAt: _parseDate(map['updatedAt'] ?? map['updated_at']),
      deletedAt: _parseDate(map['deletedAt'] ?? map['deleted_at']),
    );
  }

  String toJson() => json.encode(toMap());

  factory Menu.fromJson(String source) =>
      Menu.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Menu(id: $id, companyId: $companyId, name: $name, description: $description, statusId: $statusId, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Menu &&
        other.id == id &&
        other.companyId == companyId &&
        other.name == name &&
        other.description == description &&
        other.statusId == statusId &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.deletedAt == deletedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        companyId.hashCode ^
        name.hashCode ^
        description.hashCode ^
        statusId.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode ^
        deletedAt.hashCode;
  }
}

// Helper functions for robust parsing
int _asInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  return int.tryParse(value.toString()) ?? 0;
}

DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  if (value is String) return DateTime.tryParse(value);
  return null;
}
