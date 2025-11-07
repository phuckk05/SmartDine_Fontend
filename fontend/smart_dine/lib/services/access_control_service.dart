import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/user_session_provider.dart';

// Provider để kiểm tra quyền truy cập
final accessControlProvider = Provider((ref) => AccessControlService(ref));

class AccessControlService {
  final Ref _ref;
  
  AccessControlService(this._ref);

  // Kiểm tra user có quyền truy cập branch không
  bool canAccessBranch(int branchId) {
    final session = _ref.read(userSessionProvider);
    return session.hasAccessToBranch(branchId);
  }

  // Lấy danh sách branchIds mà user có quyền
  List<int> getAccessibleBranches() {
    final session = _ref.read(userSessionProvider);
    return session.branchIds;
  }

  // Lấy branchId hiện tại
  int? getCurrentBranchId() {
    final session = _ref.read(userSessionProvider);
    return session.currentBranchId;
  }

  // Kiểm tra có phải admin không
  bool isAdmin() {
    final session = _ref.read(userSessionProvider);
    return session.isAdmin;
  }

  // Kiểm tra có phải manager không
  bool isManager() {
    final session = _ref.read(userSessionProvider);
    return session.isManager;
  }

  // Validate API call với branchId
  bool validateBranchAccess(int? requestedBranchId) {
    final session = _ref.read(userSessionProvider);
    
    // Nếu không authenticated
    if (!session.isAuthenticated) {
      return false;
    }

    // Admin có quyền tất cả
    if (session.isAdmin) {
      return true;
    }

    // Nếu không có requestedBranchId, dùng current branch
    final branchId = requestedBranchId ?? session.currentBranchId;
    
    if (branchId == null) {
      return false;
    }

    // Kiểm tra có quyền với branch này không
    return session.hasAccessToBranch(branchId);
  }

  // Lọc dữ liệu theo quyền truy cập
  List<T> filterByBranchAccess<T>(
    List<T> items,
    int Function(T) getBranchId,
  ) {
    final session = _ref.read(userSessionProvider);
    
    // Admin thấy tất cả
    if (session.isAdmin) {
      return items;
    }

    // Lọc theo branches có quyền
    return items.where((item) {
      final itemBranchId = getBranchId(item);
      return session.hasAccessToBranch(itemBranchId);
    }).toList();
  }

  // Exception khi không có quyền
  Exception accessDeniedException([String? message]) {
    return Exception(
      message ?? 
      'Bạn không có quyền truy cập dữ liệu này. Vui lòng liên hệ quản trị viên.'
    );
  }

  // Log thông tin truy cập (cho debugging)
  void logAccess(String action, int? branchId) {
    final session = _ref.read(userSessionProvider);
    print('🔒 ACCESS LOG: ${session.userName} (${session.userRole}) '
          'thực hiện "$action" trên branch $branchId');
  }
}