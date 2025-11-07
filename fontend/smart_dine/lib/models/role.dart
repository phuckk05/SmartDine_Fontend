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
  });

  Role copyWith({String? id, String? code, String? name, String? description}) {
    return Role(
      id: json['id'],
      code: json['code'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
    };
  }

  // Legacy support for old fromMap
  factory Role.fromMap(Map<String, dynamic> map) {
    return Role(
      id: map['id']?.toInt() ?? 0,
      code: map['code'] ?? '',
      name: map['name'] ?? '',
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
