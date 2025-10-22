import 'dart:math';
import 'package:mart_dine/models/dashboard_model.dart';

/// Service cung cấp dữ liệu MOCK cho Dashboard
class DashboardMockService {
  final _random = Random();

  /// Lấy dữ liệu dashboard MOCK
  Future<DashboardData> getDashboardData({
    required String companyId,
    required RevenueFilter filter,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 800));

    // Calculate date range
    final dateRange = _calculateDateRange(filter, startDate, endDate);

    // Generate mock data
    final branches = _getMockBranches(dateRange);
    final chartData = _getMockChartData(filter, dateRange);
    final summary = _getMockSummary(branches);

    return DashboardData(
      branches: branches,
      revenueChart: chartData,
      summary: summary,
      lastUpdated: DateTime.now(),
    );
  }

  /// Lấy real-time stats MOCK
  Stream<RealtimeStats> getRealtimeStats(String companyId) async* {
    while (true) {
      await Future.delayed(const Duration(seconds: 3));
      yield RealtimeStats(
        activeOrders: _random.nextInt(15) + 5, // 5-20 đơn
        pendingOrders: _random.nextInt(8) + 2, // 2-10 đơn
        completedToday: _random.nextInt(100) + 50, // 50-150 đơn
        todayRevenue: (_random.nextDouble() * 50 + 20) * 1000000, // 20-70M
        lastUpdate: DateTime.now(),
      );
    }
  }

  /// Lấy top món bán chạy MOCK
  Future<List<TopItem>> getTopItems({
    required String companyId,
    required DateTimeRange dateRange,
    int limit = 10,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final items = [
      TopItem(
        itemId: 'item_001',
        itemName: 'Phở Bò Tái',
        quantity: 156,
        revenue: 7800000,
        categoryName: 'Món chính',
      ),
      TopItem(
        itemId: 'item_002',
        itemName: 'Cơm Tấm Sườn',
        quantity: 142,
        revenue: 6390000,
        categoryName: 'Món chính',
      ),
      TopItem(
        itemId: 'item_003',
        itemName: 'Bún Chả Hà Nội',
        quantity: 128,
        revenue: 5760000,
        categoryName: 'Món chính',
      ),
      TopItem(
        itemId: 'item_004',
        itemName: 'Bánh Mì Đặc Biệt',
        quantity: 203,
        revenue: 5075000,
        categoryName: 'Món ăn sáng',
      ),
      TopItem(
        itemId: 'item_005',
        itemName: 'Cà Phê Sữa Đá',
        quantity: 245,
        revenue: 4900000,
        categoryName: 'Đồ uống',
      ),
      TopItem(
        itemId: 'item_006',
        itemName: 'Gỏi Cuốn',
        quantity: 89,
        revenue: 3115000,
        categoryName: 'Khai vị',
      ),
      TopItem(
        itemId: 'item_007',
        itemName: 'Lẩu Thái',
        quantity: 45,
        revenue: 6750000,
        categoryName: 'Món đặc biệt',
      ),
      TopItem(
        itemId: 'item_008',
        itemName: 'Trà Sữa Trân Châu',
        quantity: 178,
        revenue: 4095000,
        categoryName: 'Đồ uống',
      ),
      TopItem(
        itemId: 'item_009',
        itemName: 'Nem Rán',
        quantity: 112,
        revenue: 3360000,
        categoryName: 'Khai vị',
      ),
      TopItem(
        itemId: 'item_010',
        itemName: 'Bánh Flan',
        quantity: 95,
        revenue: 1425000,
        categoryName: 'Tráng miệng',
      ),
    ];

    return items.take(limit).toList();
  }

  // ==================== PRIVATE METHODS ====================

  /// Generate mock branches data
  List<BranchRevenueData> _getMockBranches(DateTimeRange dateRange) {
    return [
      BranchRevenueData(
        branchId: 'branch_001',
        branchName: 'Chi nhánh Quận 1',
        branchCode: 'CN-Q1',
        revenue: 124.5,
        orderCount: 456,
        percentage: 67.2,
        target: 185.0,
        hasData: true,
        status: BranchStatus.active,
      ),
      BranchRevenueData(
        branchId: 'branch_002',
        branchName: 'Chi nhánh Quận 3',
        branchCode: 'CN-Q3',
        revenue: 98.3,
        orderCount: 382,
        percentage: 54.6,
        target: 180.0,
        hasData: true,
        status: BranchStatus.active,
      ),
      BranchRevenueData(
        branchId: 'branch_003',
        branchName: 'Chi nhánh Thủ Đức',
        branchCode: 'CN-TD',
        revenue: 156.8,
        orderCount: 521,
        percentage: 87.1,
        target: 180.0,
        hasData: true,
        status: BranchStatus.active,
      ),
      BranchRevenueData(
        branchId: 'branch_004',
        branchName: 'Chi nhánh Bình Thạnh',
        branchCode: 'CN-BT',
        revenue: 89.2,
        orderCount: 298,
        percentage: 49.6,
        target: 180.0,
        hasData: true,
        status: BranchStatus.active,
      ),
    ];
  }

  /// Generate mock chart data
  List<RevenuePoint> _getMockChartData(
    RevenueFilter filter,
    DateTimeRange dateRange,
  ) {
    final now = DateTime.now();

    switch (filter) {
      case RevenueFilter.day:
        // Dữ liệu theo giờ (mỗi 3 giờ)
        return [
          RevenuePoint(
            date: DateTime(now.year, now.month, now.day, 0),
            amount: 8.5,
            label: '0h',
            orderCount: 12,
          ),
          RevenuePoint(
            date: DateTime(now.year, now.month, now.day, 3),
            amount: 5.2,
            label: '3h',
            orderCount: 8,
          ),
          RevenuePoint(
            date: DateTime(now.year, now.month, now.day, 6),
            amount: 15.8,
            label: '6h',
            orderCount: 28,
          ),
          RevenuePoint(
            date: DateTime(now.year, now.month, now.day, 9),
            amount: 32.4,
            label: '9h',
            orderCount: 56,
          ),
          RevenuePoint(
            date: DateTime(now.year, now.month, now.day, 12),
            amount: 68.9,
            label: '12h',
            orderCount: 124,
          ),
          RevenuePoint(
            date: DateTime(now.year, now.month, now.day, 15),
            amount: 45.6,
            label: '15h',
            orderCount: 82,
          ),
          RevenuePoint(
            date: DateTime(now.year, now.month, now.day, 18),
            amount: 89.3,
            label: '18h',
            orderCount: 156,
          ),
          RevenuePoint(
            date: DateTime(now.year, now.month, now.day, 21),
            amount: 72.5,
            label: '21h',
            orderCount: 132,
          ),
        ];

      case RevenueFilter.week:
        // Dữ liệu 7 ngày
        return [
          RevenuePoint(
            date: now.subtract(const Duration(days: 6)),
            amount: 45.2,
            label: 'T2',
            orderCount: 156,
          ),
          RevenuePoint(
            date: now.subtract(const Duration(days: 5)),
            amount: 52.8,
            label: 'T3',
            orderCount: 182,
          ),
          RevenuePoint(
            date: now.subtract(const Duration(days: 4)),
            amount: 48.5,
            label: 'T4',
            orderCount: 168,
          ),
          RevenuePoint(
            date: now.subtract(const Duration(days: 3)),
            amount: 61.3,
            label: 'T5',
            orderCount: 205,
          ),
          RevenuePoint(
            date: now.subtract(const Duration(days: 2)),
            amount: 78.9,
            label: 'T6',
            orderCount: 267,
          ),
          RevenuePoint(
            date: now.subtract(const Duration(days: 1)),
            amount: 95.6,
            label: 'T7',
            orderCount: 324,
          ),
          RevenuePoint(date: now, amount: 89.2, label: 'CN', orderCount: 298),
        ];

      case RevenueFilter.month:
        // Dữ liệu 5 tuần
        return [
          RevenuePoint(
            date: DateTime(now.year, now.month - 1, 1),
            amount: 245.8,
            label: 'T1',
            orderCount: 856,
          ),
          RevenuePoint(
            date: DateTime(now.year, now.month - 1, 8),
            amount: 312.5,
            label: 'T2',
            orderCount: 1024,
          ),
          RevenuePoint(
            date: DateTime(now.year, now.month - 1, 15),
            amount: 289.3,
            label: 'T3',
            orderCount: 945,
          ),
          RevenuePoint(
            date: DateTime(now.year, now.month - 1, 22),
            amount: 356.7,
            label: 'T4',
            orderCount: 1156,
          ),
          RevenuePoint(
            date: DateTime(now.year, now.month, 1),
            amount: 398.2,
            label: 'T5',
            orderCount: 1289,
          ),
        ];

      case RevenueFilter.year:
        // Dữ liệu 12 tháng
        return [
          RevenuePoint(
            date: DateTime(now.year, 1, 1),
            amount: 856.3,
            label: 'T1',
            orderCount: 2845,
          ),
          RevenuePoint(
            date: DateTime(now.year, 2, 1),
            amount: 923.7,
            label: 'T2',
            orderCount: 3012,
          ),
          RevenuePoint(
            date: DateTime(now.year, 3, 1),
            amount: 1045.2,
            label: 'T3',
            orderCount: 3456,
          ),
          RevenuePoint(
            date: DateTime(now.year, 4, 1),
            amount: 989.5,
            label: 'T4',
            orderCount: 3245,
          ),
          RevenuePoint(
            date: DateTime(now.year, 5, 1),
            amount: 1123.8,
            label: 'T5',
            orderCount: 3678,
          ),
          RevenuePoint(
            date: DateTime(now.year, 6, 1),
            amount: 1245.6,
            label: 'T6',
            orderCount: 4012,
          ),
          RevenuePoint(
            date: DateTime(now.year, 7, 1),
            amount: 1356.9,
            label: 'T7',
            orderCount: 4356,
          ),
          RevenuePoint(
            date: DateTime(now.year, 8, 1),
            amount: 1289.4,
            label: 'T8',
            orderCount: 4156,
          ),
          RevenuePoint(
            date: DateTime(now.year, 9, 1),
            amount: 1198.2,
            label: 'T9',
            orderCount: 3890,
          ),
          RevenuePoint(
            date: DateTime(now.year, 10, 1),
            amount: 1423.7,
            label: 'T10',
            orderCount: 4567,
          ),
          RevenuePoint(
            date: DateTime(now.year, 11, 1),
            amount: 1534.5,
            label: 'T11',
            orderCount: 4890,
          ),
          RevenuePoint(
            date: DateTime(now.year, 12, 1),
            amount: 1689.3,
            label: 'T12',
            orderCount: 5234,
          ),
        ];
    }
  }

  /// Generate mock summary
  DashboardSummary _getMockSummary(List<BranchRevenueData> branches) {
    final totalRevenue = branches.fold<double>(
      0,
      (sum, branch) => sum + (branch.revenue * 1000000),
    );

    final totalOrders = branches.fold<int>(
      0,
      (sum, branch) => sum + branch.orderCount,
    );

    return DashboardSummary(
      totalRevenue: totalRevenue,
      totalOrders: totalOrders,
      averageOrderValue: totalOrders > 0 ? totalRevenue / totalOrders : 0,
      activeBranches:
          branches.where((b) => b.status == BranchStatus.active).length,
      totalTables: 48,
      occupiedTables: 32,
      revenueGrowth: 12.5,
    );
  }

  /// Calculate date range
  DateTimeRange _calculateDateRange(
    RevenueFilter filter,
    DateTime? startDate,
    DateTime? endDate,
  ) {
    if (startDate != null && endDate != null) {
      return DateTimeRange(start: startDate, end: endDate);
    }

    final now = DateTime.now();
    switch (filter) {
      case RevenueFilter.day:
        final startOfDay = DateTime(now.year, now.month, now.day);
        return DateTimeRange(start: startOfDay, end: now);

      case RevenueFilter.week:
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        final startDate = DateTime(
          startOfWeek.year,
          startOfWeek.month,
          startOfWeek.day,
        );
        return DateTimeRange(start: startDate, end: now);

      case RevenueFilter.month:
        final startOfMonth = DateTime(now.year, now.month, 1);
        return DateTimeRange(start: startOfMonth, end: now);

      case RevenueFilter.year:
        final startOfYear = DateTime(now.year, 1, 1);
        return DateTimeRange(start: startOfYear, end: now);
    }
  }
}
