class CompanyOwner {
  final int companyId;
  final String companyName;
  final String ownerName;
  final String phoneNumber;
  final int userId;
  final int totalBranches;
  final int statusId; // ✅ thêm trường này
  final DateTime createdAt;

  CompanyOwner({
    required this.companyId,
    required this.companyName,
    required this.ownerName,
    required this.phoneNumber,
    required this.userId,
    required this.totalBranches,
    required this.statusId, // ✅ thêm vào constructor
    required this.createdAt,
  });

  /// ✅ Factory khởi tạo từ Map JSON
  factory CompanyOwner.fromMap(Map<String, dynamic> map) {
    return CompanyOwner(
      companyId: map['companyId'] ?? 0,
      companyName: map['companyName'] ?? '',
      ownerName: map['ownerName'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      userId: map['userId'] ?? 0,
      totalBranches:
          (map['totalBranches'] is int)
              ? map['totalBranches']
              : int.tryParse(map['totalBranches']?.toString() ?? '0') ?? 0,
      statusId:
          map['statusId'] ??
          0, // ✅ nếu chưa có statusId trong JSON thì mặc định = 0
      createdAt:
          DateTime.tryParse(map['createdAt'] ?? '') ??
          DateTime.now(), // tránh lỗi parse null
    );
  }

  /// ✅ Convert ngược lại sang Map (nếu cần gửi lên server)
  Map<String, dynamic> toMap() {
    return {
      'companyId': companyId,
      'companyName': companyName,
      'ownerName': ownerName,
      'phoneNumber': phoneNumber,
      'userId': userId,
      'totalBranches': totalBranches,
      'statusId': statusId,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
