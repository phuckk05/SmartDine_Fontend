// file: lib/providers/mock_user_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mart_dine/models_owner/user.dart'; // Đảm bảo đường dẫn này đúng

// Provider này chỉ cung cấp một danh sách User giả lập
final mockUserListProvider = Provider<List<User>>((ref) {
  // Dữ liệu giả lập khớp với managerId trong branchListProvider
  return [
    User(
      id: 1,
      fullName: "Nguyễn Đình Phúc",
      email: "phuc@gmail.com",
      phone: "0900000001",
      passworkHash: "",
      fontImage: "",
      backImage: "",
      statusId: 1,
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
      deletedAt: null,
    ),
    User(
      id: 2,
      fullName: "Phạm Văn C",
      email: "c@gmail.com",
      phone: "0900000002",
      passworkHash: "",
      fontImage: "",
      backImage: "",
      statusId: 1,
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
      deletedAt: null,
    ),
    User(
      id: 3,
      fullName: "Trần Thị D",
      email: "d@gmail.com",
      phone: "0900000003",
      passworkHash: "",
      fontImage: "",
      backImage: "",
      statusId: 1,
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
      deletedAt: null,
    ),
  ];
});