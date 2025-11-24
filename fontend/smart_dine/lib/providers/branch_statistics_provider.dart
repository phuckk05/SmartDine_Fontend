import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../API/branch_statistics_API.dart';
import '../API/payment_statistics_API.dart';
import '../models/statistics.dart';
import '../core/realtime_notifier.dart';

// Provider cho branch statistics API với date parameter
final branchStatisticsProvider = StateNotifierProvider.family<BranchStatisticsNotifier, AsyncValue<BranchMetrics?>, int>((ref, branchId) {
  return BranchStatisticsNotifier(
    ref.read(branchStatisticsApiProvider),
    branchId,
  );
});

// Provider cho branch statistics với date filter (sử dụng branchId làm key duy nhất) - KHÔNG CÓ REALTIME
final branchStatisticsWithDateProvider = StateNotifierProvider.family<BranchStatisticsNotifier, AsyncValue<BranchMetrics?>, int>((ref, branchId) {
  final notifier = BranchStatisticsNotifier(
    ref.read(branchStatisticsApiProvider),
    branchId,
  );
  // Disable realtime polling for reports screen
  notifier.pauseRealtime();
  return notifier;
});

class BranchStatisticsNotifier extends RealtimeNotifier<BranchMetrics?> {
  final BranchStatisticsAPI _api;
  final int _branchId;
  final PaymentStatisticsAPI _paymentApi = PaymentStatisticsAPI();
  DateTime _selectedDate = DateTime.now();

  BranchStatisticsNotifier(this._api, this._branchId);

