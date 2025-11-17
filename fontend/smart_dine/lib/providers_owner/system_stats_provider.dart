// file: providers/system_stats_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mart_dine/models_owner/user.dart';
import 'package:mart_dine/API_owner/user_API.dart';
import 'package:mart_dine/providers_owner/target_provider.dart';
import 'package:mart_dine/providers_owner/staff_profile_provider.dart';
import 'package:mart_dine/providers/user_session_provider.dart'; // SỬA: Import user session

// SỬA: Loại bỏ loggedInOwnerIdProvider, sẽ dùng userSessionProvider

final ownerProfileProvider = FutureProvider<User>((ref) async {
  // SỬA: Lấy userId từ userSessionProvider
  final loggedInUserId = ref.watch(userSessionProvider).userId;

  if (loggedInUserId == null) {
    // Ném lỗi nếu không có Owner nào đăng nhập, ngăn việc gọi API không cần thiết.
    throw Exception("Chưa có người dùng Owner nào đăng nhập.");
  }

  final userApi = ref.watch(userApiProvider);
 final currentUser = await userApi.fetchUserById(loggedInUserId);
 
  // Tối ưu hóa: Nếu người dùng đăng nhập có vai trò là Owner (roleId == 5),
  // trả về trực tiếp thông tin của họ. Không cần tìm kiếm lại.
  if (currentUser.role == 5) {
    return currentUser;
  }
  
  // Nếu người đăng nhập không phải Owner, báo lỗi.
  throw Exception("Người dùng đăng nhập (ID: $loggedInUserId) không phải là Owner.");
});

// SỬA: Loại bỏ ownerCompanyIdProvider

// Provider này tính toán các thống kê hệ thống
// Nó phụ thuộc vào các provider khác để lấy dữ liệu
final systemStatsProvider = Provider<Map<String, String>>((ref) {
 // SỬA: Lấy owner profile trực tiếp
 final ownerAsync = ref.watch(ownerProfileProvider);
 final companyId = ownerAsync.value?.companyId;

 // Mặc định là 0 nếu chưa có companyId
 int branchCount = 0;
 if (companyId != null) {
    // Dùng watch để lắng nghe sự thay đổi của branchesByCompanyProvider
    final branchesAsync = ref.watch(branchesByCompanyProvider(companyId));
    branchCount = branchesAsync.when(
      data: (branches) => branches.length,
      loading: () => 0, // Hoặc giá trị mặc định khác khi đang tải
      error: (_, __) => 0, // Xử lý lỗi
    );
 }

 final staffListAsync = ref.watch(staffProfileProvider);
 final staffCount = staffListAsync.value?.length ?? 0;

 return {
  "total_branches": branchCount.toString(),
  "total_staff": staffCount.toString(),
  "service_package": "Free", // Dữ liệu giả lập, cần API từ backend
  "service_status": "Đang sử dụng", // Dữ liệu giả lập, cần API từ backend
 };
});