import 'dart:convert';

class Chef {
  final int id;
  final String name;
  final String email;

  Chef({required this.id, required this.name, required this.email});

  /// Clone object có chỉnh sửa
  Chef copyWith({int? id, String? name, String? email}) {
    return Chef(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
    );
  }

  /// Chuyển đối tượng → Map
  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'email': email};
  }

  /// Chuyển Map → Đối tượng
  factory Chef.fromMap(Map<String, dynamic> map) {
    return Chef(
      id: map['id']?.toInt() ?? 0,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
    );
  }

  /// Chuyển JSON string → Đối tượng
  factory Chef.fromJson(String source) =>
      Chef.fromMap(json.decode(source) as Map<String, dynamic>);

  /// Chuyển đối tượng → JSON string
  String toJson() => json.encode(toMap());

  @override
  String toString() => 'Chef(id: $id, name: $name, email: $email)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Chef &&
        other.id == id &&
        other.name == name &&
        other.email == email;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ email.hashCode;
}
