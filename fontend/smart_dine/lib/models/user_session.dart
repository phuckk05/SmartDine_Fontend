class UserSession {
  final int userId;
  final String userName;
  final String userRole; // 'admin', 'manager', 'staff'
  final List<int> branchIds; // Chi nhánh mà user có quyền truy cập
  final int? currentBranchId; // Chi nhánh hiện tại đang làm việc
  final DateTime loginTime;
  final bool isAuthenticated;

  const UserSession({
    required this.userId,
    required this.userName,
    required this.userRole,
    required this.branchIds,
    this.currentBranchId,
    required this.loginTime,
    this.isAuthenticated = true,
  });

  // Factory constructor cho user chưa đăng nhập
  factory UserSession.guest() {
    return UserSession(
      userId: 0,
      userName: 'Guest',
      userRole: 'guest',
      branchIds: const [],
      currentBranchId: null,
      loginTime: DateTime.now(),
      isAuthenticated: false,
    );
  }

  // Factory constructor từ API response
  factory UserSession.fromJson(Map<String, dynamic> json) {
    return UserSession(
      userId: json['userId'] ?? 0,
      userName: json['userName'] ?? '',
      userRole: json['userRole'] ?? 'staff',
      branchIds: (json['branchIds'] as List<dynamic>?)?.map((e) => e as int).toList() ?? [],
      currentBranchId: json['currentBranchId'],
      loginTime: json['loginTime'] != null 
          ? DateTime.parse(json['loginTime']) 
          : DateTime.now(),
      isAuthenticated: json['isAuthenticated'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userName': userName,
      'userRole': userRole,
      'branchIds': branchIds,
      'currentBranchId': currentBranchId,
      'loginTime': loginTime.toIso8601String(),
      'isAuthenticated': isAuthenticated,
    };
  }

  // Tạo session mới với branch khác
  UserSession copyWith({
    int? userId,
    String? userName,
    String? userRole,
    List<int>? branchIds,
    int? currentBranchId,
    DateTime? loginTime,
    bool? isAuthenticated,
  }) {
    return UserSession(
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userRole: userRole ?? this.userRole,
      branchIds: branchIds ?? this.branchIds,
      currentBranchId: currentBranchId ?? this.currentBranchId,
      loginTime: loginTime ?? this.loginTime,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }

  // Kiểm tra quyền truy cập chi nhánh
  bool hasAccessToBranch(int branchId) {
    return branchIds.contains(branchId) || userRole == 'admin';
  }

  // Kiểm tra quyền admin
  bool get isAdmin => userRole == 'admin';

  // Kiểm tra quyền manager
  bool get isManager => userRole == 'manager' || userRole == 'admin';

  @override
  String toString() {
    return 'UserSession(userId: $userId, userName: $userName, role: $userRole, currentBranch: $currentBranchId)';
  }
}