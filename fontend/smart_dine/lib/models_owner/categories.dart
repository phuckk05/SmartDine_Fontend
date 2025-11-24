// file: lib/models/category.dart
import 'dart:convert';

class Category {
  final int? id;
  final int? companyId;
  final String name;
  final int? menuId; // THÊM: Trường để liên kết với Menu
  final int? statusId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;

  Category({
    this.id,
    this.companyId,
    required this.name,
    this.menuId, // THÊM: Thêm vào constructor
    this.statusId,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

Category copyWith({
    int? id,
    int? companyId,
    String? name,
    int? menuId,
    int? statusId,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return Category(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      name: name ?? this.name,
      menuId: menuId ?? this.menuId,
      statusId: statusId ?? this.statusId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'companyId': companyId,
      'name': name,
      'menuId': menuId,
      'statusId': statusId,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'deletedAt': deletedAt?.toIso8601String(),
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    DateTime? _parseDate(dynamic v) {
      if (v == null) return null;
      if (v is String) return DateTime.tryParse(v) ?? DateTime.now();
      if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
      return null;
    }
    dynamic deletedAtValue = map['deleted_at'] ?? map['deletedAt'];

    return Category(
      id: int.tryParse(map['id']?.toString() ?? ''),
      companyId: int.tryParse(map['companyId']?.toString() ?? ''),
      name: map['name'] ?? '',
      menuId: int.tryParse(map['menuId']?.toString() ?? ''), // THÊM: Đọc menuId từ map
      statusId: int.tryParse(map['statusId']?.toString() ?? ''),
      createdAt: _parseDate(map['createdAt']),
      updatedAt: _parseDate(map['updatedAt']),
      deletedAt: deletedAtValue == null ? null : _parseDate(deletedAtValue),
    );
  }

  String toJson() => json.encode(toMap());
  factory Category.fromJson(String source) => Category.fromMap(json.decode(source));
}