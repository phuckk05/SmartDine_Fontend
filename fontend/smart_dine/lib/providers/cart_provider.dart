import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mart_dine/models/item.dart';

class CartNotifier extends StateNotifier<List<Item>> {
  CartNotifier() : super([]);

  List<Item> build() {
    return const [];
  }

  void addItemToCart(Item item) {
    state = [...state, item];
  }

  void removeItemFromCart(Item item) {
    if (item.id == null) return;

    // Tìm VỊ TRÍ (index) của item này trong list
    final index = state.indexWhere((i) => i.id == item.id);

    // Nếu tìm thấy, copy list cũ và chỉ xóa item tại vị trí đó
    if (index != -1) {
      final newList = [...state]; // Copy list
      newList.removeAt(index); // Xóa 1
      state = newList; // Cập nhật state
    }
  }

  void clearCart() {
    state = [];
  }
}

final cartNotifierProvider = StateNotifierProvider<CartNotifier, List<Item>>((
  ref,
) {
  return CartNotifier();
});
