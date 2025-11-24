// lib/models/company.dart
import 'dart:convert';

class Company {
  final int id;
  // SỬA: Đổi tên các trường Dart để khớp với UI
  final String companyName;
  final String companyAddress;
  final String companyImageUrl;
  final String companyCode; // SỬA: Đổi thành String để chứa cả chữ và số
  final int statusId;
  // ---
  final DateTime createdAt;
  final DateTime updatedAt;

  Company({
    required this.id,
    required this.companyName,
    required this.companyAddress,
    required this.companyImageUrl,
    required this.companyCode,
    required this.statusId,
    required this.createdAt,
    required this.updatedAt,
  });

  Company copyWith({
    int? id,
    String? companyName,
    String? companyAddress,
    String? companyImageUrl,
    String? companyCode, // SỬA: Đổi thành String
    int? statusId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Company(
      id: id ?? this.id,
      companyName: companyName ?? this.companyName,
      companyAddress: companyAddress ?? this.companyAddress,
      companyImageUrl: companyImageUrl ?? this.companyImageUrl,
      companyCode: companyCode ?? this.companyCode,
      statusId: statusId ?? this.statusId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      // SỬA: Khi gửi đi, chúng ta dùng tên Java
      'name': companyName,
      'address': companyAddress,
      'image': companyImageUrl,
      'companyCode': companyCode, // SỬA: Giờ nó đã là String
      'statusId': statusId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Company.fromMap(Map<String, dynamic> map) {
    // Helper an toàn để parse ngày
    DateTime _parseDate(dynamic v) {
      if (v == null) return DateTime.now();
      if (v is String) return DateTime.tryParse(v) ?? DateTime.now();
      if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
      return DateTime.now();
    }
    
    // Helper an toàn để parse int
    int _parseInt(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      return int.tryParse(v.toString()) ?? 0;
    }

    return Company(
      id: _parseInt(map['id']),
      
      // SỬA: Đọc các trường JSON từ Backend Java
      companyName: map['name'] ?? '', // Đọc 'name'
      companyAddress: map['address'] ?? '', // Đọc 'address'
      companyImageUrl: map['image'] ?? '', // Đọc 'image'
      
      // SỬA: Đọc 'companyCode' trực tiếp dưới dạng String
      companyCode: map['companyCode']?.toString() ?? '', 
      statusId: _parseInt(map['statusId']),
      
      createdAt: _parseDate(map['createdAt']),
      updatedAt: _parseDate(map['updatedAt']),
    );
  }

  String toJson() => json.encode(toMap());

  factory Company.fromJson(String source) =>
      Company.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Company(id: $id, companyName: $companyName, companyAddress: $companyAddress, companyImageUrl: $companyImageUrl, companyCode: $companyCode, statusId: $statusId, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Company &&
        other.id == id &&
        other.companyName == companyName &&
        other.companyAddress == companyAddress &&
        other.companyImageUrl == companyImageUrl &&
        other.companyCode == companyCode &&
        other.statusId == statusId &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        companyName.hashCode ^
        companyAddress.hashCode ^
        companyImageUrl.hashCode ^
        companyCode.hashCode ^
        statusId.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
}