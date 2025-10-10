import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider lưu trạng thái filter
final tableStatusProvider = StateProvider<String>((ref) => 'Tất cả');

// Provider lưu danh sách bàn
final tablesProvider =
    StateNotifierProvider<TableNotifier, List<Map<String, dynamic>>>(
  (ref) => TableNotifier(),
);

class TableNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  TableNotifier() : super(List<Map<String, dynamic>>.from(_initialTables));

  void moveToTop(Map<String, dynamic> table) {
    state = [table, ...state.where((t) => t['name'] != table['name']).toList()];
  }

  /// Đặt bàn theo tên: cập nhật trạng thái -> 'Đã đặt'
  void bookTable(String name) {
    state = state.map((t) {
      if (t['name'] == name) {
        return {...t, 'status': 'Đã đặt'};
      }
      return t;
    }).toList();
  }

  /// Ghi nhận khách đã đến, cập nhật trạng thái -> 'Có khách'
  void occupyTable(String name) {
    state = state.map((t) {
      if (t['name'] == name) {
        return {...t, 'status': 'Có khách'};
      }
      return t;
    }).toList();
  }

  /// Trả bàn về trạng thái 'Trống'
  void freeTable(String name) {
    state = state.map((t) {
      if (t['name'] == name) {
        return {...t, 'status': 'Trống'};
      }
      return t;
    }).toList();
  }
}

// ---------------------------
// Dữ liệu mẫu ban đầu (private)
// ---------------------------
final List<Map<String, dynamic>> _initialTables = [
  {'name': 'A-1', 'capacity': 4, 'status': 'Trống', 'area': 'Khu trong nhà'},
  {'name': 'A-2', 'capacity': 6, 'status': 'Trống', 'area': 'Khu trong nhà'},
  {'name': 'A-3', 'capacity': 8, 'status': 'Trống', 'area': 'Ngoài trời'},
  {'name': 'A-4', 'capacity': 4, 'status': 'Trống', 'area': 'Trong nhà'},
  {'name': 'A-5', 'capacity': 6, 'status': 'Trống', 'area': 'Ngoài trời'},
  {'name': 'A-6', 'capacity': 8, 'status': 'Trống', 'area': 'Trong nhà'},
  {'name': 'A-7', 'capacity': 2, 'status': 'Trống', 'area': 'Khu Tiên'},
  {'name': 'A-8', 'capacity': 2, 'status': 'Trống', 'area': 'Trong nhà'},
  {'name': 'A-9', 'capacity': 8, 'status': 'Trống', 'area': 'Ngoài trời'},
  {'name': 'A-10', 'capacity': 4, 'status': 'Trống', 'area': 'Trong nhà'},
  {'name': 'A-11', 'capacity': 6, 'status': 'Trống', 'area': 'Trong nhà'},
  {'name': 'A-12', 'capacity': 8, 'status': 'Trống', 'area': 'Trong nhà'},
  {'name': 'A-13', 'capacity': 4, 'status': 'Trống', 'area': 'Ngoài trời'},
  {'name': 'A-14', 'capacity': 6, 'status': 'Trống', 'area': 'Trong nhà'},
  {'name': 'A-15', 'capacity': 8, 'status': 'Trống', 'area': 'Trong nhà'},
  {'name': 'A-16', 'capacity': 2, 'status': 'Trống', 'area': 'Trong nhà'},
  {'name': 'A-17', 'capacity': 6, 'status': 'Trống', 'area': 'Ngoài trời'},
  {'name': 'A-18', 'capacity': 8, 'status': 'Trống', 'area': 'Trong nhà'},
];

/// Bookings per table (reserved but not yet arrived)
final bookingsProvider = StateNotifierProvider<BookingsNotifier, Map<String, Map<String, dynamic>>>((ref) {
  return BookingsNotifier();
});

class BookingsNotifier extends StateNotifier<Map<String, Map<String, dynamic>>> {
  BookingsNotifier() : super({});

  void setBooking(String tableName, Map<String, dynamic> booking) {
    state = {...state, tableName: booking};
  }

  Map<String, dynamic>? getBooking(String tableName) => state[tableName];

  void removeBooking(String tableName) {
    final next = Map<String, Map<String, dynamic>>.from(state);
    next.remove(tableName);
    state = next;
  }
}
