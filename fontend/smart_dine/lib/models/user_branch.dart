import 'dart:convert';

class UserBranch {
  final int? id;
  final int userId;
  final int branchId;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Relations - thông tin từ JOIN
  String? userName;
  String? userEmail;
  String? userPhone;
  String? branchName;
  String? branchCode;

  UserBranch({
    this.id,
    required this.userId,
    required this.branchId,
    required this.createdAt,
    required this.updatedAt,
    this.userName,
    this.userEmail,
    this.userPhone,
    this.branchName,
    this.branchCode,
  });

  UserBranch copyWith({
    int? id,
    int? userId,
    int? branchId,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? userName,
    String? userEmail,
    String? userPhone,
    String? branchName,
    String? branchCode,
  }) {
    return UserBranch(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      branchId: branchId ?? this.branchId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      userPhone: userPhone ?? this.userPhone,
      branchName: branchName ?? this.branchName,
      branchCode: branchCode ?? this.branchCode,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'user_id': userId,
      'branchId': branchId,
      'branch_id': branchId,
      'createdAt': createdAt.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      if (userName != null) 'userName': userName,
      if (userName != null) 'user_name': userName,
      if (userEmail != null) 'userEmail': userEmail,
      if (userEmail != null) 'user_email': userEmail,
      if (userPhone != null) 'userPhone': userPhone,
      if (userPhone != null) 'user_phone': userPhone,
      if (branchName != null) 'branchName': branchName,
      if (branchName != null) 'branch_name': branchName,
      if (branchCode != null) 'branchCode': branchCode,
      if (branchCode != null) 'branch_code': branchCode,
    };
  }

  factory UserBranch.fromMap(Map<String, dynamic> map) {
    return UserBranch(
      id: map['id'] != null ? int.tryParse(map['id'].toString()) : null,
      userId: int.tryParse(map['userId']?.toString() ?? map['user_id']?.toString() ?? '0') ?? 0,
      branchId: int.tryParse(map['branchId']?.toString() ?? map['branch_id']?.toString() ?? '0') ?? 0,
      createdAt: map['createdAt'] != null 
          ? DateTime.parse(map['createdAt'].toString()) 
          : (map['created_at'] != null 
              ? DateTime.parse(map['created_at'].toString()) 
              : DateTime.now()),
      updatedAt: map['updatedAt'] != null 
          ? DateTime.parse(map['updatedAt'].toString()) 
          : (map['updated_at'] != null 
              ? DateTime.parse(map['updated_at'].toString()) 
              : DateTime.now()),
      userName: map['userName']?.toString() ?? map['user_name']?.toString(),
      userEmail: map['userEmail']?.toString() ?? map['user_email']?.toString(),
      userPhone: map['userPhone']?.toString() ?? map['user_phone']?.toString(),
      branchName: map['branchName']?.toString() ?? map['branch_name']?.toString(),
      branchCode: map['branchCode']?.toString() ?? map['branch_code']?.toString(),
    );
  }

  String toJson() => json.encode(toMap());

  factory UserBranch.fromJson(String source) => UserBranch.fromMap(json.decode(source));

  @override
  String toString() {
    return 'UserBranch(id: $id, userId: $userId, branchId: $branchId, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserBranch &&
        other.id == id &&
        other.userId == userId &&
        other.branchId == branchId &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        branchId.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
}