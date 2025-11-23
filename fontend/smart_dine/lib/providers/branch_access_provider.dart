import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../API/user_permissions_API.dart'; // File not found - commented out
import '../models/branch.dart';
import 'user_session_provider.dart';

// Provider để lấy danh sách branches mà user có quyền truy cập
final userAccessibleBranchesProvider = FutureProvider<List<Branch>>((ref) async {
  final userSession = ref.read(userSessionProvider);
  final userId = userSession.userId;
  
  if (userId == null) return [];
  
  // Temporarily return empty list until permissions API is implemented
  return [];
});

// Provider để kiểm tra user có quyền truy cập branch cụ thể không
final branchAccessProvider = FutureProvider.family<bool, int>((ref, branchId) async {
  final userSession = ref.read(userSessionProvider);
  final userId = userSession.userId;
  
  if (userId == null) return false;
  
  // Temporarily allow access to all branches
  return true;
});

// Provider để validate current branch access
final currentBranchValidationProvider = FutureProvider<bool>((ref) async {
  final userSession = ref.read(userSessionProvider);
  final userId = userSession.userId;
  final branchId = userSession.currentBranchId;
  
  if (userId == null || branchId == null) return false;
  
  // Temporarily allow access to current branch
  return true;
});