// file: lib/providers/user_list_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mart_dine/models_owner/user.dart';
import 'package:mart_dine/API_owner/user_API.dart'; // Import UserAPI

// FutureProvider để lấy danh sách tất cả User từ API
final userListProvider = FutureProvider<List<User>>((ref) async {
  final apiService = ref.watch(userApiProvider);
  return apiService.fetchUsers();
});

// Provider để lấy User theo ID (tối ưu hơn là gọi API mỗi lần)
final userByIdProvider = FutureProvider.family<User?, int>((ref, userId) async {
  // Thử đọc từ list đã tải
  final userListAsync = ref.watch(userListProvider);
  if (userListAsync.hasValue) {
    try {
      return userListAsync.value!.firstWhere((user) => user.id == userId);
    } catch (e) {
      // Không tìm thấy trong list, gọi API
    }
  }
  // Nếu list chưa có hoặc không tìm thấy, gọi API
  final apiService = ref.watch(userApiProvider);
  return apiService.fetchUserById(userId);
});