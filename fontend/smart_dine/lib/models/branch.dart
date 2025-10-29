import 'dart:convert';

class BranchStatus {
  final int id;
  final String code; // ACTIVE, INACTIVE
  final String name;

  BranchStatus({
    required this.id,
    required this.code,
    required this.name,
  });

  factory BranchStatus.fromJson(Map<String, dynamic> json) {
    return BranchStatus(
      id: json['id'] ?? 0,
      code: json['code'] ?? '',
      name: json['name'] ?? '',
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
  //Properties - phù hợp với backend model
  final int? id;
  final int? companyId;
  final String name;
  final String branchCode;
  final String address;
  final String? image;
  final int? statusId;
  final int? managerId;
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
    this.id,
    this.companyId,
    required this.name,
    required this.branchCode,
    required this.address,
    this.image,
    this.statusId,
    this.managerId,
    required this.createdAt,
    required this.updatedAt,
    this.status,
    this.managerName,
    this.managerEmail,
    this.managerPhone,
    this.companyName,
  });

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
      'manager_id': managerId, // snake_case cho backend
      'createdAt': createdAt.toIso8601String(),
      'created_at': createdAt.toIso8601String(), // snake_case cho backend
      'updatedAt': updatedAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(), // snake_case cho backend
      if (status != null) 'status': status!.toJson(),
      if (managerName != null) 'managerName': managerName,
      if (managerName != null) 'manager_name': managerName,
      if (managerEmail != null) 'managerEmail': managerEmail,
      if (managerEmail != null) 'manager_email': managerEmail,
      if (managerPhone != null) 'managerPhone': managerPhone,
      if (managerPhone != null) 'manager_phone': managerPhone,
      if (companyName != null) 'companyName': companyName,
      if (companyName != null) 'company_name': companyName,
    };
  }

  factory Branch.fromMap(Map<String, dynamic> map) {
    return Branch(
      id: map['id'] != null ? int.tryParse(map['id'].toString()) : null,
      companyId: map['companyId'] != null ? int.tryParse(map['companyId'].toString()) : 
                 map['company_id'] != null ? int.tryParse(map['company_id'].toString()) : null,
      name: map['name']?.toString() ?? '',
      branchCode: map['branchCode']?.toString() ?? map['branch_code']?.toString() ?? '',
      address: map['address']?.toString() ?? '',
      image: map['image']?.toString(),
      statusId: map['statusId'] != null ? int.tryParse(map['statusId'].toString()) :
                map['status_id'] != null ? int.tryParse(map['status_id'].toString()) : null,
      managerId: map['managerId'] != null ? int.tryParse(map['managerId'].toString()) :
                 map['manager_id'] != null ? int.tryParse(map['manager_id'].toString()) : null,
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
      status: map['status'] != null ? BranchStatus.fromJson(map['status']) : null,
      managerName: map['managerName']?.toString() ?? map['manager_name']?.toString(),
      managerEmail: map['managerEmail']?.toString() ?? map['manager_email']?.toString(),
      managerPhone: map['managerPhone']?.toString() ?? map['manager_phone']?.toString(),
      companyName: map['companyName']?.toString() ?? map['company_name']?.toString(),
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
    return 'Branch(id: $id, companyId: $companyId, name: $name, branchCode: $branchCode, address: $address, image: $image, statusId: $statusId, managerId: $managerId, createdAt: $createdAt, updatedAt: $updatedAt, managerName: $managerName)';
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
