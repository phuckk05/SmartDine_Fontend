import 'package:bcrypt/bcrypt.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mart_dine/API/branch_API.dart';
import 'package:mart_dine/API/company_API.dart';
import 'package:mart_dine/API/user_API.dart';
import 'package:mart_dine/API/user_branch_API.dart';
import 'package:mart_dine/models/branch.dart';
import 'package:mart_dine/models/user.dart';

class UserNotifier extends StateNotifier<User?> {
  final UserAPI userAPI;
  final BranchAPI branchAPI;
  final UserBranchAPI userBranchAPI;
  final CompanyAPI companyAPI;

  UserNotifier(
    this.userAPI,
    this.branchAPI,
    this.userBranchAPI,
    this.companyAPI,
  ) : super(null);

  Set<User?> build() {
    return const {};
  }

  // Đăng ký user
  Future<int> signUpInfor(User user, String branchCode, int index) async {
    print(' user : $user');
    // Gọi API để tìm chi nhánh
    final Branch? branch;
    bool check = false;

    if (index == 1 || index == 2) {
      try {
        final registerSuccess = await userAPI.createUser(user);
        if (registerSuccess != null) {
          // Cập nhật state sau khi đăng ký thành công
          state = registerSuccess;
          return 2;
        } else {
          return 3;
        }
      } catch (e) {
        // ignore: avoid_print
        print('Lỗi 2 :  $e');
      }
    } else {
      try {
        branch = await branchAPI.findBranchByBranchCode(branchCode);
        if (branch != null) {
          check = true;
        } else {
          return 1;
        }
        if (check == true) {
          try {
            final registerSuccess = await userAPI.createUser(user);
            if (registerSuccess != null) {
              // Cập nhật state sau khi đăng ký thành công
              state = registerSuccess;
              try {
                final responseUserBranch = await userBranchAPI.create(
                  registerSuccess.id!.toInt(),
                  branch.id!.toInt(),
                );
                if (responseUserBranch == true) {
                  return 2;
                }
                return 4;
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
    }
    return 0;
  }

  Future<User?> signInInfor(String email, String password) async {
    print(' email : $email , password : $password');
    try {
      final user = await userAPI.signIn2(email);
      print(' User from API : ${user}');
      if (user != null) {
        print('do');
        // Cập nhật state sau khi đăng nhập thành công
        final isPasswordCorrect = BCrypt.checkpw(password, user.passworkHash);
        if (isPasswordCorrect) {
          state = user;
          return user;
        } else {
          return null;
        }
      } else {
        return null;
      }
    } catch (e) {
      print('Lỗi đăng nhập: $e');
      return null;
    }
  }

  //Cập nhật thông tin user
  Future<bool> updateUserInfor(int userId, String newPassword) async {
    try {
      final pwHash = BCrypt.hashpw(newPassword, BCrypt.gensalt());
      final updatedUser = await userAPI.updatePassword(userId, pwHash);
      if (updatedUser != null) {
        // Cập nhật state sau khi cập nhật thành công
        state = updatedUser;
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('Lỗi cập nhật thông tin user: $e');
      return false;
    }
  }

  // Lấy role từ user hiện tại
  int? getCurrentUserRole() {
    return state?.role;
  }

  // Đăng xuất
  void signOut() {
    state = null;
  }
}

final userNotifierProvider = StateNotifierProvider<UserNotifier, User?>((ref) {
  return UserNotifier(
    ref.read(userApiProvider),
    ref.read(branchApiProvider),
    ref.read(userBranchApiProvider),
    ref.read(companyApiProvider),
  );
});
