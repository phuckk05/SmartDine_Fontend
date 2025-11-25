// file: lib/models/category.dart
import 'dart:convert';

class Category {
  final int id;
  final int? companyId;
  final String name;
  final int? statusId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  Category({
    required this.id,
    this.companyId,
    required this.name,
    this.statusId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

Category copyWith({
    int? id,
    int? companyId,
    String? name,
    int? statusId,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return Category(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      name: name ?? this.name,
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
      'statusId': statusId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'deletedAt': deletedAt?.toIso8601String(),
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    DateTime _parseDate(dynamic v) {
      if (v == null) return DateTime.now();
      if (v is String) return DateTime.tryParse(v) ?? DateTime.now();
      if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
      return DateTime.now();
    }
    dynamic deletedAtValue = map['deleted_at'] ?? map['deletedAt'];

    return Category(
      id: int.tryParse(map['id'].toString()) ?? 0,
      companyId: int.tryParse(map['companyId'].toString()) ?? 0,
      name: map['name'] ?? '',
      statusId: int.tryParse(map['statusId'].toString()) ?? 0,
      createdAt: _parseDate(map['createdAt']),
      updatedAt: _parseDate(map['updatedAt']),
      deletedAt: deletedAtValue == null ? null : _parseDate(deletedAtValue),
    );
  }

  String toJson() => json.encode(toMap());
  factory Category.fromJson(String source) => Category.fromMap(json.decode(source));
}