// file: providers/item_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mart_dine/API_owner/item_API.dart';
import 'package:mart_dine/models_owner/item.dart';
import 'package:mart_dine/providers_owner/system_stats_provider.dart';
import 'package:mart_dine/providers_owner/menu_item_relation_provider.dart';

final itemsByCategoryProvider =
    FutureProvider.family<List<Item>, int>((ref, categoryId) async {
  final api = ref.watch(itemApiProvider);
  // SỬA: Lấy companyId trực tiếp từ owner profile
  final companyId = (await ref.watch(ownerProfileProvider.future)).companyId;
  if (companyId == null) {
    throw Exception('Company ID not available');
  }
  return api.fetchItemsByCategory(companyId, categoryId);
});

// Provider để đọc (allItemsProvider) - Giữ nguyên
final allItemsProvider = FutureProvider<List<Item>>((ref) async {
  final api = ref.watch(itemApiProvider);
  // SỬA: Lấy companyId trực tiếp từ owner profile
  final companyId = (await ref.watch(ownerProfileProvider.future)).companyId;
  if (companyId == null) {
    throw Exception('Company ID not available');
  }
  return api.fetchAllItems(companyId);
});

// 2. StateNotifier để xử lý các hành động CUD
class ItemUpdateNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;
  ItemUpdateNotifier(this._ref) : super(const AsyncValue.data(null));

  // SỬA: Hàm addItem giờ nhận 4 tham số theo yêu cầu của bạn
  Future<void> addItem(String name, double price, int categoryId, int companyId) async {
    state = const AsyncValue.loading();
    try {
      final api = _ref.read(itemApiProvider);
      // Không cần tự lấy companyId nữa, vì nó đã được truyền vào
      await api.addItem(name, price, categoryId, companyId);
      _ref.invalidate(itemsByCategoryProvider(categoryId));
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  // (Các hàm editItem và deleteItem giữ nguyên)
  Future<void> editItem(
      Item item, String newName, double newPrice, int categoryId) async {
    state = const AsyncValue.loading();
    try {
      final api = _ref.read(itemApiProvider);
      await api.updateItem(item.id, newName, newPrice);
      _ref.invalidate(itemsByCategoryProvider(categoryId));
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

 Future<void> deleteItem(Item item, int categoryId) async {
    state = const AsyncValue.loading();
    try {
      final api = _ref.read(itemApiProvider);
      // Truyền cả item.id và categoryId cho API
      await api.deleteItem(item.id, categoryId); 
      _ref.invalidate(itemsByCategoryProvider(categoryId));
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

// 3. Provider cho StateNotifier
final itemUpdateNotifierProvider =
    StateNotifierProvider<ItemUpdateNotifier, AsyncValue<void>>(
        (ref) => ItemUpdateNotifier(ref));