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
  final int? role; // <<< THÊM: Để khớp với User.java (private Integer role)
  final int? companyId; // <<< THÊM: Để khớp với User.java
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
    this.role, // <<< THÊM
    this.companyId, // <<< THÊM
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  factory User.create({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required int statusId,
    int? role, // <<< THÊM
    int? companyId, // <<< THÊM
    required String? fontImage,
    required String? backImage,
  }) {
    final hashed = BCrypt.hashpw(password, BCrypt.gensalt());
    final now = DateTime.now();
    return User(
      fullName: fullName,
      email: email,
      phone: phone,
      passworkHash: hashed,
      statusId: statusId,
      role: role, // <<< THÊM
      companyId: companyId, // <<< THÊM
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
    int? role, // <<< THÊM
    int? companyId, // <<< THÊM
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
      role: role ?? this.role, // <<< THÊM
      companyId: companyId ?? this.companyId, // <<< THÊM
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
      'role': role, // <<< THÊM
      'companyId': companyId, // <<< THÊM
      'fontImage': fontImage,
      'backImage': backImage,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'deletedAt': deletedAt?.toIso8601String(),
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    int? _parseInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      return int.tryParse(v.toString());
    }
    DateTime _parseDate(dynamic v) {
      if (v == null) return DateTime.now();
      if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
      if (v is String) {
        final parsed = DateTime.tryParse(v);
        if (parsed != null) return parsed;
        final i = int.tryParse(v);
        if (i != null) return DateTime.fromMillisecondsSinceEpoch(i);
      }
      return DateTime.now();
    }
    // Chấp nhận cả 'deleted_at' (từ db_ver1.1.txt) và 'deletedAt' (từ code Java)
    dynamic deletedAtValue = map['deleted_at'] ?? map['deletedAt'];

    return User(
      id: _parseInt(map['id']),
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      passworkHash: map['passworkHash'] ?? '',
      statusId: _parseInt(map['statusId']) ?? 0,
      role: _parseInt(map['role']), // <<< THÊM
      companyId: _parseInt(map['companyId']), // <<< THÊM
      fontImage: map['fontImage'] ?? '',
      backImage: map['backImage'] ?? '',
      createdAt: _parseDate(map['createdAt']),
      updatedAt: _parseDate(map['updatedAt']),
      deletedAt: deletedAtValue == null ? null : _parseDate(deletedAtValue),
    );
  }

  String toJson() => json.encode(toMap());
  factory User.fromJson(String source) => User.fromMap(json.decode(source));

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User &&
        other.id == id &&
        other.fullName == fullName &&
        other.email == email &&
        other.phone == phone &&
        other.passworkHash == passworkHash &&
        other.fontImage == fontImage &&
        other.backImage == backImage &&
        other.statusId == statusId &&
        other.role == role && // <<< THÊM
        other.companyId == companyId && // <<< THÊM
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
        role.hashCode ^ // <<< THÊM
        companyId.hashCode ^ // <<< THÊM
        createdAt.hashCode ^
        updatedAt.hashCode ^
        deletedAt.hashCode;
  }
}