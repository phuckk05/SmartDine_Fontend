// file: lib/providers/staff_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mart_dine/models_owner/user.dart';
import 'package:mart_dine/models_owner/role.dart';
import 'package:mart_dine/models_owner/staff_profile.dart';
// Import API Providers
import 'package:mart_dine/API_owner/user_API.dart';
import 'package:mart_dine/API_owner/role_API.dart';
import 'package:mart_dine/API_owner/user_branch_API.dart';
// Import providers
import 'package:mart_dine/providers_owner/role_provider.dart'; // roleListProvider

// 1. Provider lấy danh sách quan hệ User-Branch (UserId -> BranchId)
final userBranchRelationProvider = FutureProvider<Map<int, List<int>>>((ref) async {
  final apiService = ref.watch(userBranchApiProvider);
  final relationsList = await apiService.fetchAllRelations(); // Lấy List<UserBranch>
  
  // Chuyển List<UserBranch> thành Map<UserId, List<BranchId>>
  final Map<int, List<int>> userToBranchesMap = {};
  for (var relation in relationsList) {
    userToBranchesMap.putIfAbsent(relation.userId, () => []).add(relation.branchId);
  }
  return userToBranchesMap;
});

// 2. Provider lấy danh sách StaffProfile (User + Role)
final staffProfileProvider = FutureProvider<List<StaffProfile>>((ref) async {
  // Lấy các API services
  final userApi = ref.watch(userApiProvider);
  // Chờ danh sách Role tải xong
  final roleList = await ref.watch(roleListProvider.future);

  // Gọi API để lấy danh sách User
  final users = await userApi.fetchUsers();

  // Tạo Map RoleId (int) -> Role để tra cứu nhanh
  final roleMap = {for (var role in roleList) role.id: role};
  final defaultRole = Role(id: 0, code: 'unknown', name: 'Không rõ', description: '');

  // Kết hợp User và Role
  List<StaffProfile> profiles = [];
  for (var user in users) {
     // Lấy RoleId (int) từ User (đã sửa model User)
     final roleId = user.role ?? 0;
     final role = roleMap[roleId] ?? defaultRole; // Tra cứu Role object
     
     profiles.add(StaffProfile(user: user, role: role));
  }
  return profiles;
});


// 3. StateNotifier để quản lý cập nhật (Sửa, Xóa, Khóa, Gán)
final staffProfileUpdateNotifierProvider =
    StateNotifierProvider<StaffProfileUpdateNotifier, AsyncValue<void>>((ref) {
  return StaffProfileUpdateNotifier(ref);
});

class StaffProfileUpdateNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;
  StaffProfileUpdateNotifier(this._ref) : super(const AsyncValue.data(null));

  // Hàm gọi API update User
  Future<void> updateUserProfile(User updatedUser, Role newRole) async {
    final userApi = _ref.read(userApiProvider);
    state = const AsyncValue.loading();
    try {
      // Gán roleId (int) vào user object
      final userWithNewRole = updatedUser.copyWith(
          role: newRole.id
      );
      
      await userApi.updateUser(updatedUser.id!, userWithNewRole);
      
      // Refresh lại provider gốc để lấy dữ liệu mới
      _ref.refresh(staffProfileProvider);
      state = const AsyncValue.data(null);
    } catch (e, s) {
      print("Lỗi cập nhật user profile: $e");
      state = AsyncValue.error(e, s);
    }
  }

   // Gọi API Delete User
   Future<void> deleteUser(int userId) async {
       final userApi = _ref.read(userApiProvider);
       state = const AsyncValue.loading();
       try {
          final success = await userApi.deleteUser(userId);
          if (success) {
             _ref.refresh(staffProfileProvider); // Refresh list
             _ref.refresh(userBranchRelationProvider); // Refresh quan hệ
             state = const AsyncValue.data(null);
          } else {
             throw Exception("Xóa người dùng không thành công từ API.");
          }
       } catch (e, s) {
          print("Lỗi xóa user: $e");
          state = AsyncValue.error(e, s);
       }
   }

   // Gọi API Update User để thay đổi Status (Lock/Unlock)
   Future<void> toggleUserStatus(User user) async {
      final userApi = _ref.read(userApiProvider); // Lấy API service
      state = const AsyncValue.loading(); // Đặt trạng thái loading
      
      // Tạo user mới với statusId đảo ngược
      final updatedUser = user.copyWith(
          // SỬA: Chuyển đổi giữa 1 (Bình thường) và 2 (Đã khóa)
          statusId: user.statusId == 2 ? 1 : 2,
          updatedAt: DateTime.now()
      );

      try {
          // Gọi API updateUser với đối tượng user đã thay đổi statusId
          await userApi.updateUser(user.id!, updatedUser);
          
          // Tải lại danh sách profile để cập nhật UI
          _ref.refresh(staffProfileProvider); 
          state = const AsyncValue.data(null); // Đặt lại trạng thái
      } catch (e, s) {
          print("Lỗi toggle user status: $e");
          state = AsyncValue.error(e, s); // Báo lỗi
      }
   }

   // Gán nhân viên vào chi nhánh
   Future<void> assignStaffToBranch(int userId, int branchId) async {
      final userBranchApi = _ref.read(userBranchApiProvider);
      state = const AsyncValue.loading();
      try {
          await userBranchApi.assignUserToBranch(userId, branchId);
          _ref.refresh(userBranchRelationProvider); // Refresh list quan hệ
          state = const AsyncValue.data(null);
      } catch (e, s) {
          print("Lỗi gán nhân viên: $e");
          state = AsyncValue.error(e, s);
      }
   }
   // SỬA: Thêm branchId để biết xóa khỏi chi nhánh nào
   Future<void> unassignStaffFromBranch(int userId, int branchId) async {
      final userBranchApi = _ref.read(userBranchApiProvider);
      state = const AsyncValue.loading();
      try {
          await userBranchApi.unassignUserFromBranch(userId, branchId);
          // Refresh lại list quan hệ
          _ref.refresh(userBranchRelationProvider); 
          state = const AsyncValue.data(null);
      } catch (e, s) {
          print("Lỗi xóa nhân viên khỏi chi nhánh: $e");
          state = AsyncValue.error(e, s);
      }
   }
}