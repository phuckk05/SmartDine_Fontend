import 'dart:convert';
import 'package:bcrypt/bcrypt.dart';

class User {
  final int? id;
  final String fullName;
  final String email;
  final String phone;
  final String passworkHash;
  final String fontImage;
  final String backImage;
  final int statusId;
  final int? role;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  User({
    this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.passworkHash,
    required this.fontImage,
    required this.backImage,
    required this.statusId,
    this.role,
    required this.createdAt,
    required this.updatedAt,
    required this.deletedAt,
  });

  /// Hàm tạo user mới với hash mật khẩu
  factory User.create({
    required String fullName,
    required String email,
    required String phone,
    required String password, // nhận mật khẩu gốc
    required int statusId,
    required int? role,
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
      role: role,
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
    String? fontImage,
    String? backImage,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return User(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      passworkHash: passworkHash ?? this.passworkHash,
      statusId: statusId ?? this.statusId,
      role: role ?? this.role,
      fontImage: fontImage ?? this.fontImage,
      backImage: backImage ?? this.backImage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'passworkHash': passworkHash,
      'statusId': statusId,
      'role': role,
      'fontImage': fontImage,
      'backImage': backImage,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'deletedAt': deletedAt?.toIso8601String(),
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    // helper to parse int safely
    // ignore: no_leading_underscores_for_local_identifiers
    //Hàm kiểm tra kiểu dữ liệu
    int? parseInt(dynamic v) {
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
      id: int.tryParse(map['id']?.toString() ?? '') ?? 0,
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      passworkHash: map['passworkHash'] ?? '',
      statusId: parseInt(map['statusId']) ?? 0,
      role: parseInt(map['statusId']) ?? 0,
      fontImage: map['fontImage'] ?? '',
      backImage: map['backImage'] ?? '',
      createdAt: _parseDate(map['createdAt']),
      updatedAt: _parseDate(map['updatedAt']),
      deletedAt: _parseDate(map['deletedAt']),
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
        other.role == role &&
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
