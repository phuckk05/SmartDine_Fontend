import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../API/user_approval_API.dart';
import '../models/user.dart';

// Provider cho danh sách user chờ duyệt theo companyId
final pendingUsersByCompanyProvider = FutureProvider.family<List<User>, int>((ref, companyId) async {
  final api = ref.read(userApprovalAPIProvider);
  return await api.getPendingUsersByCompany(companyId);
});

// Provider cho danh sách user chờ duyệt theo branchId
final pendingUsersByBranchProvider = FutureProvider.family<List<User>, int>((ref, branchId) async {
  final api = ref.read(userApprovalAPIProvider);
  return await api.getPendingUsersByBranch(branchId);
});

// Provider cho thống kê user chờ duyệt
final pendingStatisticsProvider = FutureProvider.family<Map<String, int>?, int>((ref, companyId) async {
  final api = ref.read(userApprovalAPIProvider);
  return await api.getPendingStatistics(companyId);
});

// StateNotifier để quản lý các action duyệt/từ chối
class UserApprovalNotifier extends StateNotifier<AsyncValue<List<User>>> {
  final UserApprovalAPI _api;
  final int companyId;
  
  UserApprovalNotifier(this._api, this.companyId) : super(const AsyncValue.loading()) {
    loadPendingUsers();
  }
  
  // Load lại danh sách user chờ duyệt
  Future<void> loadPendingUsers() async {
    try {
      state = const AsyncValue.loading();
      final users = await _api.getPendingUsersByCompany(companyId);
      state = AsyncValue.data(users);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
  
  // Duyệt user
  Future<bool> approveUser(int userId) async {
    try {
      final success = await _api.approveUser(userId);
      if (success) {
        // Reload danh sách sau khi duyệt thành công
        await loadPendingUsers();
      }
      return success;
    } catch (e) {
      print('Error in approveUser: $e');
      return false;
    }
  }
  
  // Từ chối user
  Future<bool> rejectUser(int userId, {String? reason}) async {
    try {
      final success = await _api.rejectUser(userId, reason: reason);
      if (success) {
        // Reload danh sách sau khi từ chối thành công
        await loadPendingUsers();
      }
      return success;
    } catch (e) {
      print('Error in rejectUser: $e');
      return false;
    }
  }
  
  // Khóa user
  Future<bool> blockUser(int userId, {String? reason}) async {
    try {
      final success = await _api.blockUser(userId, reason: reason);
      if (success) {
        // Reload danh sách sau khi khóa thành công
        await loadPendingUsers();
      }
      return success;
    } catch (e) {
      print('Error in blockUser: $e');
      return false;
    }
  }
}

// Provider cho UserApprovalNotifier
final userApprovalNotifierProvider = StateNotifierProvider.family<UserApprovalNotifier, AsyncValue<List<User>>, int>((ref, companyId) {
  final api = ref.read(userApprovalAPIProvider);
  return UserApprovalNotifier(api, companyId);
});

// Provider đếm số lượng user chờ duyệt (dùng cho badge)
final pendingUsersCountProvider = Provider.family<int, int>((ref, companyId) {
  final pendingUsers = ref.watch(pendingUsersByCompanyProvider(companyId));
  return pendingUsers.when(
    data: (users) => users.length,
    loading: () => 0,
    error: (_, __) => 0,
  );
});