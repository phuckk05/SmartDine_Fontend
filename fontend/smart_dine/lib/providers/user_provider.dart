import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mart_dine/API/branch_API.dart';
import 'package:mart_dine/API/user_API.dart';
import 'package:mart_dine/API/user_branch_API.dart';
import 'package:mart_dine/models/branch.dart';
import 'package:mart_dine/models/user.dart';

class UserNotifier extends StateNotifier<User?> {
  final UserAPI userAPI;
  final BranchAPI branchAPI;
  final UserBranchAPI userBranchAPI;

  UserNotifier(this.userAPI, this.branchAPI, this.userBranchAPI) : super(null);

  // Đăng ký user
  Future<int> signUp(User user, String branchCode) async {
    // Gọi API để tìm chi nhánh
    final Branch? branch;
    bool check = false;
    try {
      branch = await branchAPI.findBranchByBranchCode(branchCode);
      if (branch != null) {
        check = true;
      } else {
        return 1;
      }
      if (check == true) {
        try {
          final registerSuccess = await userAPI.create(user);
          if (registerSuccess != null) {
            // Cập nhật state sau khi đăng ký thành công
            state = registerSuccess;
            print("User ${user}");
            print("State ${state}");
            print("Branch ${branch}");
            try {
              final responseUserBranch = await userBranchAPI.create(
                registerSuccess.id!.toInt(),
                branch.id.toInt(),
              );
              if (responseUserBranch == true) {
                return 2;
              }
            } catch (e) {
              print("Loi 3 :  $e");
            }
          } else {
            return 3;
          }
        } catch (e) {
          // ignore: avoid_print
          print('Lỗi 2 :  $e');
        }
      }
    } catch (e) {
      // ignore: avoid_print
      print('loi 1  $e');
    }
    return 0;
  }
}

final userNotifierProvider = StateNotifierProvider<UserNotifier, User?>((ref) {
  final userApi = ref.read(userApiProvider);
  final branchApi = ref.read(branchApiProvider);
  final userBranchApi = ref.read(userBranchApiProvider);
  return UserNotifier(userApi, branchApi, userBranchApi);
});
