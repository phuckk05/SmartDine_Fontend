import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mart_dine/API/menu_item_API.dart';
import 'package:mart_dine/models/item.dart';

class ItemNotifier extends StateNotifier<List<Item>> {
  final MenuItemAPI menuItemAPI;
  ItemNotifier(this.menuItemAPI) : super([]);

  Set<Item> build() {
    return const {};
  }

  //Lấy tất cả menu items by companyId
  Future<void> loadMenuItemsByCompanyId(int companyId) async {
    try {
      final items = await menuItemAPI.getMenuItemsByCompanyId(companyId);
      // Log fetch results to help diagnose empty UI states.
      // ignore: avoid_print
            state = items;
    } catch (error, stackTrace) {
      // ignore: avoid_print
          }
  }

  //Kiểm tra item đã tồn tại trong danh sách chưa nếu có trả về tên món
  String? checkItemExists(int itemId) {
    for (final item in state) {
      if (item.id == itemId) {
        return item.name;
      }
    }
    return null;
  }
}

final itemNotifierProvider = StateNotifierProvider<ItemNotifier, List<Item>>((
  ref,
) {
  return ItemNotifier(ref.watch(menuItemApiProvider));
});
