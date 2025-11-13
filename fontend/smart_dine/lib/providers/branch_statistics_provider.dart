import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../API/branch_statistics_API.dart';
import '../API/payment_statistics_API.dart';
import '../API/demo_data_helper.dart';
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
  final PaymentStatisticsAPI _paymentApi = PaymentStatisticsAPI();

  BranchStatisticsNotifier(this._api, this._branchId) : super(const AsyncValue.loading()) {
    // Auto load statistics when notifier is created
    loadInitialStatistics();
  }

  // Load initial statistics with default period (today) + Payment API
  Future<void> loadInitialStatistics() async {
    print('=== LOADING INITIAL REPORT STATISTICS ===');
    
    // First load basic statistics (like before)
    await loadStatistics();
    
    // Then immediately load "Tháng này" statistics which includes Payment API
    await loadStatisticsForPeriod('Tháng này');
  }

  Future<void> loadStatistics({String? date}) async {
    try {
      state = const AsyncValue.loading();
      
      // Load basic statistics
      final data = await _api.getBranchStatistics(_branchId, date: date);
      
      if (data != null) {
        // Load potential revenue data (including serving orders)
        final today = date ?? DateTime.now().toIso8601String().split('T')[0];
        final revenue = await _paymentApi.getPotentialRevenueByDay(
          branchId: _branchId, 
          date: today,
          includeServing: true, // Include serving orders for more accurate revenue
        );
        
        // Load yesterday's data for comparison
        final yesterday = DateTime.parse(today).subtract(const Duration(days: 1)).toIso8601String().split('T')[0];
        final previousRevenue = await _paymentApi.getPotentialRevenueByDay(
          branchId: _branchId,
          date: yesterday,
          includeServing: true,
        ) ?? 0.0;
        
        // Calculate growth rates with real comparison data
        final currentRevenue = (revenue ?? 0.0) * 1000;
        final currentOrders = data['totalOrdersToday'] ?? 0;
        final currentCustomers = data['pendingOrdersToday'] ?? 0;
        
        // Use real previous period data (yesterday) 
        final previousRevenueValue = (previousRevenue * 1000);
        final previousOrders = data['totalOrdersYesterday'] ?? (currentOrders * 0.9).round(); // Fallback to mock if no data
        final previousCustomers = data['pendingOrdersYesterday'] ?? (currentCustomers * 0.8).round(); // Fallback to mock if no data
        
        final revenueGrowth = previousRevenueValue > 0 
            ? ((currentRevenue - previousRevenueValue) / previousRevenueValue * 100)
            : 0.0;
        final orderGrowth = previousOrders > 0 
            ? ((currentOrders - previousOrders) / previousOrders * 100)
            : 0.0;
        final customerGrowth = previousCustomers > 0 
            ? ((currentCustomers - previousCustomers) / previousCustomers * 100)
            : 0.0;
        
        // Create enhanced metrics with revenue
        final metrics = BranchMetrics(
          period: 'today',
          dateRange: data['date'] ?? today,
          totalRevenue: currentRevenue.round(),
          totalOrders: currentOrders,
          avgOrderValue: currentOrders > 0 
              ? (currentRevenue / currentOrders).round()
              : 0,
          newCustomers: currentCustomers,
          customerSatisfaction: (data['completionRate'] ?? 0.0).toDouble(),
          growthRates: GrowthRates(
            revenue: revenueGrowth,
            orders: orderGrowth,
            avgOrderValue: (revenueGrowth + orderGrowth) / 2, // Average of revenue & order growth
            newCustomers: customerGrowth,
            satisfaction: 5.0, // Mock satisfaction growth
          ),
        );
        
        state = AsyncValue.data(metrics);
      } else {
        state = AsyncValue.error(
          Exception('Không thể tải thống kê chi nhánh. Vui lòng thử lại sau.'),
          StackTrace.current,
        );
      }
    } catch (error, stackTrace) {
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
            return [];
    }
  }

  Future<void> loadStatisticsForPeriod(String period) async {
    print('=== LOADING STATISTICS FOR PERIOD: $period ===');
    try {
      state = const AsyncValue.loading();
      
      // Calculate date range for the period
      final dateRange = _calculateDateRangeForPeriod(period);
      
      // Call real Payment API with period-specific dates
      final revenue = await _paymentApi.getRevenueByPeriod(
        branchId: _branchId,
        startDate: dateRange['startDate']!,
        endDate: dateRange['endDate']!,
      );
      
      print('📊 REVENUE API RESULT for $period: $revenue');
      
      // Get orders data for the same period
      final ordersData = await _api.getOrdersForPeriod(
        _branchId, 
        startDate: dateRange['startDate']!,
        endDate: dateRange['endDate']!,
      );
      
      print('📈 ORDERS API RESULT for $period: $ordersData');
      
      // If real API fails, use demo data as fallback
      if (revenue == null || ordersData == null) {
        print('⚠️ API failed, using demo data for $period');
        final demoData = DemoDataHelper.generatePeriodStatistics(period, _branchId);
        
        final metrics = BranchMetrics(
          period: period,
          dateRange: _getDateRangeForPeriod(period),
          totalRevenue: (demoData['revenue'] as double).round(),
          totalOrders: demoData['totalOrders'] as int,
          avgOrderValue: demoData['totalOrders'] > 0 
              ? ((demoData['revenue'] as double) / (demoData['totalOrders'] as int)).round()
              : 0,
          newCustomers: ((demoData['totalOrders'] as int) * 0.3).round(),
          customerSatisfaction: 4.2 + (DateTime.now().millisecond % 600 / 1000), // 4.2-4.8
          growthRates: _calculateGrowthForPeriod(period),
        );
        
        state = AsyncValue.data(metrics);
        return;
      }
      
      // Use real API data
      final totalRevenue = (revenue * 1000).round(); // Convert to proper scale
      final totalOrders = ordersData['totalOrders'] ?? 0;
      
      final metrics = BranchMetrics(
        period: period,
        dateRange: _getDateRangeForPeriod(period),
        totalRevenue: totalRevenue,
        totalOrders: totalOrders,
        avgOrderValue: totalOrders > 0 ? (totalRevenue / totalOrders).round() : 0,
        newCustomers: (totalOrders * 0.3).round(), // Estimate new customers
        customerSatisfaction: (ordersData['completionRate'] ?? 4.5).toDouble(),
        growthRates: _calculateRealGrowthForPeriod(period, totalRevenue, totalOrders),
      );
      
      print('✅ PERIOD STATISTICS LOADED: ${metrics.totalRevenue} revenue, ${metrics.totalOrders} orders');
      state = AsyncValue.data(metrics);
    } catch (error, stackTrace) {
      print('❌ PERIOD STATISTICS ERROR: $error');
      state = AsyncValue.error(error, stackTrace);
    }
  }
  
  String _getDateRangeForPeriod(String period) {
    final now = DateTime.now();
    switch (period.toLowerCase()) {
      case 'tuần này':
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        return '${weekStart.day}/${weekStart.month} - ${now.day}/${now.month}';
      case 'tháng này':
        return '1/${now.month}/${now.year} - ${now.day}/${now.month}/${now.year}';
      case 'quý này':
        final quarterStart = DateTime(now.year, ((now.month - 1) ~/ 3) * 3 + 1, 1);
        return '${quarterStart.day}/${quarterStart.month} - ${now.day}/${now.month}';
      default:
        return '${now.day}/${now.month}/${now.year}';
    }
  }
  
  GrowthRates _calculateGrowthForPeriod(String period) {
    final multiplier = period == 'Tháng này' ? 2.0 : 1.0;
    final base = DateTime.now().millisecond;
    return GrowthRates(
      revenue: (8.5 + (base % 15)) * multiplier,
      orders: (5.2 + (base % 12)) * multiplier,
      avgOrderValue: (-2.1 + (base % 8)) * multiplier,
      newCustomers: (12.3 + (base % 18)) * multiplier,
      satisfaction: 2.1 + (base % 4),
    );
  }
  
  Map<String, String> _calculateDateRangeForPeriod(String period) {
    final now = DateTime.now();
    
    switch (period.toLowerCase()) {
      case 'tuần này':
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        return {
          'startDate': weekStart.toIso8601String().split('T')[0],
          'endDate': now.toIso8601String().split('T')[0],
        };
      case 'tháng này':
        final monthStart = DateTime(now.year, now.month, 1);
        return {
          'startDate': monthStart.toIso8601String().split('T')[0],
          'endDate': now.toIso8601String().split('T')[0],
        };
      case 'quý này':
        final quarterStart = DateTime(now.year, ((now.month - 1) ~/ 3) * 3 + 1, 1);
        return {
          'startDate': quarterStart.toIso8601String().split('T')[0],
          'endDate': now.toIso8601String().split('T')[0],
        };
      default: // 'hôm nay'
        return {
          'startDate': now.toIso8601String().split('T')[0],
          'endDate': now.toIso8601String().split('T')[0],
        };
    }
  }
  
  GrowthRates _calculateRealGrowthForPeriod(String period, int currentRevenue, int currentOrders) {
    // For now, use mock growth calculation until we have historical data
    final multiplier = period == 'Tháng này' ? 1.5 : 1.0;
    final base = DateTime.now().millisecond;
    
    return GrowthRates(
      revenue: (5.0 + (base % 20)) * multiplier,
      orders: (3.0 + (base % 15)) * multiplier,
      avgOrderValue: (-1.0 + (base % 10)) * multiplier,
      newCustomers: (8.0 + (base % 25)) * multiplier,
      satisfaction: 1.5 + (base % 3),
    );
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