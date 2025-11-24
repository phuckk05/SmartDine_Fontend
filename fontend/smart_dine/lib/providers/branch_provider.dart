import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mart_dine/API/branch_API.dart';
import 'package:mart_dine/API/company_API.dart';
import 'package:mart_dine/API/user_API.dart';
import 'package:mart_dine/API/user_branch_API.dart';
import 'package:mart_dine/models/branch.dart';

class BranchNotifier extends StateNotifier<Branch?> {
  final BranchAPI branchAPI;
  final UserAPI userAPI;
  final CompanyAPI companyAPI;
  final UserBranchAPI userBranchAPI;
  BranchNotifier(
    this.branchAPI,
    this.companyAPI,
    this.userBranchAPI,
    this.userAPI,
  ) : super(null);

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
      // print('Response Company: $responseCompany');

      if (responseCompany != null) {
        final branchPayload = branch.copyWith(companyId: responseCompany.id);
        final branchCreate = Branch.create(
          companyId: branchPayload.companyId,
          name: branchPayload.name,
          branchCode: branchPayload.branchCode,
          address: branchPayload.address,
          image: branchPayload.image,
          managerId: branchPayload.managerId,
        );
        // print('Branch Payload: $branchCreate');
        final response = await branchAPI.create(branchCreate);
        if (response != null) {
          //Cập nhạt state
          state = response;
          //Cập nhật bảng user_branch
          // await userBranchAPI.create(userId, response.id!);
          await userAPI.updateCompanyId(userId, responseCompany.id!);
          return 1;
        }
      } else {
        return 2;
      }
    } catch (e) {}
    return 0;
  }

  // Lấy branchId theo userId (cho Staff, Chef từ user_branches)
  Future<int?> getBranchIdByUserId(int userId) async {
    try {
      final userBranchData = await userBranchAPI.getBranchByUserId(userId);
      if (userBranchData != null && userBranchData['branchId'] != null) {
        return userBranchData['branchId'] as int;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Lấy branchId theo managerId (cho Manager từ bảng branches)
  Future<int?> getBranchIdByManagerId(int managerId) async {
    try {
      final branch = await branchAPI.getBranchByManagerId(managerId);
      if (branch != null) {
        return branch.id;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Lấy companyId theo branchId
  Future<int?> getCompanyIdByBranchId(int branchId) async {
    try {
      final branch = await branchAPI.getBranchById(branchId.toString());
      if (branch != null) {
        return branch.companyId;
      }
      return null;
    } catch (e) {
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
    ref.watch(userApiProvider),
  );
});
