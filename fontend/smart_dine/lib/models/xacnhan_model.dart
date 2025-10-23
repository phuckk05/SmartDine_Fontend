import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

enum UserRole {
  branchManager('BRANCH_MANAGER', 'Quản lý chi nhánh'),
  cashier('CASHIER', 'Thu Ngân'),
  employee('EMPLOYEE', 'Nhân Viên'),
  waiter('WAITER', 'Phục vụ'),
  chef('CHEF', 'Bếp trưởng');

  final String code;
  final String displayName;

  const UserRole(this.code, this.displayName);

  factory UserRole.fromCode(String code) {
    return UserRole.values.firstWhere(
      (role) => role.code == code,
      orElse: () => UserRole.employee,
    );
  }
}

enum RequestStatus {
  pending('PENDING', 'Đang chờ xác nhận'),
  confirmed('CONFIRMED', 'Đã xác nhận'),
  rejected('REJECTED', 'Đã từ chối');

  final String code;
  final String displayName;

  const RequestStatus(this.code, this.displayName);

  factory RequestStatus.fromCode(String code) {
    return RequestStatus.values.firstWhere(
      (status) => status.code == code,
      orElse: () => RequestStatus.pending,
    );
  }
}

@immutable
class UserRequest {
  final String id;
  final String userName;
  final UserRole role;
  final String fullName;
  final String address;
  final String phone;
  final DateTime requestDate;
  final RequestStatus status;
  final String? email;
  final String? note;

  UserRequest({
    String? id,
    required this.userName,
    required this.role,
    required this.fullName,
    required this.address,
    required this.phone,
    required this.requestDate,
    this.status = RequestStatus.pending,
    this.email,
    this.note,
  }) : id = id ?? const Uuid().v4();

  // CopyWith method
  UserRequest copyWith({
    String? id,
    String? userName,
    UserRole? role,
    String? fullName,
    String? address,
    String? phone,
    DateTime? requestDate,
    RequestStatus? status,
    String? email,
    String? note,
  }) {
    return UserRequest(
      id: id ?? this.id,
      userName: userName ?? this.userName,
      role: role ?? this.role,
      fullName: fullName ?? this.fullName,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      requestDate: requestDate ?? this.requestDate,
      status: status ?? this.status,
      email: email ?? this.email,
      note: note ?? this.note,
    );
  }

  // JSON Serialization
  factory UserRequest.fromJson(Map<String, dynamic> json) {
    return UserRequest(
      id: json['id'] as String?,
      userName: json['userName'] as String? ?? '',
      role: UserRole.fromCode(json['role'] as String? ?? ''),
      fullName: json['fullName'] as String? ?? '',
      address: json['address'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      requestDate:
          json['requestDate'] != null
              ? DateTime.parse(json['requestDate'].toString())
              : DateTime.now(),
      status: RequestStatus.fromCode(json['status'] as String? ?? ''),
      email: json['email'] as String?,
      note: json['note'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userName': userName,
    'role': role.code,
    'fullName': fullName,
    'address': address,
    'phone': phone,
    'requestDate': requestDate.toIso8601String(),
    'status': status.code,
    'email': email,
    'note': note,
  };

  // Validation
  bool get isValid {
    return userName.isNotEmpty &&
        fullName.isNotEmpty &&
        address.isNotEmpty &&
        phone.isNotEmpty &&
        _validatePhone();
  }

  bool _validatePhone() {
    final phoneRegex = RegExp(r'^(0[3|5|7|8|9])+([0-9]{8})$');
    return phoneRegex.hasMatch(phone);
  }

  bool _validateEmail() {
    if (email == null || email!.isEmpty) return true;
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email!);
  }

  // Formatted date
  String get formattedRequestDate {
    return '${requestDate.day.toString().padLeft(2, '0')}/${requestDate.month.toString().padLeft(2, '0')}/${requestDate.year}';
  }

  // Status helpers
  bool get isPending => status == RequestStatus.pending;
  bool get isConfirmed => status == RequestStatus.confirmed;
  bool get isRejected => status == RequestStatus.rejected;

  // Role display
  String get roleDisplay => role.displayName;
  String get statusDisplay => status.displayName;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserRequest &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'UserRequest(id: $id, userName: $userName, status: ${status.displayName})';
  }
}
