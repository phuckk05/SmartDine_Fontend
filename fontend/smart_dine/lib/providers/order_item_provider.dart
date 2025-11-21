import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mart_dine/API/order_item_API.dart';
import 'package:mart_dine/models/order_item.dart';

// *** FIX 1: State phải là List<OrderItem> ***
class OrderItemNotifier extends StateNotifier<List<OrderItem>> {
  final OrderItemAPI _orderItemAPI;

  // Constructor phải khởi tạo một List rỗng
  OrderItemNotifier(this._orderItemAPI) : super([]); // <-- Sửa ở đây

  void loadOrderItems() async {
    final fetchedItems = await _orderItemAPI.fetchOrders();
    if (mounted) {
      // Logic của bạn đúng, state là List
      state = state.isEmpty ? fetchedItems : [...state, ...fetchedItems];
    }
  }

  // *** FIX 2: Tham số phải là List<OrderItem> (để khớp với _saveOrder) ***
  void addOrderItem(List<OrderItem> items) async {
    try {
      // Giờ bạn có thể dùng 'await' bên trong
      final createdItems = await _orderItemAPI.saveOrderItems(items);
      if (mounted) {
        state = [...state, ...createdItems];
      }
    } catch (e) {}
  }

  void removeOrderItem(OrderItem item) {
    // Hàm này giờ hoạt động chính xác trên List
    state = state.where((i) => i.id != item.id).toList();
  }

  void clearOrderItems() {
    // Gán một List rỗng là chính xác
    state = [];
  }
}

// Provider đã khớp với Notifier (List<OrderItem>)
final orderItemNotifierProvider =
    StateNotifierProvider<OrderItemNotifier, List<OrderItem>>((ref) {
      final orderItemAPI = ref.watch(orderItemApiProvider);
      return OrderItemNotifier(orderItemAPI);
    });
