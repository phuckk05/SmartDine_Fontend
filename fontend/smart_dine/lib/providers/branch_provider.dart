import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mart_dine/API/branch_API.dart';
import 'package:mart_dine/API/company_API.dart';
import 'package:mart_dine/API/user_branch_API.dart';
import 'package:mart_dine/models/branch.dart';

class BranchNotifier extends StateNotifier<Branch?> {
  final BranchAPI branchAPI;
  final CompanyAPI companyAPI;
  final UserBranchAPI userBranchAPI;
  BranchNotifier(this.branchAPI, this.companyAPI, this.userBranchAPI)
    : super(null);

  Set<Branch> build() {
    return const {};
  }

  //Đăng kí chi nhánh
  Future<int> signUpBranch(
    Branch branch,
    int userId,
    String companyCode,
  ) async {
    try {
      final responseCompany = await companyAPI.exitsCompanyCode(companyCode);
      if (responseCompany != null) {
        final branchPayload = branch.copyWith(companyId: responseCompany.id);
        final response = await branchAPI.create(branchPayload);
        if (response != null) {
          //Cập nhạt state
          state = response;
          return 1;
        }
      } else {
        return 2;
      }
    } catch (e) {
      print("Tìm không thấy companyCode : ${e.toString()}");
    }
    return 0;
  }

  // Lấy branchId theo userId
  Future<int?> getBranchIdByUserId(int userId) async {
    try {
      final userBranchData = await userBranchAPI.getBranchByUserId(userId);
      if (userBranchData != null && userBranchData['branchId'] != null) {
        return userBranchData['branchId'] as int;
      }
      print('Không tìm thấy branchId cho userId: $userId');
      return null;
    } catch (e) {
      print('Lỗi lấy branchId: $e');
      return null;
    }
  }

  // Lấy companyId theo branchId
  Future<int?> getCompanyIdByBranchId(int branchId) async {
    try {
      final branch = await branchAPI.getBranchById(branchId);
      if (branch != null) {
        return branch.companyId;
      }
      print('Không tìm thấy branch với id: $branchId');
      return null;
    } catch (e) {
      print('Lỗi lấy companyId từ branchId: $e');
      return null;
    }
  }
}

final branchNotifierProvider = StateNotifierProvider<BranchNotifier, Branch?>((
  ref,
) {
  return BranchNotifier(
    ref.watch(branchApiProvider),
    ref.watch(companyApiProvider),
    ref.watch(userBranchApiProvider),
  );
});
