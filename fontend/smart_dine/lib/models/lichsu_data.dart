import 'package:flutter/material.dart';

import 'lichsu_order.dart';
import 'user.dart';
import 'item.dart';
import 'menu_item_status.dart';

class HistoryMockData {
  // Mock users (nhân viên phục vụ)
  static final staffs = [
    User(
      id: 1,
      fullName: 'Nguyễn Văn A',
      email: 'nguyenvana@gmail.com',
      phone: '0901234567',
      passworkHash: '\$2a\$10\$abc',
      fontImage: 'front1.jpg',
      backImage: 'back1.jpg',
      statusId: 1,
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime.now(),
      deletedAt: null,
    ),
    User(
      id: 2,
      fullName: 'Trần Thị B',
      email: 'tranthib@gmail.com',
      phone: '0907654321',
      passworkHash: '\$2a\$10\$def',
      fontImage: 'front2.jpg',
      backImage: 'back2.jpg',
      statusId: 1,
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime.now(),
      deletedAt: null,
    ),
    User(
      id: 3,
      fullName: 'Lê Văn C',
      email: 'levanc@gmail.com',
      phone: '0909876543',
      passworkHash: '\$2a\$10\$ghi',
      fontImage: 'front3.jpg',
      backImage: 'back3.jpg',
      statusId: 1,
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime.now(),
      deletedAt: null,
    ),
  ];

  // Mock menu item status
  static final menuItemStatusAvailable = MenuItemStatus(
    id: 'mis-1',
    code: 'AVAILABLE',
    name: 'Còn món',
  );

  // Mock items
  static final items = [
    Item(
      id: 'i-1',
      companyId: 'c-1',
      name: 'Bún bò Huế',
      price: 45000,
      statusId: menuItemStatusAvailable.id,
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime.now(),
    ),
    Item(
      id: 'i-2',
      companyId: 'c-1',
      name: 'Phở bò',
      price: 50000,
      statusId: menuItemStatusAvailable.id,
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime.now(),
    ),
    Item(
      id: 'i-3',
      companyId: 'c-1',
      name: 'Cơm tấm sườn',
      price: 40000,
      statusId: menuItemStatusAvailable.id,
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime.now(),
    ),
    Item(
      id: 'i-4',
      companyId: 'c-1',
      name: 'Bánh mì thịt',
      price: 25000,
      statusId: menuItemStatusAvailable.id,
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime.now(),
    ),
    Item(
      id: 'i-5',
      companyId: 'c-1',
      name: 'Bún chả Hà Nội',
      price: 55000,
      statusId: menuItemStatusAvailable.id,
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime.now(),
    ),
    Item(
      id: 'i-6',
      companyId: 'c-1',
      name: 'Mì Quảng',
      price: 48000,
      statusId: menuItemStatusAvailable.id,
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime.now(),
    ),
    Item(
      id: 'i-7',
      companyId: 'c-1',
      name: 'Cháo lòng',
      price: 35000,
      statusId: menuItemStatusAvailable.id,
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime.now(),
    ),
    Item(
      id: 'i-8',
      companyId: 'c-1',
      name: 'Hủ tiếu Nam Vang',
      price: 45000,
      statusId: menuItemStatusAvailable.id,
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime.now(),
    ),
  ];