  @override
  Future<BranchMetrics?> loadData() async {
    final selectedDate = _selectedDate;
    final dateString = selectedDate.toIso8601String().split('T')[0];

    // Load basic statistics
    final data = await _api.getBranchStatistics(_branchId, date: dateString);
    print('BranchStatisticsNotifier: API data for $_branchId on $dateString: $data');

    if (data != null) {
      // Load potential revenue data (including serving orders)
      final revenue = await _paymentApi.getPotentialRevenueByDay(
        branchId: _branchId,
        date: dateString,
        includeServing: true, // Include serving orders for more accurate revenue
      );

      print('BranchStatisticsNotifier: Revenue data for $_branchId on $dateString: $revenue');

      final totalRevenue = ((revenue ?? 0.0) * 1000).round();
      final totalOrders = data['totalOrdersToday'] ?? 0;
      final newCustomers = totalOrders; // Mỗi đơn hàng tương ứng với một khách hàng

      print('BranchStatisticsNotifier: Parsed data - totalOrders: $totalOrders, totalRevenue: $totalRevenue, newCustomers: $newCustomers');

      // Check if we have meaningful data - đơn hàng quan trọng hơn revenue
      bool hasRealData = totalOrders > 0 || (revenue != null && revenue > 0);

      print('BranchStatisticsNotifier: hasRealData check - orders: ${totalOrders > 0}, revenue: ${(revenue != null && revenue > 0)}, hasRealData: $hasRealData');

      if (!hasRealData) {
        // Tạo empty metrics thay vì throw exception
        final emptyMetrics = BranchMetrics(
          period: 'today',
          dateRange: data['date'] ?? dateString,
          totalRevenue: 0,
          totalOrders: 0,
          avgOrderValue: 0,
          newCustomers: 0,
          customerSatisfaction: 0.0,
          growthRates: GrowthRates(
            revenue: 0.0,
            orders: 0.0,
            avgOrderValue: 0.0,
            newCustomers: 0.0,
            satisfaction: 0.0,
          ),
          isEmpty: true, // Flag đánh dấu empty state
        );

        print('BranchStatisticsNotifier: Returning empty metrics due to no real data');
        return emptyMetrics;
      }      // Calculate growth rates by comparing with previous day
      final previousDate = selectedDate.subtract(const Duration(days: 1));
      final previousDateString = previousDate.toIso8601String().split('T')[0];

      // Load previous day data for growth calculation
      final previousData = await _api.getBranchStatistics(_branchId, date: previousDateString);
      final previousRevenue = await _paymentApi.getPotentialRevenueByDay(
        branchId: _branchId,
        date: previousDateString,
        includeServing: true,
      );

      // Calculate growth rates
      double revenueGrowth = 0.0;
      double ordersGrowth = 0.0;
      double avgOrderValueGrowth = 0.0;
      double newCustomersGrowth = 0.0;
      double satisfactionGrowth = 0.0;

      if (previousRevenue != null && previousRevenue > 0 && revenue != null) {
        revenueGrowth = ((revenue - previousRevenue) / previousRevenue) * 100;
      }

      final previousOrders = previousData?['totalOrdersToday'] ?? 0;
      if (previousOrders > 0) {
        ordersGrowth = ((totalOrders - previousOrders) / previousOrders) * 100;
      }

      // Calculate avg order value growth
      final currentAvgOrderValue = (revenue != null && totalOrders > 0) ? (revenue * 1000) / totalOrders : 0.0;
      final previousAvgOrderValue = (previousRevenue != null && previousOrders > 0) ? (previousRevenue * 1000) / previousOrders : 0.0;
      if (previousAvgOrderValue > 0) {
        avgOrderValueGrowth = ((currentAvgOrderValue - previousAvgOrderValue) / previousAvgOrderValue) * 100;
      }

      final previousNewCustomers = previousData?['pendingOrdersToday'] ?? 0;
      if (previousNewCustomers > 0) {
        newCustomersGrowth = ((newCustomers - previousNewCustomers) / previousNewCustomers) * 100;
      }

      final currentSatisfaction = (data['completionRate'] ?? 0.0).toDouble();
      final previousSatisfaction = (previousData?['completionRate'] ?? 0.0).toDouble();
      if (previousSatisfaction > 0) {
        satisfactionGrowth = ((currentSatisfaction - previousSatisfaction) / previousSatisfaction) * 100;
      }

      // Create enhanced metrics with revenue
      final metrics = BranchMetrics(
        period: 'today',
        dateRange: data['date'] ?? dateString,
        totalRevenue: totalRevenue,
        totalOrders: totalOrders,
        avgOrderValue: currentAvgOrderValue.round(),
        newCustomers: newCustomers,
        customerSatisfaction: currentSatisfaction,
        growthRates: GrowthRates(
          revenue: revenueGrowth,
          orders: ordersGrowth,
          avgOrderValue: avgOrderValueGrowth,
          newCustomers: newCustomersGrowth,
          satisfaction: satisfactionGrowth,
        ),
      );

      print('BranchStatisticsNotifier: Final metrics - Orders: $totalOrders, Customers: $newCustomers, Revenue: $totalRevenue');
      return metrics;
    } else {
      // Return empty data instead of error
      final dateString = _selectedDate.toIso8601String().split('T')[0];
      final emptyData = BranchMetrics(
        period: 'today',
        dateRange: dateString,
        totalRevenue: 0,
        totalOrders: 0,
        avgOrderValue: 0,
        newCustomers: 0,
        customerSatisfaction: 0.0,
        growthRates: GrowthRates(
          revenue: 0.0,
          orders: 0.0,
          avgOrderValue: 0.0,
          newCustomers: 0.0,
          satisfaction: 0.0,
        ),
        isEmpty: true,
      );
      return emptyData;
    }
  }

  @override
  Duration get pollingInterval => const Duration(minutes: 2); // Update every 2 minutes for statistics

  // Method to update selected date
  void setSelectedDate(DateTime date) {
    // Only reload if date actually changed
    if (_selectedDate != date) {
      _selectedDate = date;
      refresh(); // Manual refresh when date changes
    }
  }

  // Keep the old method for backward compatibility
  Future<void> loadStatistics({DateTime? date}) async {
    if (date != null) {
      _selectedDate = date;
      print('BranchStatisticsNotifier: Date updated to $_selectedDate');
    }
    print('BranchStatisticsNotifier: Starting refresh for branch $_branchId on date $_selectedDate');
    await refresh();
  }
}