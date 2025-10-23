import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mart_dine/features/service/dashboard_service.dart';
import 'package:mart_dine/models/dashboard_model.dart';

/// Provider cho Dashboard Mock Service
final dashboardMockServiceProvider = Provider<DashboardMockService>((ref) {
  return DashboardMockService();
});

/// Provider cho company ID hiện tại
final currentCompanyIdProvider = StateProvider<String>((ref) {
  return 'company_mock_001';
});

/// Provider cho filter thời gian (Năm/Tháng/Tuần/Ngày)
final revenueFilterProvider = StateProvider<RevenueFilter>((ref) {
  return RevenueFilter.month;
});

/// Provider cho custom date range
final customDateRangeProvider = StateProvider<DateTimeRange?>((ref) {
  return null;
});

/// Provider cho selected branch (để xem chi tiết)
final selectedBranchProvider = StateProvider<String?>((ref) => null);

/// Provider cho dữ liệu dashboard chính
final dashboardDataProvider = FutureProvider<DashboardData>((ref) async {
  final service = ref.watch(dashboardMockServiceProvider);
  final companyId = ref.watch(currentCompanyIdProvider);
  final filter = ref.watch(revenueFilterProvider);
  final customRange = ref.watch(customDateRangeProvider);

  return await service.getDashboardData(
    companyId: companyId,
    filter: filter,
    startDate: customRange?.start,
    endDate: customRange?.end,
  );
});

/// Provider cho realtime stats
final realtimeStatsProvider = StreamProvider<RealtimeStats>((ref) {
  final companyId = ref.watch(currentCompanyIdProvider);
  final service = ref.watch(dashboardMockServiceProvider);

  return service.getRealtimeStats(companyId);
});

/// Provider cho top selling items
final topItemsProvider = FutureProvider<List<TopItem>>((ref) async {
  final companyId = ref.watch(currentCompanyIdProvider);
  final service = ref.watch(dashboardMockServiceProvider);
  final filter = ref.watch(revenueFilterProvider);

  // Calculate date range
  final now = DateTime.now();
  DateTimeRange dateRange;

  switch (filter) {
    case RevenueFilter.day:
      final startOfDay = DateTime(now.year, now.month, now.day);
      dateRange = DateTimeRange(start: startOfDay, end: now);
      break;

    case RevenueFilter.week:
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      dateRange = DateTimeRange(
        start: DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day),
        end: now,
      );
      break;

    case RevenueFilter.month:
      final startOfMonth = DateTime(now.year, now.month, 1);
      dateRange = DateTimeRange(start: startOfMonth, end: now);
      break;

    case RevenueFilter.year:
      final startOfYear = DateTime(now.year, 1, 1);
      dateRange = DateTimeRange(start: startOfYear, end: now);
      break;
  }

  return await service.getTopItems(
    companyId: companyId,
    dateRange: dateRange,
    limit: 10,
  );
});

// ==================== COMPUTED PROVIDERS ====================

/// Provider cho danh sách chi nhánh
final branchesProvider = Provider<List<BranchRevenueData>>((ref) {
  final dashboardAsync = ref.watch(dashboardDataProvider);

  return dashboardAsync.when(
    data: (data) => data.branches,
    loading: () => [],
    error: (_, __) => [],
  );
});

/// Provider cho dữ liệu biểu đồ
final revenueChartProvider = Provider<List<RevenuePoint>>((ref) {
  final dashboardAsync = ref.watch(dashboardDataProvider);

  return dashboardAsync.when(
    data: (data) => data.revenueChart,
    loading: () => [],
    error: (_, __) => [],
  );
});

/// Provider cho summary
final dashboardSummaryProvider = Provider<DashboardSummary?>((ref) {
  final dashboardAsync = ref.watch(dashboardDataProvider);

  return dashboardAsync.when(
    data: (data) => data.summary,
    loading: () => null,
    error: (_, __) => null,
  );
});

/// Provider kiểm tra có dữ liệu
final hasDashboardDataProvider = Provider<bool>((ref) {
  final dashboardAsync = ref.watch(dashboardDataProvider);
  return dashboardAsync.when(
    data: (data) => data.branches.isNotEmpty,
    loading: () => false,
    error: (_, __) => false,
  );
});

/// Provider tổng số chi nhánh
final totalBranchesCountProvider = Provider<int>((ref) {
  final branches = ref.watch(branchesProvider);
  return branches.length;
});

/// Provider tổng doanh thu
final totalRevenueProvider = Provider<double>((ref) {
  final summary = ref.watch(dashboardSummaryProvider);
  return summary?.totalRevenue ?? 0;
});

/// Provider tổng số đơn
final totalOrdersProvider = Provider<int>((ref) {
  final summary = ref.watch(dashboardSummaryProvider);
  return summary?.totalOrders ?? 0;
});

// ==================== ACTION PROVIDERS ====================

/// Provider cho action refresh dashboard
final refreshDashboardProvider = Provider<void Function()>((ref) {
  return () {
    ref.invalidate(dashboardDataProvider);
    ref.invalidate(realtimeStatsProvider);
    ref.invalidate(topItemsProvider);
  };
});

/// Provider cho action change filter
final changeFilterProvider = Provider<void Function(RevenueFilter)>((ref) {
  return (RevenueFilter newFilter) {
    ref.read(revenueFilterProvider.notifier).state = newFilter;
    ref.invalidate(dashboardDataProvider);
    ref.invalidate(topItemsProvider);
  };
});

/// Provider cho action set custom date range
final setDateRangeProvider = Provider<void Function(DateTimeRange?)>((ref) {
  return (DateTimeRange? range) {
    ref.read(customDateRangeProvider.notifier).state = range;
    ref.invalidate(dashboardDataProvider);
    ref.invalidate(topItemsProvider);
  };
});

// ==================== UI STATE PROVIDERS ====================

/// Provider cho loading state
final isDashboardLoadingProvider = Provider<bool>((ref) {
  final dashboardAsync = ref.watch(dashboardDataProvider);
  return dashboardAsync.isLoading;
});

/// Provider cho error state
final dashboardErrorProvider = Provider<String?>((ref) {
  final dashboardAsync = ref.watch(dashboardDataProvider);
  return dashboardAsync.when(
    data: (_) => null,
    loading: () => null,
    error: (error, _) => error.toString(),
  );
});
