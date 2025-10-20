import 'dart:convert';

class BranchStatus {
  final String id;
  final String code; // ACTIVE, INACTIVE
  final String name;

  BranchStatus({
    required this.id,
    required this.code,
    required this.name,
  });

  factory BranchStatus.fromJson(Map<String, dynamic> json) {
    return BranchStatus(
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

class Branch {
  //Properties
  final String id;
  final String companyId;
  final String name;
  final String branchCode;
  final String address;
  final String image;
  final String phone;
  final String statusId;
  final String managerId;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Relations
  BranchStatus? status;
  String? managerName;

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
  });

  Branch copyWith({
    String? id,
    String? companyId,
    String? name,
    String? branchCode,
    String? address,
    String? image,
    String? phone,
    String? statusId,
    String? managerId,
    DateTime? createdAt,
    DateTime? updatedAt,
    BranchStatus? status,
    String? managerName,
  }) {
    return Branch(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      name: name ?? this.name,
      branchCode: branchCode ?? this.branchCode,
      address: address ?? this.address,
      image: image ?? this.image,
      phone: phone ?? this.phone,
      statusId: statusId ?? this.statusId,
      managerId: managerId ?? this.managerId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'companyId': companyId,
      'name': name,
      'branchCode': branchCode,
      'address': address,
      'image': image,
      'phone': phone,
      'statusId': statusId,
      'managerId': managerId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      if (status != null) 'status': status!.toJson(),
      if (managerName != null) 'managerName': managerName,
    };
  }

  factory Branch.fromMap(Map<String, dynamic> map) {
    return Branch(
      id: map['id']?.toString() ?? '',
      companyId: map['companyId']?.toString() ?? map['company_id']?.toString() ?? '',
      name: map['name'] ?? '',
      branchCode: map['branchCode'] ?? map['branch_code'] ?? '',
      address: map['address'] ?? '',
      image: map['image'] ?? '',
      phone: map['phone'] ?? '',
      statusId: map['statusId']?.toString() ?? map['status_id']?.toString() ?? '',
      managerId: map['managerId']?.toString() ?? map['manager_id']?.toString() ?? '',
      createdAt: map['createdAt'] != null 
          ? DateTime.parse(map['createdAt']) 
          : (map['created_at'] != null 
              ? DateTime.parse(map['created_at']) 
              : DateTime.now()),
      updatedAt: map['updatedAt'] != null 
          ? DateTime.parse(map['updatedAt']) 
          : (map['updated_at'] != null 
              ? DateTime.parse(map['updated_at']) 
              : DateTime.now()),
      status: map['status'] != null ? BranchStatus.fromJson(map['status']) : null,
      managerName: map['managerName'] ?? map['manager_name'],
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
        other.phone == phone &&
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
        phone.hashCode ^
        statusId.hashCode ^
        managerId.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
}
