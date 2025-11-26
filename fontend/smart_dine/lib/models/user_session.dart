import 'dart:convert';

class UserSession {
  final int? userId;
  final String? email;
  final String? name;
  final String? userName;
  final String? phone;
  final int? role;
  final int? userRole;
  final int? companyId;
  final String? companyName;
  final int? currentBranchId;
  final List<int> branchIds;
  final bool isAuthenticated;
  final DateTime? loginTime;

  UserSession({
    this.userId,
    this.email,
    this.name,
    this.userName,
    this.phone,
    this.role,
    this.userRole,
    this.companyId,
    this.companyName,
    this.currentBranchId,
    this.branchIds = const [],
    this.isAuthenticated = false,
    this.loginTime,
  });

  factory UserSession.guest() {
    return UserSession(
      isAuthenticated: false,
    );
  }

  factory UserSession.authenticated({
    required int userId,
    required String email,
    required String name,
    String? userName,
    String? phone,
    required int role,
    int? userRole,
    required int companyId,
    int? currentBranchId,
    List<int>? branchIds,
  }) {
    return UserSession(
      userId: userId,
      email: email,
      name: name,
      userName: userName ?? name,
      phone: phone,
      role: role,
      userRole: userRole ?? role,
      companyId: companyId,
      currentBranchId: currentBranchId,
      branchIds: branchIds ?? [],
      isAuthenticated: true,
      loginTime: DateTime.now(),
    );
  }

  UserSession copyWith({
    int? userId,
    String? email,
    String? name,
    String? userName,
    String? phone,
    int? role,
    int? userRole,
    int? companyId,
    String? companyName,
    int? currentBranchId,
    List<int>? branchIds,
    bool? isAuthenticated,
    DateTime? loginTime,
  }) {
    return UserSession(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      name: name ?? this.name,
      userName: userName ?? this.userName,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      userRole: userRole ?? this.userRole,
      companyId: companyId ?? this.companyId,
      companyName: companyName ?? this.companyName,
      currentBranchId: currentBranchId ?? this.currentBranchId,
      branchIds: branchIds ?? this.branchIds,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      loginTime: loginTime ?? this.loginTime,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'email': email,
      'name': name,
      'userName': userName,
      'role': role,
      'userRole': userRole,
      'companyId': companyId,
      'companyName': companyName,
      'currentBranchId': currentBranchId,
      'branchIds': branchIds,
      'isAuthenticated': isAuthenticated,
      'loginTime': loginTime?.toIso8601String(),
      'phone': phone,
    };
  }

  factory UserSession.fromMap(Map<String, dynamic> map) {
    return UserSession(
      userId: map['userId'],
      email: map['email'],
      name: map['name'],
      userName: map['userName'] ?? map['name'],
      role: map['role'],
      userRole: map['userRole'] ?? map['role'],
      companyId: map['companyId'],
      companyName: map['companyName'],
      currentBranchId: map['currentBranchId'],
      branchIds: List<int>.from(map['branchIds'] ?? []),
      isAuthenticated: map['isAuthenticated'] ?? false,
      loginTime: map['loginTime'] != null ? DateTime.parse(map['loginTime']) : null,
      phone: map['phone'],
    );
  }

  // Required methods
  String toJson() => json.encode(toMap());
  factory UserSession.fromJson(String source) => UserSession.fromMap(json.decode(source));

  // Helper methods
  bool hasAccessToBranch(int branchId) => branchIds.contains(branchId);
  bool get isAdmin => role == 1; // Assuming 1 is admin role
  bool get isManager => role == 2; // Assuming 2 is manager role
}