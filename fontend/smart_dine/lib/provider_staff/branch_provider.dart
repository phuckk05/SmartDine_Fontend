import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mart_dine/API_staff/branch_API.dart';
import 'package:mart_dine/API_staff/company_API.dart';
import 'package:mart_dine/API_staff/user_branch_API.dart';

import 'package:mart_dine/model_staff/branch.dart';

class BranchNotifier extends StateNotifier<AsyncValue<List<Branch>>> {
  final BranchAPI branchAPI;
  final CompanyAPI companyAPI;
  final UserBranchAPI userBranchAPI;
  BranchNotifier(this.branchAPI, this.companyAPI, this.userBranchAPI)
    : super(const AsyncValue.loading());

  Set<Branch> build() {
    return const {};
  }

  // Load branches by company ID
  Future<void> loadBranchesByCompanyId(int companyId) async {
    state = const AsyncValue.loading();
    try {
      final branches = await branchAPI.getBranchesByCompanyId(companyId);
      state = AsyncValue.data(branches ?? []);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
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
          state = AsyncValue.data([response]);
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
}

final branchNotifierProvider2 =
    StateNotifierProvider<BranchNotifier, AsyncValue<List<Branch>>>((ref) {
      return BranchNotifier(
        ref.watch(branchApiProvider2),
        ref.watch(companyApiProvider),
        ref.watch(userBranchApiProvider),
      );
    });
