import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers_choose_table.dart';

/// Danh sách món ăn có sẵn (hard-coded)
final dishesProvider = Provider<List<Map<String, dynamic>>>((ref) => _dishes);

/// Controller quản lý trạng thái của order hiện tại trên màn hình chọn món
final orderControllerProvider =
    StateNotifierProvider<OrderNotifier, Map<int, int>>((ref) {
  return OrderNotifier(ref);
});

class OrderNotifier extends StateNotifier<Map<int, int>> {
  final Ref ref;
  Map<int, String> notes = {}; // Lưu ghi chú cho từng món ăn

  OrderNotifier(this.ref) : super({});

  void increase(int idx) {
    state = {...state, idx: (state[idx] ?? 0) + 1};
  }

  void decrease(int idx) {
    final cur = (state[idx] ?? 0) - 1;
    if (cur <= 0) {
      final next = Map<int, int>.from(state);
      next.remove(idx);
      notes.remove(idx); // Xóa ghi chú khi số lượng về 0
      state = next;
    } else {
      state = {...state, idx: cur};
    }
  }

  // Thêm hoặc cập nhật ghi chú
  void addNote(int dishIndex, String note) {
    if (state.containsKey(dishIndex)) {
      notes[dishIndex] = note;
    }
  }

  // Lấy ghi chú của món ăn
  String getNote(int dishIndex) {
    return notes[dishIndex] ?? '';
  }

  void clear() {
    state = {};
    notes = {};
  }

  /// Xác nhận order: Cập nhật trạng thái bàn thành 'Có khách' và lưu order
  Future<void> confirmOrder(String tableName, int guestCount) async {
    final dishes = ref.read(dishesProvider);
    final orderItems = state.entries.map((entry) {
      final dish = dishes[entry.key];
      return {
        'name': dish['name'],
        'price': dish['price'],
        'quantity': entry.value,
        'note': notes[entry.key] ?? '',
      };
    }).toList();

    // Lưu order vào ordersProvider
    final ordersNotifier = ref.read(ordersProvider.notifier);
    ordersNotifier.setOrder(tableName, {
      'guestCount': guestCount,
      'items': orderItems,
      'total': ref.read(orderTotalProvider),
    });

    // Nếu có booking, xóa booking (khách đã đến)
    ref.read(bookingsProvider.notifier).removeBooking(tableName);

    // Đánh dấu bàn có khách
    ref.read(tablesProvider.notifier).occupyTable(tableName);

    // Sau khi xác nhận, clear order tạm
    clear();
  }

  /// Xử lý thanh toán: xóa order và cập nhật trạng thái bàn thành 'Trống'
  Future<void> checkoutOrder(String tableName) async {
    // Xóa order khỏi danh sách
    ref.read(ordersProvider.notifier).removeOrder(tableName);

    // Đánh dấu bàn trống
    ref.read(tablesProvider.notifier).vacateTable(tableName);
    
    // Clear order tạm (dù màn hình sẽ pop)
    clear();
  }
}

/// Provider tính tổng tiền của order hiện tại
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

/// Orders per table: key = tableName -> value = order data { guestCount, items, total }
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


