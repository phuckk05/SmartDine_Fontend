// file: providers/staff_branch_relation_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider này chứa Map thể hiện mối quan hệ: UserId (key) -> BranchId (value)
final staffBranchRelationProvider =
    StateNotifierProvider<StaffBranchRelationNotifier, Map<int, int>>((ref) {
  return StaffBranchRelationNotifier();
});

class StaffBranchRelationNotifier extends StateNotifier<Map<int, int>> {
  StaffBranchRelationNotifier() : super(_initialRelations);

  // Dữ liệu giả lập:
  static final Map<int, int> _initialRelations = {
    101: 101, // Phúc -> CN A
    103: 101, // Anh D -> CN A
    102: 102, // Chị B -> CN B
    104: 103, // Chị E -> CN B
  };

  /// Gán hoặc cập nhật chi nhánh cho một nhân viên
  void assignStaffToBranch(int userId, int branchId) {
    // Tạo bản sao của state hiện tại để chỉnh sửa
    final currentRelations = Map<int, int>.from(state);
    // Cập nhật hoặc thêm mới quan hệ
    currentRelations[userId] = branchId;
    // Cập nhật state
    state = currentRelations;
  }

  // (Bạn có thể thêm hàm unassignStaff(int userId) nếu cần)
}