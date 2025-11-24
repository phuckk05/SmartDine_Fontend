// file: providers/system_stats_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mart_dine/models_owner/user.dart';
import 'package:mart_dine/API_owner/user_API.dart';
import 'package:mart_dine/providers_owner/target_provider.dart';
import 'package:mart_dine/providers_owner/staff_profile_provider.dart';
import 'package:mart_dine/providers/user_session_provider.dart'; // SỬA: Import user session
// THÊM: Import các provider API cần thiết
import 'package:mart_dine/API_owner/payment_API.dart';
import 'package:mart_dine/API_owner/order_API.dart';

// SỬA: Loại bỏ loggedInOwnerIdProvider, sẽ dùng userSessionProvider

final ownerProfileProvider = FutureProvider<User>((ref) async {
  // SỬA: Lấy userId từ userSessionProvider
  final loggedInUserId = ref.watch(userSessionProvider).userId;
  if (loggedInUserId == null) {
    throw Exception("Chưa có người dùng Owner nào đăng nhập.");
  }
  final userApi = ref.watch(userApiProvider);
  // SỬA: Dùng async/await để trả về User, đúng với FutureProvider
  return await userApi.fetchUserById(loggedInUserId);
});

// SỬA: Loại bỏ ownerCompanyIdProvider

// Provider này tính toán các thống kê hệ thống
// Nó phụ thuộc vào các provider khác để lấy dữ liệu
// SỬA: Chuyển đổi kiểu trả về của FutureProvider thành Map<String, dynamic> để chứa cả số và chuỗi.
final systemStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  // SỬA: Lấy companyId từ ownerProfileProvider để đảm bảo tính chính xác và đồng bộ.
  // Provider sẽ chờ ownerProfileProvider tải xong rồi mới thực thi.
  final owner = await ref.watch(ownerProfileProvider.future);
  final companyId = owner.companyId;

  // Nếu không có companyId, trả về map rỗng để tránh lỗi
  if (companyId == null) {
    return {
      "total_revenue": 0.0,
      "total_orders": 0,
    };
  }

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

 // SỬA: Lọc danh sách nhân viên theo companyId của owner
 final staffListAsync = ref.watch(staffProfileProvider);
 final staffCount = staffListAsync.when(
  data: (staffList) {
    // Chỉ đếm những nhân viên có companyId trùng với owner
    return staffList.where((profile) => profile.user.companyId == companyId).length;
  },
  loading: () => 0,
  error: (_, __) => 0,
 );

  // THÊM: Gọi API để lấy tổng doanh thu và tổng đơn hàng
  final paymentApi = ref.read(paymentApiProvider);
  final orderApi = ref.read(orderApiProvider);

  // SỬA: Lấy danh sách chi nhánh để tổng hợp dữ liệu.
  final branches = await ref.watch(branchListProvider.future);
  double totalRevenue = 0.0;
  int totalOrders = 0;

  if (branches.isNotEmpty) {
    // Gọi API doanh thu và đơn hàng cho từng chi nhánh trong 12 tháng qua.
    final revenueFutures = branches.map((b) => paymentApi.fetchRevenueTrends('monthly', companyId, b.id, 12));
    final orderFutures = branches.map((b) => orderApi.fetchOrderCount('monthly', companyId, b.id, 12));

    final revenueResults = await Future.wait(revenueFutures);
    final orderResults = await Future.wait(orderFutures);

    // Tính tổng doanh thu từ tất cả các chi nhánh.
    for (var result in revenueResults) {
      totalRevenue += result.fold<double>(0.0, (sum, item) => sum + item.value);
    }
    // Tính tổng đơn hàng từ tất cả các chi nhánh.
    for (var result in orderResults) {
      totalOrders += result.fold<int>(0, (sum, item) => sum + item.count);
    }
  }
 return {
  "total_revenue": totalRevenue,
  "total_orders": totalOrders,
  "total_branches": branchCount.toString(),
  "total_staff": staffCount.toString(),
  "service_package": "Free", // Dữ liệu giả lập, cần API từ backend
  "service_status": "Đang sử dụng", // Dữ liệu giả lập, cần API từ backend
 };
});