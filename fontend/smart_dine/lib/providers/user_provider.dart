import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mart_dine/API/branch_API.dart';
import 'package:mart_dine/API/user_API.dart';
import 'package:mart_dine/models/branch.dart';
import 'package:mart_dine/models/user.dart';

class UserNotifier extends StateNotifier<User?> {
  final UserAPI userAPI;
  final BranchAPI branchAPI;

  UserNotifier(this.userAPI, this.branchAPI) : super(null);

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
            state = user;
            return 2;
          }
          return 3;
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
  return UserNotifier(userApi, branchApi);
});
