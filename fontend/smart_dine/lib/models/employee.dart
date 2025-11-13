import 'role.dart';

class UserStatus {
  final String id;
  final String code; // ACTIVE, INACTIVE, LOCKED
  final String name;

  UserStatus({
    required this.id,
    required this.code,
    required this.name,
  });

  factory UserStatus.fromJson(Map<String, dynamic> json) {
    return UserStatus(
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
}

// Employee chính là User trong database với các relation
class Employee {
  final String id;
  final String fullName;
  final String phone;
  final String email;
  final String passwordHash;
  final String statusId;
  final String? cccd;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  // Relations (from database schema)
  UserStatus? status;
  List<Role>? roles; // từ user_roles table
  List<String>? roleIds; // danh sách role_id
  List<String>? branchIds; // từ user_branches table
  List<String>? companyIds; // từ user_companys table

  Employee({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.email,
    required this.passwordHash,
    required this.statusId,
    this.cccd,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.status,
    this.roles,
    this.roleIds,
    this.branchIds,
    this.companyIds,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'],
      fullName: json['full_name'],
      phone: json['phone'],
      email: json['email'],
      passwordHash: json['password_hash'] ?? '',
      statusId: json['status_id'],
      cccd: json['cccd'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      deletedAt: json['deleted_at'] != null ? DateTime.parse(json['deleted_at']) : null,
      status: json['status'] != null ? UserStatus.fromJson(json['status']) : null,
      roles: json['roles'] != null 
        ? (json['roles'] as List).map((r) => Role.fromJson(r)).toList()
        : null,
      roleIds: json['role_ids'] != null ? List<String>.from(json['role_ids']) : null,
      branchIds: json['branch_ids'] != null ? List<String>.from(json['branch_ids']) : null,
      companyIds: json['company_ids'] != null ? List<String>.from(json['company_ids']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'phone': phone,
      'email': email,
      'password_hash': passwordHash,
      'status_id': statusId,
      'cccd': cccd,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
      if (status != null) 'status': status!.toJson(),
      if (roles != null) 'roles': roles!.map((r) => r.toJson()).toList(),
      if (roleIds != null) 'role_ids': roleIds,
      if (branchIds != null) 'branch_ids': branchIds,
      if (companyIds != null) 'company_ids': companyIds,
    };
  }

  // Helper methods
  String getStatusName() {
    return status?.name ?? 'Unknown';
  }

  bool isActive() {
    return status?.code == 'ACTIVE';
  }

  bool isInactive() {
    return status?.code == 'INACTIVE';
  }

  bool isLocked() {
    return status?.code == 'LOCKED';
  }

  // Get avatar initial
  String getAvatarInitial() {
    return fullName.isNotEmpty ? fullName[0].toUpperCase() : '?';
  }

  // Get primary role
  String getPrimaryRole() {
    if (roles != null && roles!.isNotEmpty) {
      return roles!.first.name;
    }
    return 'N/A';
  }

  // Check if has specific role
  bool hasRole(String roleCode) {
    if (roles == null) return false;
    return roles!.any((r) => r.code == roleCode);
  }

  bool isAdmin() => hasRole('ADMIN');
  bool isManager() => hasRole('MANAGER');
  bool isWaiter() => hasRole('WAITER');
  bool isCashier() => hasRole('CASHIER');
}
