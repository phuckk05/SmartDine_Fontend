import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../API/dish_statistics_API.dart';

// Provider cho dish statistics
final dishStatisticsProvider = StateNotifierProvider.family<DishStatisticsNotifier, AsyncValue<DishStatisticsData?>, int>((ref, branchId) {
  return DishStatisticsNotifier(
    ref.read(dishStatisticsApiProvider),
    branchId,
  );
});

class DishStatisticsData {
  final List<Map<String, dynamic>> dishRevenueList;
  final Map<String, List<Map<String, dynamic>>> chartData;
  final int totalDishes;
  final double totalRevenue;
  final String period;

  DishStatisticsData({
    required this.dishRevenueList,
    required this.chartData,
    required this.totalDishes,
    required this.totalRevenue,
    this.period = 'week',
  });

  bool get isEmpty => dishRevenueList.isEmpty && totalDishes == 0;
}

class DishStatisticsNotifier extends StateNotifier<AsyncValue<DishStatisticsData?>> {
  final DishStatisticsAPI _api;
  final int _branchId;

  DishStatisticsNotifier(this._api, this._branchId) : super(const AsyncValue.loading()) {
    loadStatistics();
  }

  Future<void> loadStatistics({String period = 'week'}) async {
    try {
      state = const AsyncValue.loading();
      

      
      // Load dish revenue data and chart data in parallel
      final futures = await Future.wait([
        _api.getDishRevenueData(_branchId),
        _api.getChartData(_branchId),
      ]);
      
      final dishRevenueList = futures[0] as List<Map<String, dynamic>>?;
      final chartData = futures[1] as Map<String, List<Map<String, dynamic>>>?;
      
      if (dishRevenueList != null && chartData != null) {
        // Calculate totals
        int totalDishes = 0;
        double totalRevenue = 0.0;
        
        for (final dish in dishRevenueList) {
          final quantity = int.tryParse(dish['quantity']?.toString() ?? '0') ?? 0;
          totalDishes += quantity;
          
          // Use raw revenue value from API (no need to parse "triệu")
          final revenueNum = double.tryParse(dish['revenue']?.toString() ?? '0') ?? 0.0;
          totalRevenue += revenueNum;
        }
        
        final data = DishStatisticsData(
          dishRevenueList: dishRevenueList,
          chartData: chartData,
          totalDishes: totalDishes,
          totalRevenue: totalRevenue,
          period: period,
        );
        

        state = AsyncValue.data(data);
      } else {

        // Return empty data instead of error
        final emptyData = DishStatisticsData(
          dishRevenueList: [],
          chartData: {},
          totalDishes: 0,
          totalRevenue: 0.0,
          period: period,
        );
        state = AsyncValue.data(emptyData);
      }
    } catch (error, stackTrace) {

      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> refresh({String period = 'week'}) async {
    await loadStatistics(period: period);
  }

  Future<void> changePeriod(String newPeriod) async {
    await loadStatistics(period: newPeriod);
  }
}