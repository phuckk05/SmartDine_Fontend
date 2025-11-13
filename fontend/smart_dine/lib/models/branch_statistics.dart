class BranchStatistics {
  final int branchId;
  final String branchName;
  final DateTime date;
  final double todayRevenue;
  final int todayOrders;
  final int todayCustomers;
  final double averageOrderValue;
  final int tableOccupancy;
  final int totalTables;
  final List<RevenueTrend> revenueTrends;
  final List<TopDish> topDishes;
  final List<EmployeePerformance> employeePerformance;

  BranchStatistics({
    required this.branchId,
    required this.branchName,
    required this.date,
    required this.todayRevenue,
    required this.todayOrders,
    required this.todayCustomers,
    required this.averageOrderValue,
    required this.tableOccupancy,
    required this.totalTables,
    required this.revenueTrends,
    required this.topDishes,
    required this.employeePerformance,
  });

  factory BranchStatistics.fromJson(Map<String, dynamic> json) {
    return BranchStatistics(
      branchId: json['branchId'] ?? 0,
      branchName: json['branchName'] ?? '',
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      todayRevenue: (json['totalRevenue'] ?? 0).toDouble(),
      todayOrders: json['totalOrders'] ?? 0,
      todayCustomers: json['totalCustomers'] ?? 0,
      averageOrderValue: (json['averageOrderValue'] ?? 0).toDouble(),
      tableOccupancy: json['tableOccupancy'] ?? 0,
      totalTables: json['totalTables'] ?? 0,
      revenueTrends: (json['revenueTrends'] as List<dynamic>?)
          ?.map((item) => RevenueTrend.fromJson(item))
          .toList() ?? [],
      topDishes: (json['topDishes'] as List<dynamic>?)
          ?.map((item) => TopDish.fromJson(item))
          .toList() ?? [],
      employeePerformance: (json['employeePerformance'] as List<dynamic>?)
          ?.map((item) => EmployeePerformance.fromJson(item))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'branchId': branchId,
      'branchName': branchName,
      'date': date.toIso8601String(),
      'totalRevenue': todayRevenue,
      'totalOrders': todayOrders,
      'totalCustomers': todayCustomers,
      'averageOrderValue': averageOrderValue,
      'tableOccupancy': tableOccupancy,
      'totalTables': totalTables,
      'revenueTrends': revenueTrends.map((item) => item.toJson()).toList(),
      'topDishes': topDishes.map((item) => item.toJson()).toList(),
      'employeePerformance': employeePerformance.map((item) => item.toJson()).toList(),
    };
  }
}

class RevenueTrend {
  final String date;
  final double revenue;

  RevenueTrend({
    required this.date,
    required this.revenue,
  });

  factory RevenueTrend.fromJson(Map<String, dynamic> json) {
    return RevenueTrend(
      date: json['date'] ?? '',
      revenue: (json['revenue'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'revenue': revenue,
    };
  }
}

class TopDish {
  final String dishName;
  final int quantitySold;
  final double revenue;

  TopDish({
    required this.dishName,
    required this.quantitySold,
    required this.revenue,
  });

  factory TopDish.fromJson(Map<String, dynamic> json) {
    return TopDish(
      dishName: json['dishName'] ?? '',
      quantitySold: json['quantitySold'] ?? 0,
      revenue: (json['revenue'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dishName': dishName,
      'quantitySold': quantitySold,
      'revenue': revenue,
    };
  }
}

class EmployeePerformance {
  final String employeeName;
  final int ordersHandled;
  final double performanceScore;

  EmployeePerformance({
    required this.employeeName,
    required this.ordersHandled,
    required this.performanceScore,
  });

  factory EmployeePerformance.fromJson(Map<String, dynamic> json) {
    return EmployeePerformance(
      employeeName: json['employeeName'] ?? '',
      ordersHandled: json['ordersHandled'] ?? 0,
      performanceScore: (json['performanceScore'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'employeeName': employeeName,
      'ordersHandled': ordersHandled,
      'performanceScore': performanceScore,
    };
  }
}