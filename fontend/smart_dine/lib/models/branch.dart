import 'dart:convert';

class Branch {
  //Properties
  final int id;
  final int companyId;
  final String name;
  final String branchCode;
  final String address;
  final String image;
  final String phone;
  final int statusId;
  final int managerId;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Relations - thông tin từ JOIN query
  BranchStatus? status;
  String? managerName;
  String? managerEmail;
  String? managerPhone;
  String? companyName;

  //Constructor
  Branch({
    required this.id,
    required this.companyId,
    required this.name,
    required this.branchCode,
    required this.address,
    required this.image,
    required this.phone,
    required this.statusId,
    required this.managerId,
    required this.createdAt,
    required this.updatedAt,
    this.status,
    this.managerName,
    this.managerEmail,
    this.managerPhone,
    this.companyName,
  });
  factory Branch.create({
    required int companyId,
    required String name,
    required String branchCode,
    required String address,
    required String image,
    required int managerId,
  }) {
    final now = DateTime.now();
    return Branch(
      companyId: companyId,
      name: name,
      branchCode: branchCode,
      address: address,
      image: image,
      statusId: 3,
      managerId: managerId,
      createdAt: now,
      updatedAt: now,
    );
  }
  Branch copyWith({
    int? id,
    int? companyId,
    String? name,
    String? branchCode,
    String? address,
    String? image,
    int? statusId,
    int? managerId,
    DateTime? createdAt,
    DateTime? updatedAt,
    BranchStatus? status,
    String? managerName,
    String? managerEmail,
    String? managerPhone,
    String? companyName,
  }) {
    return Branch(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      name: name ?? this.name,
      branchCode: branchCode ?? this.branchCode,
      address: address ?? this.address,
      image: image ?? this.image,
      statusId: statusId ?? this.statusId,
      managerId: managerId ?? this.managerId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
      managerName: managerName ?? this.managerName,
      managerEmail: managerEmail ?? this.managerEmail,
      managerPhone: managerPhone ?? this.managerPhone,
      companyName: companyName ?? this.companyName,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'companyId': companyId,
      'company_id': companyId, // snake_case cho backend
      'name': name,
      'branchCode': branchCode,
      'branch_code': branchCode, // snake_case cho backend
      'address': address,
      'image': image,
      'statusId': statusId,
      'status_id': statusId, // snake_case cho backend
      'managerId': managerId,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory Branch.fromMap(Map<String, dynamic> map) {
    return Branch(
      id: int.tryParse(map['id'].toString()) ?? 0,
      companyId: int.tryParse(map['companyId'].toString()) ?? 0,
      name: map['name'] ?? '',
      branchCode: map['branchCode'] ?? '',
      address: map['address'] ?? '',
      image: map['image'] ?? '',
      phone: map['phone'] ?? '',
      statusId: int.tryParse(map['statusId'].toString()) ?? 0,
      managerId: int.tryParse(map['managerId'].toString()) ?? 0,
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(map['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }

  String toJson() => json.encode(toMap());

  factory Branch.fromJson(String source) => Branch.fromMap(json.decode(source));

  // Helper methods
  bool isActive() => status?.code == 'ACTIVE';
  bool isInactive() => status?.code == 'INACTIVE';

  String getStatusName() => status?.name ?? 'Unknown';

  @override
  String toString() {
    return 'Branch(id: $id, companyId: $companyId, name: $name, branchCode: $branchCode, address: $address, image: $image, phone: $phone, statusId: $statusId, managerId: $managerId, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Branch &&
        other.id == id &&
        other.companyId == companyId &&
        other.name == name &&
        other.branchCode == branchCode &&
        other.address == address &&
        other.image == image &&
        other.statusId == statusId &&
        other.managerId == managerId &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        companyId.hashCode ^
        name.hashCode ^
        branchCode.hashCode ^
        address.hashCode ^
        image.hashCode ^
        statusId.hashCode ^
        managerId.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
}