  /// Lấy tất cả lịch sử
  static List<HistoryOrder> getAllHistory() {
    final now = DateTime.now();
    final history = <HistoryOrder>[];

    // Hôm nay (10 records)
    for (int i = 0; i < 10; i++) {
      history.add(
        _createHistory(
          id: 'h-${i + 1}',
          item: items[i % items.length],
          staff: staffs[i % staffs.length],
          table: 'B-${(i % 12) + 1}',
          servedAt: now.subtract(Duration(hours: i, minutes: i * 5)),
        ),
      );
    }

    // Hôm qua (8 records)
    for (int i = 10; i < 18; i++) {
      history.add(
        _createHistory(
          id: 'h-${i + 1}',
          item: items[i % items.length],
          staff: staffs[i % staffs.length],
          table: 'B-${(i % 12) + 1}',
          servedAt: now.subtract(
            Duration(days: 1, hours: i - 10, minutes: i * 3),
          ),
        ),
      );
    }

    // Tuần này (15 records)
    for (int i = 18; i < 33; i++) {
      history.add(
        _createHistory(
          id: 'h-${i + 1}',
          item: items[i % items.length],
          staff: staffs[i % staffs.length],
          table: 'B-${(i % 12) + 1}',
          servedAt: now.subtract(Duration(days: (i - 18) % 7, hours: i % 12)),
        ),
      );
    }

    // Sắp xếp theo thời gian mới nhất
    history.sort((a, b) => b.servedAt.compareTo(a.servedAt));

    return history;
  }

  /// Tạo một history order
  static HistoryOrder _createHistory({
    required String id,
    required Item item,
    required User staff,
    required String table,
    required DateTime servedAt,
  }) {
    return HistoryOrder(
      id: id,
      orderId: 'o-${id.split('-').last}',
      dishName: item.name,
      quantity: (int.parse(id.split('-').last) % 3) + 1,
      tableNumber: table,
      staffName: staff.fullName,
      staffId: staff.id?.toString() ?? '',
      servedAt: servedAt,
      orderCreatedAt: servedAt.subtract(const Duration(minutes: 15)),
      note: int.parse(id.split('-').last) % 3 == 0 ? 'Ít cay' : null,
      itemDetails: item,
      servedByUser: staff,
    );
  }

  /// Lọc theo thời gian
  static List<HistoryOrder> filterByTime(
    List<HistoryOrder> history,
    String timeFilter,
    DateTimeRange? customRange,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (timeFilter) {
      case 'today':
        return history.where((h) {
          final orderDate = DateTime(
            h.servedAt.year,
            h.servedAt.month,
            h.servedAt.day,
          );
          return orderDate == today;
        }).toList();

      case 'week':
        final weekAgo = today.subtract(const Duration(days: 7));
        return history.where((h) => h.servedAt.isAfter(weekAgo)).toList();

      case 'custom':
        if (customRange == null) return history;
        return history.where((h) {
          return h.servedAt.isAfter(customRange.start) &&
              h.servedAt.isBefore(customRange.end.add(const Duration(days: 1)));
        }).toList();

      default:
        return history;
    }
  }

  /// Lọc theo nhân viên
  static List<HistoryOrder> filterByStaff(
    List<HistoryOrder> history,
    Map<String, bool> staffFilter,
  ) {
    final selectedStaffs =
        staffFilter.entries.where((e) => e.value).map((e) => e.key).toList();

    if (selectedStaffs.isEmpty) return history;

    return history.where((h) => selectedStaffs.contains(h.staffName)).toList();
  }

  /// Lọc theo loại món
  static List<HistoryOrder> filterByDish(
    List<HistoryOrder> history,
    Map<String, bool> dishFilter,
  ) {
    final selectedDishes =
        dishFilter.entries.where((e) => e.value).map((e) => e.key).toList();

    if (selectedDishes.isEmpty) return history;

    return history.where((h) {
      // Check if dish name contains any of the selected categories
      return selectedDishes.any((category) {
        return h.dishName.toLowerCase().contains(category.toLowerCase());
      });
    }).toList();
  }

  /// Tìm kiếm
  static List<HistoryOrder> search(List<HistoryOrder> history, String query) {
    if (query.isEmpty) return history;

    final lowerQuery = query.toLowerCase();
    return history.where((h) {
      return h.dishName.toLowerCase().contains(lowerQuery) ||
          h.tableNumber.toLowerCase().contains(lowerQuery) ||
          h.staffName.toLowerCase().contains(lowerQuery);
    }).toList();
  }
}
