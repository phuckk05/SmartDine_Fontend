import 'dart:convert';
import 'package:bcrypt/bcrypt.dart';

class User {
  final int? id;
  final String fullName;
  final String email;
  final String phone;
  final String passworkHash;
  final String? fontImage;
  final String? backImage;
  final int? statusId;
  final int? role; // Role: admin, manager, staff
  final int? companyId; // Company/Restaurant ID
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  // Relations - thông tin từ JOIN
  String? roleName;
  String? statusName;
  String? companyName;
  List<int>? branchIds; // Danh sách chi nhánh user được assign

  User({
    this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.passworkHash,
    this.fontImage,
    this.backImage,
    this.statusId,
    this.role,
    this.companyId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.roleName,
    this.statusName,
    this.companyName,
    this.branchIds,
  });

  // Factory constructor để tạo User mới với password hashing
  factory User.create({
    required String fullName,
    required String email,
    required String phone,
    required String password, // nhận mật khẩu gốc
    int? statusId,
    int? role,
    int? companyId,
    String? fontImage,
    String? backImage,
  }) {
    // hash mật khẩu
    final hashed = BCrypt.hashpw(password, BCrypt.gensalt());
    final now = DateTime.now();
    return User(
      fullName: fullName,
      email: email,
      phone: phone,
      passworkHash: hashed,
      statusId: statusId ?? 1,
      role: role,
      companyId: companyId,
      fontImage: fontImage ?? "Chưa có",
      backImage: backImage ?? "Chưa có",
      createdAt: now,
      updatedAt: now,
      deletedAt: null,
    );
  }

  User copyWith({
    int? id,
    String? fullName,
    String? email,
    String? phone,
    String? passworkHash,
    int? statusId,
    int? role,
    int? companyId,
    String? fontImage,
    String? backImage,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    String? roleName,
    String? statusName,
    String? companyName,
    List<int>? branchIds,
  }) {
    return User(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      passworkHash: passworkHash ?? this.passworkHash,
      statusId: statusId ?? this.statusId,
      role: role ?? this.role,
      companyId: companyId ?? this.companyId,
      fontImage: fontImage ?? this.fontImage,
      backImage: backImage ?? this.backImage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      roleName: roleName ?? this.roleName,
      statusName: statusName ?? this.statusName,
      companyName: companyName ?? this.companyName,
      branchIds: branchIds ?? this.branchIds,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'full_name': fullName,
      'email': email,
      'phone': phone,
      'passwork_hash': passworkHash,
      'font_image': fontImage,
      'back_image': backImage,
      'status_id': statusId,
      'role': role,
      'company_id': companyId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] != null ? map['id'] as int : null,
      fullName: map['full_name'] as String,
      email: map['email'] as String,
      phone: map['phone'] as String,
      passworkHash: map['passwork_hash'] as String,
      fontImage: map['font_image'] != null ? map['font_image'] as String : null,
      backImage: map['back_image'] != null ? map['back_image'] as String : null,
      statusId: map['status_id'] != null ? map['status_id'] as int : null,
      role: map['role'] != null ? map['role'] as int : null,
      companyId: map['company_id'] != null ? map['company_id'] as int : null,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
      deletedAt: map['deleted_at'] != null ? DateTime.parse(map['deleted_at']) : null,
      roleName: map['role_name'] != null ? map['role_name'] as String : null,
      statusName: map['status_name'] != null ? map['status_name'] as String : null,
      companyName: map['company_name'] != null ? map['company_name'] as String : null,
      branchIds: map['branch_ids'] != null ? List<int>.from(map['branch_ids']) : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory User.fromJson(String source) => User.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'User(id: $id, fullName: $fullName, email: $email, phone: $phone, role: $role, companyId: $companyId, branchIds: $branchIds)';
  }

  @override
  bool operator ==(covariant User other) {
    if (identical(this, other)) return true;
  
    return 
      other.id == id &&
      other.fullName == fullName &&
      other.email == email &&
      other.phone == phone &&
      other.passworkHash == passworkHash &&
      other.fontImage == fontImage &&
      other.backImage == backImage &&
      other.statusId == statusId &&
      other.role == role &&
      other.companyId == companyId &&
      other.createdAt == createdAt &&
      other.updatedAt == updatedAt &&
      other.deletedAt == deletedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      fullName.hashCode ^
      email.hashCode ^
      phone.hashCode ^
      passworkHash.hashCode ^
      fontImage.hashCode ^
      backImage.hashCode ^
      statusId.hashCode ^
      role.hashCode ^
      companyId.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode ^
      deletedAt.hashCode;
  }

  // Utility methods cho branch management
  bool hasRole(String roleName) {
    return this.roleName?.toLowerCase() == roleName.toLowerCase();
  }

  bool isAdmin() => hasRole('admin');
  bool isManager() => hasRole('manager');
  bool isStaff() => hasRole('staff');

  bool hasAccessToBranch(int branchId) {
    return branchIds?.contains(branchId) ?? false;
  }

  bool get isActive => statusId == 1; // Assuming 1 = active status

  String get roleDisplayName {
    switch (roleName?.toLowerCase()) {
      case 'admin':
        return 'Quản trị viên';
      case 'manager':
        return 'Quản lý';
      case 'staff':
        return 'Nhân viên';
      default:
        return roleName ?? 'Chưa xác định';
    }
  }
}