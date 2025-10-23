import 'package:flutter/foundation.dart';
import 'package:mart_dine/models/cuahang_model.dart';

@immutable
class StoreDetail {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String code;
  final DateTime establishDate;
  final int totalBranches;
  final int totalEmployees;
  final String servicePackage;
  final List<String> licenseImages;
  final bool isActive;
  final String? address; // Thêm address từ Store model

  const StoreDetail({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.code,
    required this.establishDate,
    required this.totalBranches,
    required this.totalEmployees,
    required this.servicePackage,
    required this.licenseImages,
    this.isActive = false,
    this.address,
  });

  // Constructor từ Store model (QUAN TRỌNG!)
  factory StoreDetail.fromStore(Store store) {
    return StoreDetail(
      id: store.id,
      name: store.name,
      email:
          '${store.ownerName.toLowerCase().replaceAll(' ', '')}@restaurant.com', // Generate email từ owner name
      phone: store.phone,
      code:
          'NH-${store.id.substring(0, 6).toUpperCase()}', // Generate code từ ID
      establishDate: store.foundedDate ?? DateTime.now(),
      totalBranches: store.branchNumber,
      totalEmployees:
          store.branchNumber * 10, // Estimate: mỗi chi nhánh ~10 nhân viên
      servicePackage: _getPackageFromBranches(store.branchNumber),
      licenseImages: const ['assets/license1.jpg', 'assets/license2.jpg'],
      isActive: store.status == StoreStatus.active,
      address: store.address,
    );
  }

  // Xác định gói dịch vụ dựa trên số chi nhánh
  static String _getPackageFromBranches(int branches) {
    if (branches >= 5) return 'enterprise';
    if (branches >= 3) return 'premium';
    if (branches >= 2) return 'basic';
    return 'free';
  }

  // CopyWith method
  StoreDetail copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? code,
    DateTime? establishDate,
    int? totalBranches,
    int? totalEmployees,
    String? servicePackage,
    List<String>? licenseImages,
    bool? isActive,
    String? address,
  }) {
    return StoreDetail(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      code: code ?? this.code,
      establishDate: establishDate ?? this.establishDate,
      totalBranches: totalBranches ?? this.totalBranches,
      totalEmployees: totalEmployees ?? this.totalEmployees,
      servicePackage: servicePackage ?? this.servicePackage,
      licenseImages: licenseImages ?? this.licenseImages,
      isActive: isActive ?? this.isActive,
      address: address ?? this.address,
    );
  }

  // JSON Serialization
  factory StoreDetail.fromJson(Map<String, dynamic> json) {
    return StoreDetail(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      code: json['code'] as String? ?? '',
      establishDate:
          json['establishDate'] != null
              ? DateTime.parse(json['establishDate'].toString())
              : DateTime.now(),
      totalBranches: int.tryParse(json['totalBranches'].toString()) ?? 0,
      totalEmployees: int.tryParse(json['totalEmployees'].toString()) ?? 0,
      servicePackage: json['servicePackage'] as String? ?? 'free',
      licenseImages:
          (json['licenseImages'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      isActive: json['isActive'] as bool? ?? false,
      address: json['address'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'phone': phone,
    'code': code,
    'establishDate': establishDate.toIso8601String(),
    'totalBranches': totalBranches,
    'totalEmployees': totalEmployees,
    'servicePackage': servicePackage,
    'licenseImages': licenseImages,
    'isActive': isActive,
    'address': address,
  };

  // Validation
  bool get isValid {
    return name.isNotEmpty &&
        email.isNotEmpty &&
        _validateEmail() &&
        phone.isNotEmpty &&
        _validatePhone() &&
        code.isNotEmpty;
  }

  bool _validateEmail() {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  bool _validatePhone() {
    final phoneRegex = RegExp(r'^(0[3|5|7|8|9])+([0-9]{8})$');
    return phoneRegex.hasMatch(phone);
  }

  // Formatted date string
  String get formattedEstablishDate {
    return '${establishDate.day.toString().padLeft(2, '0')}-${establishDate.month.toString().padLeft(2, '0')}-${establishDate.year}';
  }

  // Status display
  String get statusDisplay => isActive ? 'Đã kích hoạt' : 'Chưa kích hoạt';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StoreDetail &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'StoreDetail(id: $id, name: $name, isActive: $isActive)';
  }
}
