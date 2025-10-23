import 'dart:convert';

class Item {
  final int? id;
  final int companyId;
  final String name;
  final double price;
  final int statusId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;

  const Item({
    this.id,
    required this.companyId,
    required this.name,
    required this.price,
    required this.statusId,
    this.createdAt,
    this.updatedAt,
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
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'deletedAt': deletedAt?.toIso8601String(),
    };
  }

  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
      id: _asInt(map['id']),
      companyId: _asInt(map['companyId'] ?? map['company_id']),
      name: map['name']?.toString() ?? '',
      price: _asDouble(map['price']),
      statusId: _asInt(map['statusId'] ?? map['status_id']),
      createdAt: _parseDate(map['createdAt'] ?? map['created_at']),
      updatedAt: _parseDate(map['updatedAt'] ?? map['updated_at']),
      deletedAt: _parseDate(map['deletedAt'] ?? map['deleted_at']),
    );
  }

  String toJson() => jsonEncode(toMap());

  factory Item.fromJson(String source) =>
      Item.fromMap(jsonDecode(source) as Map<String, dynamic>);

  static int _asInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }

  static double _asDouble(dynamic value) {
    if (value == null) return 0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }
}

// ...existing code...
