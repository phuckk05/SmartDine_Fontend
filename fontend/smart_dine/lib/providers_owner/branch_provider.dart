// file: providers/branch_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mart_dine/models_owner/user.dart';
import 'package:mart_dine/models_owner/branch.dart';
import 'package:mart_dine/API_owner/branch_API.dart';
import 'package:mart_dine/API_owner/user_API.dart'; // SỬA: Import user API
import 'package:mart_dine/providers_owner/system_stats_provider.dart';
import 'package:mart_dine/providers_owner/target_provider.dart'; // Để invalidate branchListProvider

// Provider lấy danh sách chi nhánh đang chờ duyệt (statusId = 3)
final pendingBranchesProvider = FutureProvider<List<Branch>>((ref) async {
  final branchApi = ref.watch(branchApiProvider);
  // SỬA: Lấy companyId trực tiếp từ owner profile
  final companyId = (await ref.watch(ownerProfileProvider.future)).companyId;

  if (companyId == null) {
    return []; // Không có công ty thì không có chi nhánh
  }

  final allBranches = await branchApi.fetchBranchesByCompanyId(companyId);
  // Lọc những chi nhánh có statusId = 3
  return allBranches.where((branch) => branch.statusId == 3).toList();
});

// THÊM: Provider để lấy thông tin chi tiết của một chi nhánh
final branchDetailProvider = FutureProvider.family<Branch, int>((ref, branchId) async {
  final branchApi = ref.watch(branchApiProvider);
  // Giả định API có hàm fetchBranchById
  return await branchApi.fetchBranchById(branchId);
});

// StateNotifier để xử lý các hành động cập nhật chi nhánh
final branchUpdateNotifierProvider =
    StateNotifierProvider<BranchUpdateNotifier, AsyncValue<void>>((ref) {
  return BranchUpdateNotifier(ref);
});

class BranchUpdateNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;
  BranchUpdateNotifier(this._ref) : super(const AsyncValue.data(null));

  // Hàm để duyệt một chi nhánh
  Future<void> approveBranch(Branch branchToApprove) async {
    state = const AsyncValue.loading(); // Bắt đầu trạng thái loading

    final branchApi = _ref.read(branchApiProvider);
    final userApi = _ref.read(userApiProvider); // SỬA: Lấy user API provider

    try {
      // SỬA: Tạo một bản sao của chi nhánh với statusId được cập nhật
      final approvedBranch = branchToApprove.copyWith(
        statusId: 1, // 1 = Đã duyệt
        updatedAt: DateTime.now(),
      );

      // 1. Gọi API để cập nhật chi nhánh
      await branchApi.updateBranch(branchToApprove.id, approvedBranch);

      // 2. Gọi API để duyệt luôn tài khoản quản lý của chi nhánh đó
      // Giả định rằng branchToApprove có trường managerId
      if (branchToApprove.managerId != null) {
        // SỬA LỖI: Phương thức updateUser yêu cầu một đối tượng User.
        // 1. Lấy thông tin người dùng hiện tại.
        final managerUser = await userApi.fetchUserById(branchToApprove.managerId!);
        // 2. Tạo một bản sao với statusId được cập nhật.
        final updatedManager = managerUser.copyWith(
          statusId: 1, // 1 = Đã duyệt
        );
        // 3. Gửi đối tượng đã cập nhật đến API.
        await userApi.updateUser(branchToApprove.managerId!, updatedManager);
      }

      // Làm mới lại các provider liên quan để UI tự cập nhật
      _ref.invalidate(pendingBranchesProvider); // Danh sách chờ duyệt
      _ref.invalidate(branchListProvider); // Danh sách tổng

      state = const AsyncValue.data(null); // Kết thúc loading, thành công
    } catch (e, s) {
      state = AsyncValue.error(e, s); // Báo lỗi nếu có
    }
  }
}