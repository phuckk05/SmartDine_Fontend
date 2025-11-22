import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mart_dine/API/branch_API.dart';
import 'package:mart_dine/models/branch.dart';
import 'user_session_provider.dart';

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

// Provider để lấy branch theo ID
final branchByIdProvider = FutureProvider.family<Branch?, String>((ref, branchId) async {
  final branchAPI = ref.read(branchApiProvider);
  return await branchAPI.getBranchById(branchId);
});

// Provider để lấy branch hiện tại từ session
final currentBranchProvider = FutureProvider<Branch?>((ref) async {
  final currentBranchId = ref.watch(currentBranchIdProvider);
  if (currentBranchId == null) return null;
  
  final branchAPI = ref.read(branchApiProvider);
  return await branchAPI.getBranchById(currentBranchId.toString());
});
