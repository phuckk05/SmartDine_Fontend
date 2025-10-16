import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/lichsu_models.dart';

/// Provider cho danh sách lịch sử orders
final historyOrdersProvider = StateProvider<List<HistoryOrderModel>>((ref) {
  // Dữ liệu mẫu - sau này thay bằng dữ liệu từ database
  return [
    HistoryOrderModel(
      id: 1,
      dishName: 'Bánh mì',
      tableNumber: 'B-5',
      staffName: 'Nguyễn Văn A',
      time: DateTime.now().subtract(const Duration(hours: 2)),
      dishCategory: 'Món chính',
      orderId: 101,
      dishId: 1,
      staffId: 1,
    ),
    HistoryOrderModel(
      id: 2,
      dishName: 'Bánh mì',
      tableNumber: 'A-2',
      staffName: 'Nguyễn Văn B',
      time: DateTime.now().subtract(const Duration(hours: 3)),
      dishCategory: 'Món chính',
      orderId: 102,
      dishId: 1,
      staffId: 2,
    ),
    HistoryOrderModel(
      id: 3,
      dishName: 'Salad',
      tableNumber: 'B-5',
      staffName: 'Nguyễn Văn C',
      time: DateTime.now().subtract(const Duration(hours: 4)),
      dishCategory: 'Món khai vị',
      orderId: 103,
      dishId: 2,
      staffId: 3,
    ),
    HistoryOrderModel(
      id: 4,
      dishName: 'Kem',
      tableNumber: 'B-5',
      staffName: 'Nguyễn Văn A',
      time: DateTime.now().subtract(const Duration(hours: 5)),
      dishCategory: 'Món tráng miệng',
      orderId: 104,
      dishId: 3,
      staffId: 1,
    ),
    HistoryOrderModel(
      id: 5,
      dishName: 'Phở bò',
      tableNumber: 'C-3',
      staffName: 'Nguyễn Văn D',
      time: DateTime.now().subtract(const Duration(days: 1)),
      dishCategory: 'Món chính',
      orderId: 105,
      dishId: 4,
      staffId: 4,
    ),
  ];
});

/// Provider cho search query
final searchQueryProvider = StateProvider<String>((ref) => '');

/// Provider cho time filter (today, week, custom)
final selectedTimeFilterProvider = StateProvider<String>((ref) => 'today');

/// Provider cho custom date range (khi chọn "Chọn ngày")
final customDateRangeProvider = StateProvider<DateTimeRange?>((ref) => null);

/// Provider cho staff filter
final staffFilterProvider = StateProvider<Map<String, bool>>((ref) {
  return {
    'Nguyễn Văn A': false,
    'Nguyễn Văn B': false,
    'Nguyễn Văn C': false,
    'Nguyễn Văn D': false,
  };
});

/// Provider cho dish category filter
final dishCategoryFilterProvider = StateProvider<Map<String, bool>>((ref) {
  return {'Món khai vị': false, 'Món chính': false, 'Món tráng miệng': false};
});

/// Provider để lấy danh sách staff từ history
final availableStaffProvider = Provider<List<String>>((ref) {
  final orders = ref.watch(historyOrdersProvider);
  final staffSet = orders.map((order) => order.staffName).toSet();
  return staffSet.toList()..sort();
});

/// Provider để lấy danh sách dish categories từ history
final availableDishCategoriesProvider = Provider<List<String>>((ref) {
  final orders = ref.watch(historyOrdersProvider);
  final categorySet = orders.map((order) => order.dishCategory).toSet();
  return categorySet.toList()..sort();
});

