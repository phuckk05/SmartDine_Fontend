// file: providers/category_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mart_dine/models_owner/categories.dart'; // Đảm bảo đường dẫn đúng
import 'package:mart_dine/API_owner/category_API.dart';
import 'package:mart_dine/providers_owner/menu_item_relation_provider.dart';
// THÊM: Notifier để quản lý các hành động CUD (Create, Update, Delete)
final categoryUpdateNotifierProvider =
    StateNotifierProvider<CategoryUpdateNotifier, AsyncValue<void>>((ref) {
  return CategoryUpdateNotifier(ref);
});
class CategoryUpdateNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;
  CategoryUpdateNotifier(this._ref) : super(const AsyncValue.data(null));
  Future<void> addCategory(String name, int companyId) async {
    state = const AsyncValue.loading();
    try {
      final newCategory = Category(id: 0, name: name, companyId: companyId, createdAt: DateTime.now(), updatedAt: DateTime.now());
      await _ref.read(categoryApiProvider).createCategory(newCategory);
      _ref.invalidate(categoryListProvider); // Làm mới danh sách
      state = const AsyncValue.data(null);
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }
  Future<void> editCategory(Category originalCategory, String newName) async {
    state = const AsyncValue.loading();
    try {
      final updatedCategory = originalCategory.copyWith(name: newName, updatedAt: DateTime.now());
      await _ref.read(categoryApiProvider).updateCategory(originalCategory.id, updatedCategory);
      _ref.invalidate(categoryListProvider); // Làm mới danh sách
      state = const AsyncValue.data(null);
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }
  Future<void> deleteCategory(int categoryId) async {
    state = const AsyncValue.loading();
    try {
      await _ref.read(categoryApiProvider).deleteCategory(categoryId);
      _ref.invalidate(categoryListProvider); // Làm mới danh sách
      state = const AsyncValue.data(null);
    } catch (e, s) {
      // Truyền lỗi ra ngoài để UI có thể hiển thị
      state = AsyncValue.error(e, s);
      rethrow; // Ném lại lỗi để bên gọi có thể bắt
    }
  }
}