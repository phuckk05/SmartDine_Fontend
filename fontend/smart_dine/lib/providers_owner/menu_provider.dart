// file: lib/providers_owner/menu_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mart_dine/API_owner/menu_API.dart';
import 'package:mart_dine/models_owner/menu.dart';
import 'package:mart_dine/providers_owner/system_stats_provider.dart';

/// FutureProvider để lấy danh sách tất cả các menu của một công ty.
///
/// Provider này sẽ tự động gọi API khi được watch và cache kết quả.
/// Nó sẽ được làm mới (refreshed) khi các hành động CUD (Create, Update, Delete)
/// được thực hiện thành công bởi `menuUpdateNotifierProvider`.
final menuListProvider = FutureProvider<List<Menu>>((ref) async {
  // Lấy companyId từ profile của owner
  final companyId = (await ref.watch(ownerProfileProvider.future)).companyId;
  if (companyId == null) {
    // Nếu không có companyId, trả về danh sách rỗng để tránh lỗi.
    return [];
  }
  // Gọi API để lấy danh sách menu
  return ref.watch(menuApiProvider).getMenusByCompany(companyId);
});

/// StateNotifier để quản lý các hành động thêm, sửa, xóa menu.
class MenuUpdateNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;

  MenuUpdateNotifier(this._ref) : super(const AsyncValue.data(null));

  /// Thêm một menu mới.
  Future<void> addMenu(String name, String description) async {
    state = const AsyncValue.loading();
    try {
      // Lấy companyId từ profile của owner đang đăng nhập
      final companyId = (await _ref.read(ownerProfileProvider.future)).companyId;
      if (companyId == null) {
        throw Exception("Không thể xác định công ty của người dùng.");
      }

      // Tạo đối tượng Menu với companyId và statusId mặc định
      final newMenu = Menu(name: name, description: description, companyId: companyId, statusId: 1);
      await _ref.read(menuApiProvider).createMenu(newMenu);
      _ref.invalidate(menuListProvider); // Làm mới danh sách menu
      state = const AsyncValue.data(null);
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }

  /// Chỉnh sửa một menu đã có.
  Future<void> editMenu(Menu oldMenu, String newName, String newDescription) async {
    state = const AsyncValue.loading();
    try {
      // SỬA: Tạo một đối tượng Menu mới với thông tin cập nhật
      // Điều này đảm bảo companyId và statusId được giữ lại.
      final updatedMenu = oldMenu.copyWith(
        name: newName,
        description: newDescription,
        statusId: 1,
      );
      // SỬA: Truyền toàn bộ đối tượng đã cập nhật vào API
      await _ref.read(menuApiProvider).updateMenu(oldMenu.id!, updatedMenu);
      _ref.invalidate(menuListProvider); // Làm mới danh sách menu
      state = const AsyncValue.data(null);
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }

  /// Xóa một menu.
  Future<void> deleteMenu(int menuId) async {
    state = const AsyncValue.loading();
    try {
      await _ref.read(menuApiProvider).deleteMenu(menuId);
      _ref.invalidate(menuListProvider); // Làm mới danh sách menu
      state = const AsyncValue.data(null);
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }
}

/// Provider để cung cấp một instance của MenuUpdateNotifier cho UI.
///
/// UI sẽ sử dụng provider này để gọi các hàm addMenu, editMenu, deleteMenu.
/// Ví dụ: `ref.read(menuUpdateNotifierProvider.notifier).addMenu(...)`
final menuUpdateNotifierProvider =
    StateNotifierProvider<MenuUpdateNotifier, AsyncValue<void>>(
  (ref) => MenuUpdateNotifier(ref),
);