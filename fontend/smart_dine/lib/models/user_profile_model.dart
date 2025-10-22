import 'user.dart';
import 'role.dart';

class UserProfile {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? avatar;
  final String roleCode;
  final String roleName;
  final DateTime? lastLogin;
  final bool isActive;

  // Chi tiết
  final User? userDetails;
  final Role? roleDetails;

  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.avatar,
    required this.roleCode,
    required this.roleName,
    this.lastLogin,
    this.isActive = true,
    this.userDetails,
    this.roleDetails,
  });

  /// Tạo từ User và Role
  factory UserProfile.fromUserAndRole({
    required User user,
    required Role role,
    DateTime? lastLogin,
  }) {
    return UserProfile(
      id: user.id?.toString() ?? '',
      name: user.fullName,
      email: user.email,
      phone: user.phone,
      avatar: user.fontImage.isNotEmpty ? user.fontImage : null,
      roleCode: role.code,
      roleName: role.name,
      lastLogin: lastLogin,
      isActive: user.statusId == 1,
      userDetails: user,
      roleDetails: role,
    );
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      avatar: json['avatar']?.toString(),
      roleCode: json['role_code']?.toString() ?? '',
      roleName: json['role_name']?.toString() ?? '',
      lastLogin:
          json['last_login'] != null
              ? DateTime.tryParse(json['last_login'])
              : null,
      isActive: json['is_active'] as bool? ?? true,
      userDetails:
          json['user_details'] != null
              ? User.fromMap(json['user_details'] as Map<String, dynamic>)
              : null,
      roleDetails:
          json['role_details'] != null
              ? Role.fromMap(json['role_details'] as Map<String, dynamic>)
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'avatar': avatar,
      'role_code': roleCode,
      'role_name': roleName,
      'last_login': lastLogin?.toIso8601String(),
      'is_active': isActive,
      'user_details': userDetails?.toMap(),
      'role_details': roleDetails?.toMap(),
    };
  }

  /// Kiểm tra role
  bool get isKitchenStaff => roleCode == 'KITCHEN_STAFF';
  bool get isWaiter => roleCode == 'WAITER';
  bool get isManager => roleCode == 'MANAGER';
  bool get isAdmin => roleCode == 'ADMIN';
  bool get isCashier => roleCode == 'CASHIER';

  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? avatar,
    String? roleCode,
    String? roleName,
    DateTime? lastLogin,
    bool? isActive,
    User? userDetails,
    Role? roleDetails,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatar: avatar ?? this.avatar,
      roleCode: roleCode ?? this.roleCode,
      roleName: roleName ?? this.roleName,
      lastLogin: lastLogin ?? this.lastLogin,
      isActive: isActive ?? this.isActive,
      userDetails: userDetails ?? this.userDetails,
      roleDetails: roleDetails ?? this.roleDetails,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserProfile && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'UserProfile(id: $id, name: $name, role: $roleName)';
  }
}
