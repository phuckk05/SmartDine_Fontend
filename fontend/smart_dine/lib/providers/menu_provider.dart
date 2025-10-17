import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mart_dine/models/menu.dart';

// ✅ Cập nhật State để quản lý số lượng món ăn
class ChooseMenuState {
  final List<MenuItemModel> allMenuItems;
  final List<MenuItemModel> filteredMenuItems;
  final MenuCategory selectedCategory;
  final Map<String, int> selectedItems; // <itemId, quantity>

  ChooseMenuState({
    required this.allMenuItems,
    required this.filteredMenuItems,
    this.selectedCategory = MenuCategory.all,
    this.selectedItems = const {},
  });

  // ✅ Getter để tính tổng số món đã chọn
  int get totalItemsSelected {
    if (selectedItems.isEmpty) return 0;
    return selectedItems.values.reduce((sum, quantity) => sum + quantity);
  }

  ChooseMenuState copyWith({
    List<MenuItemModel>? allMenuItems,
    List<MenuItemModel>? filteredMenuItems,
    MenuCategory? selectedCategory,
    Map<String, int>? selectedItems,
  }) {
    return ChooseMenuState(
      allMenuItems: allMenuItems ?? this.allMenuItems,
      filteredMenuItems: filteredMenuItems ?? this.filteredMenuItems,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedItems: selectedItems ?? this.selectedItems,
    );
  }
}

class ChooseMenuNotifier extends StateNotifier<ChooseMenuState> {
  ChooseMenuNotifier() : super(_initialState());

  static ChooseMenuState _initialState() {
    final menuItems = [
      MenuItemModel(id: 'M1', name: 'Phở bò', price: 50000, category: MenuCategory.mainCourse),
      MenuItemModel(id: 'M2', name: 'Bún chả', price: 45000, category: MenuCategory.mainCourse),
      MenuItemModel(id: 'M3', name: 'Mì Quảng', price: 40000, category: MenuCategory.mainCourse),
      MenuItemModel(id: 'M4', name: 'Cơm tấm sườn bì', price: 55000, category: MenuCategory.mainCourse),
      MenuItemModel(id: 'M7', name: 'Lẩu Thái hải sản', price: 250000, category: MenuCategory.mainCourse),
      MenuItemModel(id: 'D1', name: 'Cà phê sữa', price: 25000, category: MenuCategory.drink),
      MenuItemModel(id: 'D2', name: 'Trà đào cam sả', price: 35000, category: MenuCategory.drink),
      MenuItemModel(id: 'D3', name: 'Nước cam ép', price: 30000, category: MenuCategory.drink),
      MenuItemModel(id: 'D4', name: 'Coca-Cola', price: 15000, category: MenuCategory.drink),
    ];
    return ChooseMenuState(
      allMenuItems: menuItems,
      filteredMenuItems: menuItems,
    );
  }

  void _applyFilters() {
    List<MenuItemModel> filtered;
    if (state.selectedCategory == MenuCategory.all) {
      filtered = state.allMenuItems;
    } else {
      filtered = state.allMenuItems
          .where((item) => item.category == state.selectedCategory)
          .toList();
    }
    state = state.copyWith(filteredMenuItems: filtered);
  }

  void setFilter(MenuCategory category) {
    state = state.copyWith(selectedCategory: category);
    _applyFilters();
  }

  // ✅ Tăng số lượng món
  void incrementItem(String itemId) {
    final newItems = Map<String, int>.from(state.selectedItems);
    newItems.update(itemId, (value) => value + 1, ifAbsent: () => 1);
    state = state.copyWith(selectedItems: newItems);
  }

  // ✅ Giảm số lượng món
  void decrementItem(String itemId) {
    final newItems = Map<String, int>.from(state.selectedItems);
    if (newItems.containsKey(itemId)) {
      if (newItems[itemId]! > 1) {
        newItems[itemId] = newItems[itemId]! - 1;
      } else {
        newItems.remove(itemId);
      }
      state = state.copyWith(selectedItems: newItems);
    }
  }

  void clearAllSelection() {
    state = state.copyWith(selectedItems: {});
  }
}

final chooseMenuProvider =
    StateNotifierProvider<ChooseMenuNotifier, ChooseMenuState>(
  (ref) => ChooseMenuNotifier(),
);

// Các provider phụ để dễ truy cập
final filteredMenuItemsProvider = Provider<List<MenuItemModel>>((ref) {
  return ref.watch(chooseMenuProvider).filteredMenuItems;
});

final selectedCategoryProvider = Provider<MenuCategory>((ref) {
  return ref.watch(chooseMenuProvider).selectedCategory;
});

// ✅ ĐÃ SỬA LỖI TẠI ĐÂY
final selectedItemsProvider = Provider<Map<String, int>>((ref) {
  return ref.watch(chooseMenuProvider).selectedItems;
});