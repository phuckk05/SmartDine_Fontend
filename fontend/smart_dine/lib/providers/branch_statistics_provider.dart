import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../API/branch_statistics_API.dart';
import '../models/statistics.dart';

// Provider cho branch statistics API
final branchStatisticsProvider = StateNotifierProvider.family<BranchStatisticsNotifier, AsyncValue<BranchMetrics?>, int>((ref, branchId) {
  return BranchStatisticsNotifier(
    ref.read(branchStatisticsApiProvider),
    branchId,
  );
});

class BranchStatisticsNotifier extends StateNotifier<AsyncValue<BranchMetrics?>> {
  final BranchStatisticsAPI _api;
  final int _branchId;

  BranchStatisticsNotifier(this._api, this._branchId) : super(const AsyncValue.loading()) {
    // Auto load statistics when notifier is created
    loadStatistics();
  }

  Future<void> loadStatistics({String? date}) async {
    try {
      state = const AsyncValue.loading();
      final data = await _api.getBranchStatistics(_branchId, date: date);
      
      if (data != null) {
        // Convert API response to BranchMetrics model
        final metrics = BranchMetrics.fromMap(data);
        state = AsyncValue.data(metrics);
      } else {
        state = AsyncValue.error(
          Exception('Không thể tải thống kê chi nhánh. Vui lòng thử lại sau.'),
          StackTrace.current,
        );
      }
    } catch (error, stackTrace) {
      print('Provider error: $error');
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<List<RevenueTrend>> loadRevenueTrends({String period = 'day', int days = 7}) async {
    try {
      final data = await _api.getRevenueTrends(_branchId, period: period, days: days);
      
      if (data != null) {
        return data.map((json) => RevenueTrend.fromMap(json)).toList();
      }
      return [];
    } catch (error) {
      print('Error loading revenue trends: $error');
      return [];
    }
  }

  Future<List<TopDish>> loadTopDishes({int limit = 5}) async {
    try {
      final data = await _api.getTopDishes(_branchId, limit: limit);
      
      if (data != null) {
        return data.map((json) => TopDish.fromMap(json)).toList();
      }
      return [];
    } catch (error) {
      print('Error loading top dishes: $error');
      return [];
    }
  }

  Future<List<EmployeePerformance>> loadEmployeePerformance() async {
    try {
      final data = await _api.getEmployeePerformance(_branchId);
      
      if (data != null) {
        return data.map((json) => EmployeePerformance.fromMap(json)).toList();
      }
      return [];
    } catch (error) {
      print('Error loading employee performance: $error');
      return [];
    }
  }
}

// Provider cho revenue trends
final revenueTrendsProvider = FutureProvider.family<List<RevenueTrend>, Map<String, dynamic>>((ref, params) async {
  final branchId = params['branchId'] as int;
  final period = params['period'] as String? ?? 'day';
  final days = params['days'] as int? ?? 7;
  
  final notifier = ref.read(branchStatisticsProvider(branchId).notifier);
  return notifier.loadRevenueTrends(period: period, days: days);
});

// Provider cho top dishes
final topDishesProvider = FutureProvider.family<List<TopDish>, Map<String, dynamic>>((ref, params) async {
  final branchId = params['branchId'] as int;
  final limit = params['limit'] as int? ?? 5;
  
  final notifier = ref.read(branchStatisticsProvider(branchId).notifier);
  return notifier.loadTopDishes(limit: limit);
});

// Provider cho employee performance
final employeePerformanceProvider = FutureProvider.family<List<EmployeePerformance>, int>((ref, branchId) async {
  final notifier = ref.read(branchStatisticsProvider(branchId).notifier);
  return notifier.loadEmployeePerformance();
});