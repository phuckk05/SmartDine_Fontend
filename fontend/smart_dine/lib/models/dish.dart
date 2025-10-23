import 'package:uuid/uuid.dart';

class DishModel {
  final String id;
  final String name;
  final double price;
  final String? note; // Ghi chú (ví dụ: không cay, ít đường)

  DishModel({
    String? id,
    required this.name,
    required this.price,
    this.note,
  }) : id = id ?? const Uuid().v4();

  DishModel copyWith({
    String? id,
    String? name,
    double? price,
    String? note,
  }) {
    return DishModel(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      note: note ?? this.note,
    );
  }

  factory DishModel.fromJson(Map<String, dynamic> json) {
    return DishModel(
      id: json['id'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      note: json['note'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'note': note,
    };
  }
}