// file: providers/item_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mart_dine/API_owner/item_API.dart';
import 'package:mart_dine/API_owner/category_API.dart'; // THÊM: Import CategoryAPI
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
final allItemsProvider = FutureProvider.family<List<Item>, int>((ref, companyId) async {
  final api = ref.watch(itemApiProvider);
  return api.fetchAllItems(companyId);
});

// THÊM: Provider để lấy danh sách các món ăn thuộc về một menu cụ thể.
final itemsByMenuProvider =
    FutureProvider.family<List<Item>, int>((ref, menuId) async {
  // Lấy companyId từ profile của owner
  final companyId = (await ref.watch(ownerProfileProvider.future)).companyId;
  if (companyId == null) {
    // Nếu không có companyId, trả về danh sách rỗng để tránh lỗi.
    return [];
  }
  // Gọi API để lấy danh sách món ăn theo menuId
  return ref.watch(itemApiProvider).fetchItemsByMenu(companyId, menuId);
});

// 2. StateNotifier để xử lý các hành động CUD
class ItemUpdateNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;
  ItemUpdateNotifier(this._ref) : super(const AsyncValue.data(null));

  // SỬA: Hoàn nguyên. Hàm addItem không cần categoryId.
  Future<void> addItem(String name, double price, int companyId, String? imageUrl) async {
    state = const AsyncValue.loading();
    try {
      final api = _ref.read(itemApiProvider);
      // SỬA: Gọi hàm API đã được hoàn nguyên
      await api.addItem(name, price, companyId, imageUrl);
      // SỬA: Làm mới danh sách TẤT CẢ món ăn của công ty
      _ref.invalidate(allItemsProvider(companyId));
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  // SỬA: Hàm editItem không cần newCategoryId
  Future<void> editItem(Item item, String newName, double newPrice, String? newImageUrl) async {
    state = const AsyncValue.loading();
    try {
      // Tạo một đối tượng Item mới với thông tin đã cập nhật, bao gồm cả ảnh
      final updatedItem = item.copyWith(name: newName, price: newPrice, image: newImageUrl);
      final api = _ref.read(itemApiProvider);
      await api.updateItem(updatedItem); // Truyền toàn bộ đối tượng
      // SỬA: Làm mới danh sách TẤT CẢ món ăn của công ty
      if (item.companyId != null) {
        _ref.invalidate(allItemsProvider(item.companyId!));
        _ref.invalidate(categoryListProvider); // TỐI ƯU: Làm mới cả danh sách category
      }
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  // SỬA: Hàm deleteItem không cần categoryId
  Future<void> deleteItem(Item item) async {
    state = const AsyncValue.loading();
    try {
      final api = _ref.read(itemApiProvider);
      await api.deleteItem(item.id); 
      // SỬA: Làm mới danh sách TẤT CẢ món ăn của công ty
      if (item.companyId != null) {
        _ref.invalidate(allItemsProvider(item.companyId!));
        _ref.invalidate(categoryListProvider); // TỐI ƯU: Làm mới cả danh sách category
      }
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  // THÊM: Xóa một món ăn khỏi một menu
  Future<void> unassignItemFromMenu(int itemId, int categoryId, int menuId) async {
    state = const AsyncValue.loading();
    try {
      final api = _ref.read(itemApiProvider);
      await api.unassignItemFromMenu(itemId, categoryId);

      // Làm mới danh sách món ăn của menu này
      _ref.invalidate(itemsByMenuProvider(menuId));
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow; // Ném lại lỗi để UI có thể bắt và hiển thị
    }
  }

  // SỬA: Gán một món ăn vào một menu, cần thêm categoryId
  Future<void> assignItemToMenu(int itemId, int menuId, int companyId, int categoryId) async {
    state = const AsyncValue.loading();
    try {
      final api = _ref.read(itemApiProvider);
      // Gọi API để tạo quan hệ
      await api.assignItemToMenu(itemId, menuId, companyId, categoryId);

      // Làm mới danh sách món ăn của menu này để UI cập nhật
      _ref.invalidate(itemsByMenuProvider(menuId));
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      // Ném lại lỗi để UI có thể bắt và hiển thị thông báo
      rethrow;
    }
  }

  // THÊM: Hàm để gán nhiều món vào cùng một nhóm trong menu
  Future<void> assignItemsToMenu(
      {required int menuId,
      required int companyId,
      required int categoryId,
      required List<int> itemIds}) async {
    state = const AsyncValue.loading();
    try {
      final api = _ref.read(itemApiProvider);
      // Lặp và gọi API cho từng món.
      // (Tối ưu hơn nếu backend có API cho phép gán hàng loạt)
      for (final itemId in itemIds) {
        await api.assignItemToMenu(itemId, menuId, companyId, categoryId);
      }
      _ref.invalidate(itemsByMenuProvider(menuId));
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  // THÊM: Hàm xóa category và các liên kết của nó
  Future<void> deleteCategory(int categoryId) async {
    state = const AsyncValue.loading();
    try {
      final companyId = (await _ref.read(ownerProfileProvider.future)).companyId;
      if (companyId == null) {
        throw Exception("Không thể xác định công ty để xóa nhóm món.");
      }
      // Sử dụng CategoryAPI để thực hiện logic xóa phức tạp
      await _ref.read(categoryApiProvider).deleteCategoryAndAssignments(categoryId, companyId);

      // Làm mới danh sách category và các món ăn (vì categoryId trong item có thể bị ảnh hưởng)
      _ref.invalidate(categoryListProvider);
      _ref.invalidate(allItemsProvider(companyId));
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

// 3. Provider cho StateNotifier
final itemUpdateNotifierProvider =
    StateNotifierProvider<ItemUpdateNotifier, AsyncValue<void>>(
        (ref) => ItemUpdateNotifier(ref));