import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mart_dine/API/menu_item_API.dart';
import 'package:mart_dine/models/item.dart';

class MenuItemNotifier extends StateNotifier<List<Item>> {
  final MenuItemApi menuApi;
  MenuItemNotifier(this.menuApi) : super([]);

  //lay menu theo company id
  Future<void> loadMenusByCompanyId(int companyId) async {
    final items = await menuApi.fetchMenusByCompanyId(companyId);
    state = items;
  }
}

final menuNotifierProvider =
    StateNotifierProvider<MenuItemNotifier, List<Item>>((ref) {
      final menuApi = ref.watch(menuApiProvider);
      return MenuItemNotifier(menuApi);
    });
