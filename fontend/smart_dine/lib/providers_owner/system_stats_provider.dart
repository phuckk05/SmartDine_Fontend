// file: providers/system_stats_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mart_dine/models_owner/user.dart';
import 'package:mart_dine/API_owner/company_API.dart';
import 'package:mart_dine/API_owner/user_API.dart';
import 'package:mart_dine/providers_owner/target_provider.dart';
import 'package:mart_dine/providers_owner/staff_profile_provider.dart';
import 'package:mart_dine/providers_owner/role_provider.dart'; // <<< SỬA: Thêm import

// Provider để lưu trữ ID của người dùng đã đăng nhập.
// Giá trị này sẽ được cập nhật từ màn hình đăng nhập.
final loggedInOwnerIdProvider = StateProvider<int?>((ref) => null);

final ownerProfileProvider = FutureProvider<User>((ref) async {
  final loggedInUserId = ref.watch(loggedInOwnerIdProvider);

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

// Provider mới: Chỉ lấy companyId của owner
// Giúp companyProvider không cần phụ thuộc vào toàn bộ User object
final ownerCompanyIdProvider = FutureProvider<int?>((ref) async {
  // Chờ ownerProfileProvider hoàn thành
  final owner = await ref.watch(ownerProfileProvider.future);
  // Trả về companyId của owner
  return owner.companyId;
});

// Provider này tính toán các thống kê hệ thống
// Nó phụ thuộc vào các provider khác để lấy dữ liệu
final systemStatsProvider = Provider<Map<String, String>>((ref) {
 // Lấy companyId động từ owner
 final companyIdAsync = ref.watch(ownerCompanyIdProvider);

 // Mặc định là 0 nếu chưa có companyId
 final branchCount = companyIdAsync.when(
  data: (id) => id != null ? (ref.watch(branchesByCompanyProvider(id)).value?.length ?? 0) : 0,
  loading: () => 0,
  error: (_, __) => 0,
 );

 final staffListAsync = ref.watch(staffProfileProvider);
 final staffCount = staffListAsync.value?.length ?? 0;

 return {
  "total_branches": branchCount.toString(),
  "total_staff": staffCount.toString(),
  "service_package": "Free", // Dữ liệu giả lập, cần API từ backend
  "service_status": "Đang sử dụng", // Dữ liệu giả lập, cần API từ backend
 };
});