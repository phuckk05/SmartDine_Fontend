import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'choose_table_controller.dart';

/// Danh sách món (tạm hard-coded)
final dishesProvider = Provider<List<Map<String, dynamic>>>((ref) => _dishes);

/// Controller quản lý số lượng đã chọn: key = index món, value = số lượng
final orderControllerProvider =
    StateNotifierProvider<OrderNotifier, Map<int, int>>((ref) {
  return OrderNotifier(ref);
});

class OrderNotifier extends StateNotifier<Map<int, int>> {
  final Ref ref;
  OrderNotifier(this.ref) : super({});

  void increase(int idx) {
    state = {...state, idx: (state[idx] ?? 0) + 1};
  }

  void decrease(int idx) {
    final cur = (state[idx] ?? 0) - 1;
    final Map<int, int> next = Map.from(state);
    if (cur <= 0) {
      next.remove(idx);
    } else {
      next[idx] = cur;
    }
    state = next;
  }

  void clear() => state = {};

  /// Xác nhận order: cập nhật trạng thái bàn thành 'Đã đặt' và xoá order tạm
  Future<void> confirmOrder(String tableName, int guestCount) async {
    // Thực thi cập nhật trạng thái bàn
    // Khi khách chọn món => bàn đang có khách
      // Lưu order xuống ordersProvider
      final ordersNotifier = ref.read(ordersProvider.notifier);
    ordersNotifier.setOrder(tableName, {'guestCount': guestCount, 'items': state});
    // Nếu có booking, xoá booking (khách đến)
    ref.read(bookingsProvider.notifier).removeBooking(tableName);
    // Đánh dấu bàn có khách
    ref.read(tablesProvider.notifier).occupyTable(tableName);
      // Sau khi confirm, clear order
      clear();
  }
}

/// Provider tính tổng tiền theo order hiện tại
final orderTotalProvider = Provider<int>((ref) {
  final quantities = ref.watch(orderControllerProvider);
  final dishes = ref.watch(dishesProvider);
  var sum = 0;
  quantities.forEach((idx, q) {
    final price = (dishes[idx]['price'] as int?) ?? 0;
    sum += price * q;
  });
  return sum;
});

final List<Map<String, dynamic>> _dishes = [
  {'name': 'Phở bò', 'price': 60000},
  {'name': 'Cơm sườn', 'price': 70000},
  {'name': 'Gỏi cuốn', 'price': 30000},
  {'name': 'Bún chả', 'price': 65000},
  {'name': 'Nước ngọt', 'price': 15000},
];

/// Orders per table: key = tableName -> value = order data { guestCount, items }
final ordersProvider = StateNotifierProvider<OrdersNotifier, Map<String, Map<String, dynamic>>>((ref) {
  return OrdersNotifier();
});

class OrdersNotifier extends StateNotifier<Map<String, Map<String, dynamic>>> {
  OrdersNotifier() : super({});

  void setOrder(String tableName, Map<String, dynamic> order) {
    state = {...state, tableName: order};
  }

  Map<String, dynamic>? getOrder(String tableName) => state[tableName];

  void removeOrder(String tableName) {
    final next = Map<String, Map<String, dynamic>>.from(state);
    next.remove(tableName);
    state = next;
  }
}
