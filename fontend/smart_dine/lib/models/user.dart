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
  final int? role; // Thêm role field theo backend
  final int? companyId; // Thêm companyId field theo backend
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

  /// Hàm tạo user mới với hash mật khẩu
  factory User.create({
    required String fullName,
    required String email,
    required String phone,
    required String password, // nhận mật khẩu gốc
    required int statusId,
    required String? fontImage,
    required String? backImage,
  }) {
    // hash mật khẩu
    final hashed = BCrypt.hashpw(password, BCrypt.gensalt());
    final now = DateTime.now();
    return User(
      fullName: fullName,
      email: email,
      phone: phone,
      passworkHash: hashed,
      statusId: statusId,
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
    return {
      'id': id,
      'fullName': fullName,
      'full_name': fullName,
      'email': email,
      'phone': phone,
      'passworkHash': passworkHash,
      'passwork_hash': passworkHash,
      'passwordHash': passworkHash,
      'password_hash': passworkHash,
      'statusId': statusId,
      'status_id': statusId,
      'role': role,
      'companyId': companyId,
      'company_id': companyId,
      'fontImage': fontImage,
      'font_image': fontImage,
      'backImage': backImage,
      'back_image': backImage,
      'createdAt': createdAt.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'deletedAt': deletedAt?.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
      if (roleName != null) 'roleName': roleName,
      if (roleName != null) 'role_name': roleName,
      if (statusName != null) 'statusName': statusName,
      if (statusName != null) 'status_name': statusName,
      if (companyName != null) 'companyName': companyName,
      if (companyName != null) 'company_name': companyName,
      if (branchIds != null) 'branchIds': branchIds,
      if (branchIds != null) 'branch_ids': branchIds,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    // helper to parse int safely
    // ignore: no_leading_underscores_for_local_identifiers
    //Hàm kiểm tra kiểu dữ liệu
    int? _parseInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      return int.tryParse(v.toString());
    }

    //Hàm chuyển đổi date
    // ignore: no_leading_underscores_for_local_identifiers
    DateTime _parseDate(dynamic v) {
      if (v == null) return DateTime.now();
      if (v is int) {
        return DateTime.fromMillisecondsSinceEpoch(v);
      }
      if (v is String) {
        // Try ISO8601 first
        final parsed = DateTime.tryParse(v);
        if (parsed != null) return parsed;
        // fallback: try parsing as int string (epoch ms)
        final i = int.tryParse(v);
        if (i != null) return DateTime.fromMillisecondsSinceEpoch(i);
      }
      // default fallback
      return DateTime.now();
    }

    return User(
      id: _parseInt(map['id']),
      fullName: map['fullName']?.toString() ?? map['full_name']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      passworkHash: map['passworkHash']?.toString() ?? 
                   map['passwork_hash']?.toString() ?? 
                   map['passwordHash']?.toString() ?? 
                   map['password_hash']?.toString() ?? '',
      statusId: _parseInt(map['statusId']) ?? _parseInt(map['status_id']),
      role: _parseInt(map['role']),
      companyId: _parseInt(map['companyId']) ?? _parseInt(map['company_id']),
      fontImage: map['fontImage']?.toString() ?? map['font_image']?.toString(),
      backImage: map['backImage']?.toString() ?? map['back_image']?.toString(),
      createdAt: _parseDate(map['createdAt'] ?? map['created_at']),
      updatedAt: _parseDate(map['updatedAt'] ?? map['updated_at']),
      deletedAt: map['deletedAt'] != null ? _parseDate(map['deletedAt']) :
                 map['deleted_at'] != null ? _parseDate(map['deleted_at']) : null,
      roleName: map['roleName']?.toString() ?? map['role_name']?.toString(),
      statusName: map['statusName']?.toString() ?? map['status_name']?.toString(),
      companyName: map['companyName']?.toString() ?? map['company_name']?.toString(),
      branchIds: map['branchIds'] != null ? List<int>.from(map['branchIds']) :
                 map['branch_ids'] != null ? List<int>.from(map['branch_ids']) : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory User.fromJson(String source) => User.fromMap(json.decode(source));

  @override
  String toString() {
    return 'User(id: $id, full_Name: $fullName, email: $email, phone: $phone, passwork_Hash: $passworkHash, font_Image: $fontImage, back_Image: $backImage, created_At: $createdAt, updated_At: $updatedAt, deleted_At: $deletedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is User &&
        other.id == id &&
        other.fullName == fullName &&
        other.email == email &&
        other.phone == phone &&
        other.passworkHash == passworkHash &&
        other.statusId == statusId &&
        other.fontImage == fontImage &&
        other.backImage == backImage &&
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
        createdAt.hashCode ^
        updatedAt.hashCode ^
        deletedAt.hashCode;
  }
}
