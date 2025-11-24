// file: lib/models/item.dart
import 'dart:convert';

class Item {
  final int id;
  final String name;
  final double price; // Java là BigDecimal, Dart dùng double
  final int? companyId;
  final int? categoryId; // <<< THÊM: Trường để lưu ID nhóm món gốc
  final String? image; // THÊM: URL ảnh của món ăn
  final int? statusId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  Item({
    required this.id,
    required this.name,
    required this.price,
    this.companyId,
    this.image, // THÊM
    this.categoryId, // <<< THÊM
    this.statusId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
Item copyWith({
    int? id,
    String? name,
    double? price,
    int? companyId,
    String? image, // THÊM
    int? categoryId,
    int? statusId,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return Item(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      companyId: companyId ?? this.companyId,
      image: image ?? this.image, // THÊM
      categoryId: categoryId ?? this.categoryId,
      statusId: statusId ?? this.statusId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'companyId': companyId,
      'image': image, // THÊM
      'categoryId': categoryId,
      'statusId': statusId, // Đảm bảo trường này luôn được gửi đi
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
      name: map['name'] ?? '',
      price: double.tryParse(map['price'].toString()) ?? 0.0,
      image: map['image'], // THÊM: Lấy URL ảnh từ map
      companyId: map['companyId'] == null ? null : int.tryParse(map['companyId'].toString()),
      categoryId: map['categoryId'] == null ? null : int.tryParse(map['categoryId'].toString()), // <<< THÊM
      statusId: map['statusId'] == null ? null : int.tryParse(map['statusId'].toString()),
      createdAt: _parseDate(map['createdAt']),
      updatedAt: _parseDate(map['updatedAt']),
      deletedAt: deletedAtValue == null ? null : _parseDate(deletedAtValue),
    );
  }

  String toJson() => json.encode(toMap());
  factory Item.fromJson(String source) => Item.fromMap(json.decode(source));
}