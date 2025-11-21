import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mart_dine/API/branch_API.dart';
import 'package:mart_dine/API/company_API.dart';
import 'package:mart_dine/API/user_API.dart';
import 'package:mart_dine/API/user_branch_API.dart';
import 'package:mart_dine/models/branch.dart';

class BranchNotifier extends StateNotifier<AsyncValue<List<Branch>>> {
  final BranchAPI branchAPI;
  final UserAPI userAPI;
  final CompanyAPI companyAPI;
  final UserBranchAPI userBranchAPI;
  BranchNotifier(
    this.branchAPI,
    this.userAPI,
    this.companyAPI,
    this.userBranchAPI,
  ) : super(const AsyncValue.data([]));

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
      print('Response Company: $responseCompany');
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
        print('Branch Payload: $branchCreate');
        final response = await branchAPI.create(branchCreate);
        if (response != null) {
          //Cập nhạt state
          state = AsyncValue.data([...state.value!, response]);
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
      print('Error getting branch by manager ID: $e');
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

  //   // Lấy branchId theo userId
  //   Future<int?> getBranchIdByUserId(int userId) async {
  //     try {
  //       final userBranchData = await userBranchAPI.getBranchByUserId(userId);
  //       if (userBranchData != null && userBranchData['branchId'] != null) {
  //         return userBranchData['branchId'] as int;
  //       }
  //       print('Không tìm thấy branchId cho userId: $userId');
  //       return null;
  //     } catch (e) {
  //       print('Lỗi lấy branchId: $e');
  //       return null;
  //     }
  //   }
}

final branchNotifierProvider =
    StateNotifierProvider<BranchNotifier, AsyncValue<List<Branch>>>((ref) {
      return BranchNotifier(
        ref.watch(branchApiProvider),
        ref.watch(userApiProvider),
        ref.watch(companyApiProvider),
        ref.watch(userBranchApiProvider),
      );
    });
