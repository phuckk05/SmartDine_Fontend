import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mart_dine/API/branch_API.dart';
import 'package:mart_dine/models/branch.dart';

class BranchesNotifier extends StateNotifier<List<Branch>> {
  final BranchAPI branchAPI;
  BranchesNotifier(this.branchAPI) : super([]);

  List<Branch> build() {
    return state;
  }

  // Lấy tất cả các chi nhánh
  Future<void> fetchBranches() async {
    final branches = await branchAPI.getAllBranches();
    state = branches;
  }
}

final BranchesNotifierProvider =
    StateNotifierProvider<BranchesNotifier, List<Branch>>((ref) {
      return BranchesNotifier(ref.read(branchApiProvider));
    });
