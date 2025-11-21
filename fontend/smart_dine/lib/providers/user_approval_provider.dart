import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../API/user_approval_API.dart';
import '../models/user.dart';

// Provider cho UserApprovalAPI
final userApprovalApiProvider = Provider<UserApprovalAPI>((ref) {
  return UserApprovalAPI();
});

// Provider cho danh sách users chờ duyệt theo branch
final pendingUsersByBranchProvider = FutureProvider.family<List<User>, int>((ref, branchId) async {
  final api = ref.read(userApprovalApiProvider);
  return await api.getPendingUsersByBranch(branchId);
});

// Provider cho danh sách users chờ duyệt theo company
final pendingUsersByCompanyProvider = FutureProvider.family<List<User>, int>((ref, companyId) async {
  final api = ref.read(userApprovalApiProvider);
  return await api.getPendingUsersByCompany(companyId);
});

// Provider cho thống kê pending users
final pendingStatisticsProvider = FutureProvider.family<Map<String, int>, int>((ref, companyId) async {
  final api = ref.read(userApprovalApiProvider);
  return await api.getPendingStatistics(companyId);
});

// StateNotifier cho việc quản lý user approval
class UserApprovalNotifier extends StateNotifier<AsyncValue<List<User>>> {
  final UserApprovalAPI _api;
  final int _branchId;

  UserApprovalNotifier(this._api, this._branchId) : super(const AsyncValue.loading()) {
    loadPendingUsers();
  }

  Future<void> loadPendingUsers() async {
    try {
      state = const AsyncValue.loading();
      final users = await _api.getPendingUsersByBranch(_branchId);
      state = AsyncValue.data(users);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<bool> approveUser(int userId) async {
    try {
      final success = await _api.approveUser(userId);
      if (success) {
        await loadPendingUsers();
      }
      return success;
    } catch (e) {
      print('Error approving user: $e');
      return false;
    }
  }

  Future<bool> rejectUser(int userId, String reason) async {
    try {
      final success = await _api.rejectUser(userId, reason);
      if (success) {
        await loadPendingUsers();
      }
      return success;
    } catch (e) {
      print('Error rejecting user: $e');
      return false;
    }
  }

  Future<bool> blockUser(int userId, String reason) async {
    try {
      final success = await _api.blockUser(userId, reason);
      if (success) {
        await loadPendingUsers();
      }
      return success;
    } catch (e) {
      print('Error blocking user: $e');
      return false;
    }
  }
}

// Provider cho UserApprovalNotifier
final userApprovalProvider = StateNotifierProvider.family<UserApprovalNotifier, AsyncValue<List<User>>, int>((ref, branchId) {
  final api = ref.read(userApprovalApiProvider);
  return UserApprovalNotifier(api, branchId);
});