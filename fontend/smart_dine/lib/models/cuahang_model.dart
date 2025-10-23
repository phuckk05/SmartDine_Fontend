import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

enum StoreStatus {
  active('ACTIVE', 'Đang hoạt động'),
  inactive('INACTIVE', 'Ngừng hoạt động');

  final String code;
  final String displayName;

  const StoreStatus(this.code, this.displayName);

  factory StoreStatus.fromCode(String code) {
    return StoreStatus.values.firstWhere(
      (status) => status.code == code,
      orElse: () => StoreStatus.active,
    );
  }
}

@immutable
class Store {
  final String id;
  final String name;
  final String ownerName;
  final String phone;
  final int branchNumber;
  final StoreStatus status;
  final String? address;
  final DateTime? foundedDate;

  Store({
    String? id,
    required this.name,
    required this.ownerName,
    required this.phone,
    required this.branchNumber,
    this.status = StoreStatus.active,
    this.address,
    this.foundedDate,
  }) : id = id ?? const Uuid().v4();

  // JSON Serialization
  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      id: json['id'] as String?,
      name: json['name'] as String? ?? '',
      ownerName: json['ownerName'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      branchNumber: int.tryParse(json['branchNumber'].toString()) ?? 0,
      status: StoreStatus.fromCode(json['status'] as String? ?? ''),
      address: json['address'] as String?,
      foundedDate:
          json['foundedDate'] != null
              ? DateTime.parse(json['foundedDate'].toString())
              : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'ownerName': ownerName,
    'phone': phone,
    'branchNumber': branchNumber,
    'status': status.code,
    'address': address,
    'foundedDate': foundedDate?.toIso8601String(),
  };

  // Copywrite method
  Store copyWith({
    String? id,
    String? name,
    String? ownerName,
    String? phone,
    int? branchNumber,
    StoreStatus? status,
    String? address,
    DateTime? foundedDate,
  }) {
    return Store(
      id: id ?? this.id,
      name: name ?? this.name,
      ownerName: ownerName ?? this.ownerName,
      phone: phone ?? this.phone,
      branchNumber: branchNumber ?? this.branchNumber,
      status: status ?? this.status,
      address: address ?? this.address,
      foundedDate: foundedDate ?? this.foundedDate,
    );
  }

  // Validation
  bool get isValid {
    return name.isNotEmpty && ownerName.isNotEmpty && _validatePhone();
  }

  bool _validatePhone() {
    final phoneRegex = RegExp(r'^(0[3|5|7|8|9])+([0-9]{8})$');
    return phoneRegex.hasMatch(phone);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Store && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Store(id: $id, name: $name, owner: $ownerName)';
  }
}
