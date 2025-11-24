// file: providers/target_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mart_dine/models_owner/target.dart'; 
// SỬA: Import model Branch
import 'package:mart_dine/models_owner/branch.dart'; 
import 'package:mart_dine/API_owner/branch_API.dart';
// THÊM: Import provider để lấy companyId của owner
import 'package:mart_dine/providers_owner/system_stats_provider.dart';
// -----------------------------------------------------------------------------
// 1. Target List Provider (StateNotifierProvider)
// -----------------------------------------------------------------------------
// (Phần TargetListNotifier giữ nguyên, không thay đổi)
final targetListProvider =
    StateNotifierProvider<TargetListNotifier, List<Target>>(
        (ref) => TargetListNotifier());

class TargetListNotifier extends StateNotifier<List<Target>> {
  TargetListNotifier() : super(_initialTargets);

  // Dữ liệu mẫu ban đầu
  static final List<Target> _initialTargets = [
    Target(
      id: 1,
      branchId: 101, // <<< Khớp với ID của Chi nhánh A
      targetAmount: 50000000.0,
      targetType: 'Năm',
      startDate: DateTime(2025, 1, 1),
      endDate: DateTime(2025, 12, 31),
      createdAt: DateTime(2024, 1, 15),
      updatedAt: DateTime(2024, 1, 15),
    ),
    Target(
      id: 2,
      branchId: 102, // <<< Khớp với ID của Chi nhánh B
      targetAmount: 15000000.0,
      targetType: 'Tháng',
      startDate: DateTime(2025, 10, 1),
      endDate: DateTime(2025, 10, 31),
      createdAt: DateTime(2024, 1, 15),
      updatedAt: DateTime(2024, 1, 15),
    ),
     Target(
      id: 3,
      branchId: 101, // <<< Khớp với ID của Chi nhánh A
      targetAmount: 25000000.0,
      targetType: 'Tháng',
      startDate: DateTime(2025, 10, 21),
      endDate: DateTime(2025, 10, 31),
      createdAt: DateTime(2024, 1, 16),
      updatedAt: DateTime(2024, 1, 16),
    ),
    Target(
      id: 4,
      branchId: 103, // ID của Chi nhánh C
      targetAmount: 30000000.0,
      targetType: 'Tháng',
      startDate: DateTime(2025, 11, 1),
      endDate: DateTime(2025, 11, 30),
      createdAt: DateTime(2024, 1, 17),
      updatedAt: DateTime(2024, 1, 17),
    ),
  ];

  /// Thêm một chỉ tiêu mới.
  void addTarget(Target newTarget) {
    final targetWithId = newTarget.copyWith(
      id: state.isEmpty ? 1 : state.map((t) => t.id).reduce((a, b) => a > b ? a : b) + 1,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    state = [targetWithId, ...state];
  }
  
  /// Cập nhật chỉ tiêu
  void updateTarget(Target updatedTarget) {
    state = [
      for (final target in state)
        if (target.id == updatedTarget.id) updatedTarget else target,
    ];
  }
}

final branchesByCompanyProvider = FutureProvider.family<List<Branch>, int>((ref, companyId) async {
  final apiService = ref.watch(branchApiProvider);
  return apiService.fetchBranchesByCompanyId(companyId);
});
// -----------------------------------------------------------------------------
// 2. Branch List Provider (StateNotifierProvider)
// -----------------------------------------------------------------------------
/// Quản lý danh sách các chi nhánh.
// SỬA: Thay thế List<Map<String, String>> bằng List<Branch>
// SỬA: Provider này sẽ lấy danh sách chi nhánh cho công ty hiện tại của người dùng.
final branchListProvider = FutureProvider<List<Branch>>((ref) async {
  // 1. Lấy companyId của owner đang đăng nhập.
  // SỬA: Lấy trực tiếp từ ownerProfileProvider
  final owner = await ref.watch(ownerProfileProvider.future);
  final companyId = owner.companyId;
  // 2. Nếu không có companyId, trả về danh sách rỗng.
  if (companyId == null) {
    return [];
  }
  // 3. Gọi provider khác để lấy chi nhánh theo companyId.
  return ref.watch(branchesByCompanyProvider(companyId).future);
});