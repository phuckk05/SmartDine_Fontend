import 'dart:convert';

class Role {
  final String id; // UUID hoặc ID do Firestore tạo
  final String
  code; //Max vai trò: "admin", "manager", "cashier", "staff", "chef"
  final String
  name; // Tên vai trò: "Admin", "Manager", "Cashier", "Staff", "Chef"
  final String description; // Mô tả chi tiết vai trò
  Role({
    required this.id,
    required this.code,
    required this.name,
    required this.description,
  });

  Role copyWith({String? id, String? code, String? name, String? description}) {
    return Role(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      description: description ?? this.description,
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'code': code, 'name': name, 'description': description};
  }

  factory Role.fromMap(Map<String, dynamic> map) {
    return Role(
      id: map['id'] ?? '',
      code: map['code'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory Role.fromJson(String source) => Role.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Role(id: $id, code: $code, name: $name, description: $description)';
  }

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
