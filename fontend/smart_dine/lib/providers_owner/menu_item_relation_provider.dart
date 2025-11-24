// file: lib/providers/menu_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mart_dine/models_owner/categories.dart';
import 'package:mart_dine/models_owner/item.dart';
import 'package:mart_dine/API_owner/category_API.dart';
import 'package:mart_dine/API_owner/item_API.dart';
import 'package:mart_dine/providers_owner/system_stats_provider.dart';

// 1. Provider cho danh sách Category
// Chúng ta dùng FutureProvider vì chỉ cần hiển thị
final categoryListProvider = FutureProvider<List<Category>>((ref) async {
  final apiService = ref.watch(categoryApiProvider);
  // SỬA: Lấy companyId trực tiếp từ owner profile
  final companyId = (await ref.watch(ownerProfileProvider.future)).companyId;
  if (companyId == null) {
    // Nếu không có companyId, trả về danh sách rỗng để tránh lỗi
    return [];
  }
  return apiService.fetchCategoriesByCompany(companyId);
});

// 2. Provider cho danh sách Item (lọc theo categoryId)
// Dùng .family để truyền categoryId vào
final itemsByCategoryProvider = FutureProvider.family<List<Item>, int>((ref, categoryId) async {
  final apiService = ref.watch(itemApiProvider);
  // SỬA: Lấy companyId trực tiếp từ owner profile
  final companyId = (await ref.watch(ownerProfileProvider.future)).companyId;
  if (companyId == null) {
    throw Exception('Company ID not available');
  }
  return apiService.fetchItemsByCategory(companyId, categoryId);
});