import 'dart:convert';

class Company {
  final int? id;
  final String name;
  final String address;
  final String image;
  final String companyCode;
  final int statusId;
  final DateTime createdAt;
  final DateTime updatedAt;
  Company({
    this.id,
    required this.name,
    required this.address,
    required this.image,
    required this.companyCode,
    required this.statusId,
    required this.createdAt,
    required this.updatedAt,
  });
  factory Company.create({
    required String name,
    required String address,
    required String image,
    required String companyCode,
  }) {
    final now = DateTime.now();
    return Company(
      name: name,
      address: address,
      image: image,
      companyCode: companyCode,
      statusId: 3,
      createdAt: now,
      updatedAt: now,
    );
  }
  Company copyWith({
    int? id,
    String? name,
    String? address,
    String? image,
    String? companyCode,
    int? statusId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Company(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      image: image ?? this.image,
      companyCode: companyCode ?? this.companyCode,
      statusId: statusId ?? this.statusId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'companyCode': companyCode,
      'address': address,
      'image': image,
      'statusId': statusId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Company.fromMap(Map<String, dynamic> map) {
    return Company(
      id:
          map['id'] is int
              ? map['id']
              : int.tryParse(map['id'].toString()) ?? 0,
      name: map['name'] ?? '',
      address: map['address'] ?? '',
      image: map['image'] ?? '',
      companyCode: map['companyCode'] ?? '',
      statusId:
          map['statusId'] is int
              ? map['statusId']
              : int.tryParse(map['statusId'].toString()) ?? 0,
      createdAt:
          DateTime.tryParse(map['created_at'] ?? map['createdAt'] ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(map['updated_at'] ?? map['updatedAt'] ?? '') ??
          DateTime.now(),
    );
  }

  String toJson() => json.encode(toMap());

  factory Company.fromJson(String source) =>
      Company.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Company(id: $id, name: $name, address: $address, image: $image, companyCode: $companyCode, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Company &&
        other.id == id &&
        other.name == name &&
        other.address == address &&
        other.image == image &&
        other.companyCode == companyCode &&
        other.statusId == statusId &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        address.hashCode ^
        image.hashCode ^
        companyCode.hashCode ^
        statusId.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
}
