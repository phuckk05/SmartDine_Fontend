import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mart_dine/models/item.dart';

// StateNotifier để quản lý giỏ hàng
class CartNotifier extends StateNotifier<List<Item>> {
  CartNotifier() : super([]); // Khởi tạo với List rỗng

  // Thêm món vào giỏ hàng
  void addItemToCart(Item item) {
    state = [...state, item]; // Thêm item vào cuối List
  }

  // Xóa 1 món khỏi giỏ hàng (xóa lần xuất hiện đầu tiên)
  void removeItemFromCart(Item item) {
    if (item.id == null) return;
    
    final index = state.indexWhere((i) => i.id == item.id);
    if (index != -1) {
      final newList = [...state];
      newList.removeAt(index); // Xóa 1 item tại vị trí index
      state = newList;
    }
  }

  // Xóa toàn bộ giỏ hàng
  void clearCart() {
    state = [];
  }

  // Load items ban đầu (dùng khi có order cũ)
  void loadInitialItems(List<Item> items) {
    state = items;
  }

  // Xóa tất cả món có ID cụ thể
  void removeAllOfItem(Item item) {
    if (item.id == null) return;
    state = state.where((i) => i.id != item.id).toList();
  }

  // Đếm số lượng của 1 món cụ thể
  int getItemCount(int itemId) {
    return state.where((item) => item.id == itemId).length;
  }

  // Tính tổng giá trị giỏ hàng
  double getTotalPrice() {
    return state.fold(0.0, (sum, item) => sum + item.price);
  }

  // Lấy danh sách món duy nhất với số lượng
  Map<Item, int> getUniqueItemsWithQuantity() {
    final Map<Item, int> itemCounts = {};
    for (var item in state) {
      if (item.id != null) {
        // Tìm xem item đã có trong map chưa
        final existingItem = itemCounts.keys.firstWhere(
          (key) => key.id == item.id,
          orElse: () => item,
        );
        
        if (itemCounts.containsKey(existingItem)) {
          itemCounts[existingItem] = itemCounts[existingItem]! + 1;
        } else {
          itemCounts[item] = 1;
        }
      }
    }
    return itemCounts;
  }
}

// Provider cho CartNotifier
final cartNotifierProvider = StateNotifierProvider<CartNotifier, List<Item>>((ref) {
  return CartNotifier();
});

// Provider tính tổng số món (bao gồm trùng)
final cartTotalItemsProvider = Provider<int>((ref) {
  final cart = ref.watch(cartNotifierProvider);
  return cart.length;
});

// Provider tính tổng giá
final cartTotalPriceProvider = Provider<double>((ref) {
  final cart = ref.watch(cartNotifierProvider);
  return cart.fold(0.0, (sum, item) => sum + item.price);
});

// Provider lấy số món duy nhất
final cartUniqueItemsCountProvider = Provider<int>((ref) {
  final cart = ref.watch(cartNotifierProvider);
  if (cart.isEmpty) return 0;
  
  final uniqueIds = <int>{};
  for (var item in cart) {
    if (item.id != null) {
      uniqueIds.add(item.id!);
    }
  }
  return uniqueIds.length;
});