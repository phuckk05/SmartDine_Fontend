import 'package:intl/intl.dart';

enum RevenueFilter {
  day,
  week,
  month,
  year;

  String get label {
    switch (this) {
      case RevenueFilter.day:
        return 'Ngày';
      case RevenueFilter.week:
        return 'Tuần';
      case RevenueFilter.month:
        return 'Tháng';
      case RevenueFilter.year:
        return 'Năm';
    }
  }
}

/// Trạng thái chi nhánh
enum BranchStatus {
  active,
  inactive,
  maintenance;

  String get label {
    switch (this) {
      case BranchStatus.active:
        return 'Hoạt động';
      case BranchStatus.inactive:
        return 'Ngưng hoạt động';
      case BranchStatus.maintenance:
        return 'Bảo trì';
    }
  }

  static BranchStatus fromString(String status) {
    switch (status.toUpperCase()) {
      case 'ACTIVE':
        return BranchStatus.active;
      case 'INACTIVE':
        return BranchStatus.inactive;
      case 'MAINTENANCE':
        return BranchStatus.maintenance;
      default:
        return BranchStatus.active;
    }
  }
}

/// Dữ liệu dashboard tổng hợp
class DashboardData {
  final List<BranchRevenueData> branches;
  final List<RevenuePoint> revenueChart;
  final DashboardSummary summary;
  final DateTime lastUpdated;

  DashboardData({
    required this.branches,
    required this.revenueChart,
    required this.summary,
    required this.lastUpdated,
  });

  DashboardData copyWith({
    List<BranchRevenueData>? branches,
    List<RevenuePoint>? revenueChart,
    DashboardSummary? summary,
    DateTime? lastUpdated,
  }) {
    return DashboardData(
      branches: branches ?? this.branches,
      revenueChart: revenueChart ?? this.revenueChart,
      summary: summary ?? this.summary,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

/// Dữ liệu doanh thu từng chi nhánh
class BranchRevenueData {
  final String branchId;
  final String branchName;
  final String branchCode;
  final double revenue; // Triệu VNĐ
  final int orderCount;
  final double percentage;
  final double target; // Target doanh thu (triệu VNĐ)
  final bool hasData;
  final BranchStatus status;

  BranchRevenueData({
    required this.branchId,
    required this.branchName,
    required this.branchCode,
    required this.revenue,
    required this.orderCount,
    required this.percentage,
    required this.target,
    this.hasData = true,
    this.status = BranchStatus.active,
  });

  String get revenueFormatted => '${revenue.toStringAsFixed(0)}M';
  String get percentageFormatted => '${percentage.toStringAsFixed(0)}%';
  String get targetFormatted => '${target.toStringAsFixed(0)}M';
}

/// Điểm dữ liệu cho biểu đồ
class RevenuePoint {
  final DateTime date;
  final double amount;
  final String label;
  final int orderCount;

  RevenuePoint({
    required this.date,
    required this.amount,
    required this.label,
    this.orderCount = 0,
  });

  String get amountFormatted => '${amount.toStringAsFixed(1)}M';
}

/// Tổng quan dashboard
class DashboardSummary {
  final double totalRevenue;
  final int totalOrders;
  final double averageOrderValue;
  final int activeBranches;
  final int totalTables;
  final int occupiedTables;
  final double revenueGrowth;

  DashboardSummary({
    required this.totalRevenue,
    required this.totalOrders,
    required this.averageOrderValue,
    required this.activeBranches,
    this.totalTables = 0,
    this.occupiedTables = 0,
    this.revenueGrowth = 0,
  });

  String get totalRevenueFormatted {
    final formatter = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: 'đ',
      decimalDigits: 0,
    );
    return formatter.format(totalRevenue);
  }

  String get averageOrderValueFormatted {
    final formatter = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: 'đ',
      decimalDigits: 0,
    );
    return formatter.format(averageOrderValue);
  }

  String get revenueGrowthFormatted {
    final sign = revenueGrowth >= 0 ? '+' : '';
    return '$sign${revenueGrowth.toStringAsFixed(1)}%';
  }

  double get tableOccupancyRate {
    if (totalTables == 0) return 0;
    return (occupiedTables / totalTables) * 100;
  }
}

/// Thống kê real-time
class RealtimeStats {
  final int activeOrders;
  final int pendingOrders; // Đơn chờ xử lý
  final int completedToday; // Đơn hoàn thành hôm nay
  final double todayRevenue; // Doanh thu hôm nay (VNĐ)
  final DateTime lastUpdate;

  RealtimeStats({
    required this.activeOrders,
    required this.pendingOrders,
    required this.completedToday,
    required this.todayRevenue,
    required this.lastUpdate,
  });

  String get todayRevenueFormatted {
    final formatter = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: 'đ',
      decimalDigits: 0,
    );
    return formatter.format(todayRevenue);
  }
}

/// Món bán chạy
class TopItem {
  final String itemId;
  final String itemName;
  final int quantity;
  final double revenue; // VNĐ
  final String? imageUrl;
  final String categoryName;

  TopItem({
    required this.itemId,
    required this.itemName,
    required this.quantity,
    required this.revenue,
    this.imageUrl,
    this.categoryName = '',
  });

  String get revenueFormatted {
    final formatter = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: 'đ',
      decimalDigits: 0,
    );
    return formatter.format(revenue);
  }
}

/// Helper class for date range
class DateTimeRange {
  final DateTime start;
  final DateTime end;

  DateTimeRange({required this.start, required this.end});

  Duration get duration => end.difference(start);

  bool contains(DateTime date) {
    return date.isAfter(start) && date.isBefore(end);
  }
}
