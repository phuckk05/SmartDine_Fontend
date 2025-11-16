// file: lib/models/item.dart
import 'dart:convert';

class Item {
  final int id;
  final int? companyId;
  final String name;
  final double price; // Java là BigDecimal, Dart dùng double
  final int? statusId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  Item({
    required this.id,
    this.companyId,
    required this.name,
    required this.price,
    this.statusId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
Item copyWith({
    int? id,
    int? companyId,
    String? name,
    double? price,
    int? statusId,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return Item(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      name: name ?? this.name,
      price: price ?? this.price,
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
      'price': price,
      'statusId': statusId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'deletedAt': deletedAt?.toIso8601String(),
    };
  }

  factory Item.fromMap(Map<String, dynamic> map) {
    DateTime _parseDate(dynamic v) {
      if (v == null) return DateTime.now();
      if (v is String) return DateTime.tryParse(v) ?? DateTime.now();
      if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
      return DateTime.now();
    }
    dynamic deletedAtValue = map['deleted_at'] ?? map['deletedAt'];

    return Item(
      id: int.tryParse(map['id'].toString()) ?? 0,
      companyId: int.tryParse(map['companyId'].toString()) ?? 0,
      name: map['name'] ?? '',
      price: double.tryParse(map['price'].toString()) ?? 0.0,
      statusId: int.tryParse(map['statusId'].toString()) ?? 0,
      createdAt: _parseDate(map['createdAt']),
      updatedAt: _parseDate(map['updatedAt']),
      deletedAt: deletedAtValue == null ? null : _parseDate(deletedAtValue),
    );
  }

  String toJson() => json.encode(toMap());
  factory Item.fromJson(String source) => Item.fromMap(json.decode(source));
}