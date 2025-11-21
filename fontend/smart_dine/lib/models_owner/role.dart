// lib/models/role.dart
import 'dart:convert';
class Role {
  final int id; 
  final String code;
  final String name;
  final String description; // Model Java thiếu trường này

  Role({
    required this.id,
    required this.code,
    required this.name,
    this.description = '', // Thêm giá trị mặc định
  });

  Role copyWith({
    int? id, 
    String? code,
    String? name,
    String? description,
  }) {
    return Role(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      description: description ?? this.description,
    );
  }

  Map<String, dynamic> toMap() {
    // SỬA: Không gửi 'description' vì backend không có
    return {'id': id, 'code': code, 'name': name};
  }

  factory Role.fromMap(Map<String, dynamic> map) {
    return Role(
      id: int.tryParse(map['id'].toString()) ?? 0,
      code: map['code'] ?? '',
      name: map['name'] ?? '',
      // SỬA: 'description' không có trong JSON, gán giá trị mặc định
      description: map['description'] ?? '', 
    );
  }

  String toJson() => json.encode(toMap());
  factory Role.fromJson(String source) => Role.fromMap(json.decode(source));

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Role &&
        other.id == id &&
        other.code == code &&
        other.name == name &&
        other.description == description;
  }

  @override
  int get hashCode {
    return id.hashCode ^ code.hashCode ^ name.hashCode ^ description.hashCode;
  }
}