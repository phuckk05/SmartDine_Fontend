class Role {
  final String id;
  final String code; // ADMIN, MANAGER, WAITER, CASHIER
  final String name;

  Role({
    required this.id,
    required this.code,
    required this.name,
  });

  factory Role.fromJson(Map<String, dynamic> json) {
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
      id: map['id'] ?? '',
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
