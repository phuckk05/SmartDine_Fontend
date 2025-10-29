import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../API/order_management_API.dart';
import '../API/table_management_API.dart';

// Provider cho hoạt động hôm nay
final todayActivitiesProvider = StateNotifierProvider.family<TodayActivitiesNotifier, AsyncValue<TodayActivitiesData>, int>((ref, branchId) {
  return TodayActivitiesNotifier(
    ref.read(orderManagementApiProvider),
    ref.read(tableManagementApiProvider),
    branchId,
  );
});

class TodayActivitiesData {
  final int totalOrders;
  final int completedOrders;
  final int servingOrders;
  final int cancelledOrders;
  final int totalTables;
  final int unpaidTables;
  final Map<String, int> statusBreakdown;
  final Map<String, int> hourlyBreakdown;
  final String date;
  final DateTime lastUpdated;

  TodayActivitiesData({
    required this.totalOrders,
    required this.completedOrders,
    required this.servingOrders,
    required this.cancelledOrders,
    required this.totalTables,
    required this.unpaidTables,
    required this.statusBreakdown,
    required this.hourlyBreakdown,
    required this.date,
    required this.lastUpdated,
  });
}

class TodayActivitiesNotifier extends StateNotifier<AsyncValue<TodayActivitiesData>> {
  final OrderManagementAPI _orderApi;
  final TableManagementAPI _tableApi;
  final int _branchId;

  TodayActivitiesNotifier(this._orderApi, this._tableApi, this._branchId) : super(const AsyncValue.loading()) {
    loadTodayActivities();
  }

  Future<void> loadTodayActivities() async {
    try {
      state = const AsyncValue.loading();
      
      // Gọi các API song song
      final futures = await Future.wait([
        _orderApi.getTodayOrderSummary(_branchId),
        _tableApi.getTablesByBranch(_branchId),
        _orderApi.getUnpaidOrderTableIdsToday(),
      ]);
      
      final summaryData = futures[0] as Map<String, dynamic>?;
      final tables = futures[1] as List?;
      final unpaidTableIds = futures[2] as List<int>?;
      
      if (summaryData != null) {
        final statusBreakdown = Map<String, int>.from(summaryData['statusBreakdown'] ?? {});
        final hourlyBreakdown = (summaryData['hourlyBreakdown'] as Map<String, dynamic>?)?.map(
          (key, value) => MapEntry(key, (value as num).toInt())
        ) ?? <String, int>{};
        
        final data = TodayActivitiesData(
          totalOrders: summaryData['totalOrders'] ?? 0,
          completedOrders: statusBreakdown['completed'] ?? 0,
          servingOrders: statusBreakdown['serving'] ?? 0,
          cancelledOrders: statusBreakdown['cancelled'] ?? 0,
          totalTables: tables?.length ?? 0,
          unpaidTables: unpaidTableIds?.length ?? 0,
          statusBreakdown: statusBreakdown,
          hourlyBreakdown: hourlyBreakdown,
          date: summaryData['date'] ?? '',
          lastUpdated: DateTime.now(),
        );
        
        state = AsyncValue.data(data);
      } else {
        state = AsyncValue.error(
          Exception('Không thể tải dữ liệu hoạt động hôm nay'),
          StackTrace.current,
        );
      }
    } catch (error, stackTrace) {
      print('Error loading today activities: $error');
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> refresh() async {
    await loadTodayActivities();
  }
}