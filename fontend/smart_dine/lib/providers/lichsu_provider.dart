// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../models/lichsu_order.dart';

// // ==================== STATE PROVIDERS ====================

// /// Provider cho danh sách lịch sử - BẮT ĐẦU RỖNG
// final historyProvider = StateProvider<List<HistoryOrder>>((ref) {
//   return []; // Không có dữ liệu cứng
// });

// /// Provider để thêm order vào lịch sử
// final addHistoryOrderProvider = Provider<void Function(HistoryOrder)>((ref) {
//   return (HistoryOrder order) {
//     final currentHistory = ref.read(historyProvider);
//     ref.read(historyProvider.notifier).state = [order, ...currentHistory];
//   };
// });

// /// Provider cho search query
// final searchQueryProvider = StateProvider<String>((ref) => '');

// /// Provider cho time filter
// final selectedTimeFilterProvider = StateProvider<String>((ref) => 'today');

// /// Provider cho custom date range
// final customDateRangeProvider = StateProvider<DateTimeRange?>((ref) => null);

// /// Provider cho staff filter
// final staffFilterProvider = StateProvider<Map<String, bool>>((ref) {
//   return {'Nguyễn Văn A': false, 'Trần Thị B': false, 'Lê Văn C': false};
// });

// /// Provider cho dish category filter
// final dishCategoryFilterProvider = StateProvider<Map<String, bool>>((ref) {
//   return {
//     'Bún': false,
//     'Phở': false,
//     'Cơm': false,
//     'Bánh mì': false,
//     'Mì': false,
//   };
// });

// // ==================== COMPUTED PROVIDERS ====================

// /// Provider cho filtered history
// final filteredHistoryProvider = Provider<List<HistoryOrder>>((ref) {
//   var history = ref.watch(historyProvider);
//   final searchQuery = ref.watch(searchQueryProvider);
//   final timeFilter = ref.watch(selectedTimeFilterProvider);
//   final customRange = ref.watch(customDateRangeProvider);
//   final staffFilter = ref.watch(staffFilterProvider);
//   final dishFilter = ref.watch(dishCategoryFilterProvider);

//   // Apply time filter
//   final now = DateTime.now();
//   if (timeFilter == 'today') {
//     final today = DateTime(now.year, now.month, now.day);
//     history =
//         history.where((h) {
//           final orderDate = DateTime(
//             h.servedAt.year,
//             h.servedAt.month,
//             h.servedAt.day,
//           );
//           return orderDate == today;
//         }).toList();
//   } else if (timeFilter == 'week') {
//     final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
//     final startDate = DateTime(
//       startOfWeek.year,
//       startOfWeek.month,
//       startOfWeek.day,
//     );
//     history = history.where((h) => h.servedAt.isAfter(startDate)).toList();
//   } else if (timeFilter == 'custom' && customRange != null) {
//     history =
//         history.where((h) {
//           return h.servedAt.isAfter(customRange.start) &&
//               h.servedAt.isBefore(customRange.end.add(const Duration(days: 1)));
//         }).toList();
//   }

//   // Apply staff filter
//   final activeStaff =
//       staffFilter.entries.where((e) => e.value).map((e) => e.key).toList();
//   if (activeStaff.isNotEmpty) {
//     history = history.where((h) => activeStaff.contains(h.staffName)).toList();
//   }

//   // Apply dish filter
//   final activeDishes =
//       dishFilter.entries.where((e) => e.value).map((e) => e.key).toList();
//   if (activeDishes.isNotEmpty) {
//     history =
//         history.where((h) {
//           return activeDishes.any((dish) => h.dishName.contains(dish));
//         }).toList();
//   }

//   // Apply search
//   if (searchQuery.isNotEmpty) {
//     final query = searchQuery.toLowerCase();
//     history =
//         history.where((h) {
//           return h.dishName.toLowerCase().contains(query) ||
//               h.tableNumber.toLowerCase().contains(query) ||
//               h.staffName.toLowerCase().contains(query);
//         }).toList();
//   }

//   return history;
// });

// /// Provider đếm số filter đang active
// final activeFiltersCountProvider = Provider<int>((ref) {
//   int count = 0;

//   // Đếm staff filters
//   final staffFilter = ref.watch(staffFilterProvider);
//   count += staffFilter.values.where((v) => v).length;

//   // Đếm dish category filters
//   final dishFilter = ref.watch(dishCategoryFilterProvider);
//   count += dishFilter.values.where((v) => v).length;

//   // Đếm time filter (nếu không phải 'today' thì +1)
//   final timeFilter = ref.watch(selectedTimeFilterProvider);
//   if (timeFilter != 'today') count++;

//   return count;
// });

// /// Provider để clear all filters
// final clearAllFiltersProvider = Provider<VoidCallback>((ref) {
//   return () {
//     // Reset search
//     ref.read(searchQueryProvider.notifier).state = '';

//     // Reset time filter
//     ref.read(selectedTimeFilterProvider.notifier).state = 'today';
//     ref.read(customDateRangeProvider.notifier).state = null;

//     // Reset staff filter
//     final staffFilter = ref.read(staffFilterProvider);
//     final resetStaff = Map<String, bool>.fromEntries(
//       staffFilter.keys.map((k) => MapEntry(k, false)),
//     );
//     ref.read(staffFilterProvider.notifier).state = resetStaff;

//     // Reset dish filter
//     final dishFilter = ref.read(dishCategoryFilterProvider);
//     final resetDish = Map<String, bool>.fromEntries(
//       dishFilter.keys.map((k) => MapEntry(k, false)),
//     );
//     ref.read(dishCategoryFilterProvider.notifier).state = resetDish;

//     ref.read(searchQueryProvider.notifier).state = '';
//   };
// });

// /// Provider tổng số lịch sử
// final totalHistoryProvider = Provider<int>((ref) {
//   return ref.watch(historyProvider).length;
// });

// /// Provider lịch sử hôm nay
// final todayHistoryCountProvider = Provider<int>((ref) {
//   final history = ref.watch(historyProvider);
//   final now = DateTime.now();
//   final today = DateTime(now.year, now.month, now.day);

//   return history.where((h) {
//     final orderDate = DateTime(
//       h.servedAt.year,
//       h.servedAt.month,
//       h.servedAt.day,
//     );
//     return orderDate == today;
//   }).length;
// });

// /// Provider nhân viên phục vụ nhiều nhất hôm nay
// final topStaffTodayProvider = Provider<String?>((ref) {
//   final history = ref.watch(historyProvider);
//   final now = DateTime.now();
//   final today = DateTime(now.year, now.month, now.day);

//   final todayHistory =
//       history.where((h) {
//         final orderDate = DateTime(
//           h.servedAt.year,
//           h.servedAt.month,
//           h.servedAt.day,
//         );
//         return orderDate == today;
//       }).toList();

//   if (todayHistory.isEmpty) return null;

//   final staffCounts = <String, int>{};
//   for (final h in todayHistory) {
//     staffCounts[h.staffName] = (staffCounts[h.staffName] ?? 0) + 1;
//   }

//   var maxCount = 0;
//   String? topStaff;
//   staffCounts.forEach((staff, count) {
//     if (count > maxCount) {
//       maxCount = count;
//       topStaff = staff;
//     }
//   });

//   return topStaff;
// });
