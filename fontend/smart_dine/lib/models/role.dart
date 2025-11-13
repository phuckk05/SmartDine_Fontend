class Role {
  final String id; // UUID hoặc ID do Firestore tạo
  final String code; // Mã vai trò: "admin", "manager", "cashier", "staff", "chef"
  final String name; // Tên vai trò: "Admin", "Manager", "Cashier", "Staff", "Chef"
  final String? description; // Mô tả chi tiết vai trò
  
  Role({
    required this.id,
    required this.code,
    required this.name,
    this.description,
  });

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      id: json['id'].toString(),
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
    );
  }

  Role copyWith({String? id, String? code, String? name, String? description}) {
    return Role(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      description: description ?? this.description,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      if (description != null) 'description': description,
    };
  }

  // Legacy support for old fromMap
  factory Role.fromMap(Map<String, dynamic> map) {
    return Role(
      id: map['id']?.toString() ?? '0',
      code: map['code'] ?? '',
      name: map['name'] ?? '',
      description: map['description'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'code': code,
      'name': name,
    };
  }

  // Helper methods
  bool isAdmin() => code == 'ADMIN';
  bool isManager() => code == 'MANAGER';
  bool isWaiter() => code == 'WAITER';
  bool isCashier() => code == 'CASHIER';
  bool isChef() => code == 'CHEF';

  @override
  String toString() {
    return 'Role(id: $id, code: $code, name: $name)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Role && other.id == id && other.code == code;
  }

  @override
  int get hashCode => id.hashCode ^ code.hashCode;
}