/// Provider cho filtered history với tất cả filters
final filteredHistoryProvider = Provider<List<HistoryOrderModel>>((ref) {
  final orders = ref.watch(historyOrdersProvider);
  final searchQuery = ref.watch(searchQueryProvider);
  final timeFilter = ref.watch(selectedTimeFilterProvider);
  final customDateRange = ref.watch(customDateRangeProvider);
  final staffFilter = ref.watch(staffFilterProvider);
  final dishCategoryFilter = ref.watch(dishCategoryFilterProvider);

  List<HistoryOrderModel> filtered = orders;

  // 1. Lọc theo thời gian
  switch (timeFilter) {
    case 'today':
      filtered = filtered.where((order) => order.isToday).toList();
      break;
    case 'week':
      filtered = filtered.where((order) => order.isThisWeek).toList();
      break;
    case 'custom':
      if (customDateRange != null) {
        filtered =
            filtered.where((order) {
              return order.time.isAfter(customDateRange.start) &&
                  order.time.isBefore(
                    customDateRange.end.add(const Duration(days: 1)),
                  );
            }).toList();
      }
      break;
  }

  // 2. Lọc theo nhân viên
  final selectedStaff =
      staffFilter.entries
          .where((entry) => entry.value)
          .map((entry) => entry.key)
          .toList();

  if (selectedStaff.isNotEmpty) {
    filtered =
        filtered.where((order) {
          return selectedStaff.contains(order.staffName);
        }).toList();
  }

  // 3. Lọc theo loại món
  final selectedCategories =
      dishCategoryFilter.entries
          .where((entry) => entry.value)
          .map((entry) => entry.key)
          .toList();

  if (selectedCategories.isNotEmpty) {
    filtered =
        filtered.where((order) {
          return selectedCategories.contains(order.dishCategory);
        }).toList();
  }

  // 4. Lọc theo search query
  if (searchQuery.isNotEmpty) {
    final query = searchQuery.toLowerCase();
    filtered =
        filtered.where((order) {
          return order.dishName.toLowerCase().contains(query) ||
              order.tableNumber.toLowerCase().contains(query) ||
              order.staffName.toLowerCase().contains(query);
        }).toList();
  }

  // 5. Sắp xếp theo thời gian mới nhất
  filtered.sort((a, b) => b.time.compareTo(a.time));

  return filtered;
});

/// Provider đếm số lượng active filters
final activeFiltersCountProvider = Provider<int>((ref) {
  int count = 0;

  // Đếm staff filters
  final staffFilter = ref.watch(staffFilterProvider);
  count += staffFilter.values.where((v) => v).length;

  // Đếm dish category filters
  final dishFilter = ref.watch(dishCategoryFilterProvider);
  count += dishFilter.values.where((v) => v).length;

  // Đếm time filter (nếu không phải 'today' thì +1)
  final timeFilter = ref.watch(selectedTimeFilterProvider);
  if (timeFilter != 'today') count++;

  return count;
});

/// Provider để clear tất cả filters
final clearAllFiltersProvider = Provider<void Function()>((ref) {
  return () {
    // Reset search
    ref.read(searchQueryProvider.notifier).state = '';

    // Reset time filter
    ref.read(selectedTimeFilterProvider.notifier).state = 'today';
    ref.read(customDateRangeProvider.notifier).state = null;

    // Reset staff filter
    final staffFilter = ref.read(staffFilterProvider);
    final clearedStaff = Map<String, bool>.from(staffFilter);
    clearedStaff.updateAll((key, value) => false);
    ref.read(staffFilterProvider.notifier).state = clearedStaff;

    // Reset dish filter
    final dishFilter = ref.read(dishCategoryFilterProvider);
    final clearedDish = Map<String, bool>.from(dishFilter);
    clearedDish.updateAll((key, value) => false);
    ref.read(dishCategoryFilterProvider.notifier).state = clearedDish;
  };
});

/// Provider để thêm history order mới
final addHistoryOrderProvider = Provider<void Function(HistoryOrderModel)>((
  ref,
) {
  return (HistoryOrderModel order) {
    final currentOrders = ref.read(historyOrdersProvider);
    ref.read(historyOrdersProvider.notifier).state = [order, ...currentOrders];
  };
});

/// Provider để xóa history order
final deleteHistoryOrderProvider = Provider<void Function(int)>((ref) {
  return (int orderId) {
    final currentOrders = ref.read(historyOrdersProvider);
    ref.read(historyOrdersProvider.notifier).state =
        currentOrders.where((order) => order.id != orderId).toList();
  };
});

/// Provider để clear toàn bộ history
final clearAllHistoryProvider = Provider<Future<void> Function()>((ref) {
  return () async {
    // TODO: Implement clear history from database
    ref.read(historyOrdersProvider.notifier).state = [];
  };
});

/// Provider lấy history count
final historyCountProvider = Provider<int>((ref) {
  final orders = ref.watch(historyOrdersProvider);
  return orders.length;
});

/// Provider lấy filtered history count
final filteredHistoryCountProvider = Provider<int>((ref) {
  final filtered = ref.watch(filteredHistoryProvider);
  return filtered.length;
});

/// Provider lấy today's history count
final todayHistoryCountProvider = Provider<int>((ref) {
  final orders = ref.watch(historyOrdersProvider);
  return orders.where((order) => order.isToday).length;
});

/// Provider lấy this week's history count
final thisWeekHistoryCountProvider = Provider<int>((ref) {
  final orders = ref.watch(historyOrdersProvider);
  return orders.where((order) => order.isThisWeek).length;
});
