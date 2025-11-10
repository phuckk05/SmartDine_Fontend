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

  Item({
    this.id,
    required this.companyId,
    required this.name,
    required this.price,
    required this.statusId,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  // Robust parsing helpers
  static int? _parseInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }

  static double _parseDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
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

  static DateTime? _parseNullableDate(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
    if (v is String) {
      final parsed = DateTime.tryParse(v);
      if (parsed != null) return parsed;
      final i = int.tryParse(v);
      if (i != null) return DateTime.fromMillisecondsSinceEpoch(i);
    }
    return null;
  }

  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
      id: _parseInt(map['id'] ?? map['Id'] ?? map['ID']),
      companyId:
          _parseInt(map['company_id'] ?? map['companyId'] ?? map['company']) ??
          0,
      name: map['name']?.toString() ?? '',
      price: _parseDouble(map['price'] ?? map['unit_price'] ?? 0),
      statusId:
          _parseInt(map['status_id'] ?? map['statusId'] ?? map['status']) ?? 0,
      createdAt: _parseDate(
        map['created_at'] ?? map['createdAt'] ?? map['created'],
      ),
      updatedAt: _parseDate(
        map['updated_at'] ?? map['updatedAt'] ?? map['updated'],
      ),
      deletedAt: _parseNullableDate(
        map['deleted_at'] ?? map['deletedAt'] ?? map['deleted'],
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'company_id': companyId,
      'name': name,
      'price': price,
      'status_id': statusId,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }

  factory Item.fromJson(String source) => Item.fromMap(json.decode(source));

  String toJson() => json.encode(toMap());

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

  @override
  String toString() {
    return 'Item(id: $id, companyId: $companyId, name: $name, price: $price, statusId: $statusId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Item &&
        other.id == id &&
        other.companyId == companyId &&
        other.name == name;
  }

  @override
  int get hashCode =>
      id.hashCode ^ companyId.hashCode ^ name.hashCode ^ price.hashCode;
}

// ...existing code...
