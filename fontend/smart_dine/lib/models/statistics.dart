class BranchMetrics {
  final String period;
  final String dateRange;
  final int totalRevenue;
  final int totalOrders;
  final int avgOrderValue;
  final int newCustomers;
  final double customerSatisfaction;
  final GrowthRates growthRates;
  final bool isEmpty; // Flag đánh dấu empty state

  BranchMetrics({
    required this.period,
    required this.dateRange,
    required this.totalRevenue,
    required this.totalOrders,
    required this.avgOrderValue,
    required this.newCustomers,
    required this.customerSatisfaction,
    required this.growthRates,
    this.isEmpty = false, // Mặc định không empty
  });

  factory BranchMetrics.fromJson(Map<String, dynamic> json) {
    // Handle both old format and new API response format
    if (json.containsKey('totalOrdersToday')) {
      // New API format from OrderController
      return BranchMetrics(
        period: 'today',
        dateRange: json['date'] ?? '',
        totalRevenue: 0, // API chưa có revenue data
        totalOrders: json['totalOrdersToday'] ?? 0,
        avgOrderValue: 0, // Sẽ tính sau
        newCustomers: json['pendingOrdersToday'] ?? 0, // Tạm dùng pending orders
        customerSatisfaction: json['completionRate'] ?? 0.0,
        growthRates: GrowthRates.fromJson({}), // Empty for now
        isEmpty: false,
      );
    } else {
      // Old format
      return BranchMetrics(
        period: json['period'] ?? '',
        dateRange: json['date_range'] ?? '',
        totalRevenue: json['total_revenue'] ?? 0,
        totalOrders: json['total_orders'] ?? 0,
        avgOrderValue: json['avg_order_value'] ?? 0,
        newCustomers: json['new_customers'] ?? 0,
        customerSatisfaction: (json['customer_satisfaction'] ?? 0.0).toDouble(),
        growthRates: GrowthRates.fromJson(json['growth_rates'] ?? {}),
        isEmpty: false,
      );
    }
  }

  factory BranchMetrics.fromMap(Map<String, dynamic> map) => BranchMetrics.fromJson(map);

  Map<String, dynamic> toJson() {
    return {
      'period': period,
      'date_range': dateRange,
      'total_revenue': totalRevenue,
      'total_orders': totalOrders,
      'avg_order_value': avgOrderValue,
      'new_customers': newCustomers,
      'customer_satisfaction': customerSatisfaction,
      'growth_rates': growthRates.toJson(),
      'is_empty': isEmpty,
    };
  }
}

class GrowthRates {
  final double revenue;
  final double orders;
  final double avgOrderValue;
  final double newCustomers;
  final double satisfaction;

  GrowthRates({
    required this.revenue,
    required this.orders,
    required this.avgOrderValue,
    required this.newCustomers,
    required this.satisfaction,
  });

  factory GrowthRates.fromJson(Map<String, dynamic> json) {
    return GrowthRates(
      revenue: (json['revenue'] ?? 0.0).toDouble(),
      orders: (json['orders'] ?? 0.0).toDouble(),
      avgOrderValue: (json['avg_order_value'] ?? 0.0).toDouble(),
      newCustomers: (json['new_customers'] ?? 0.0).toDouble(),
      satisfaction: (json['satisfaction'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'revenue': revenue,
      'orders': orders,
      'avg_order_value': avgOrderValue,
      'new_customers': newCustomers,
      'satisfaction': satisfaction,
    };
  }
}

class RevenueTrend {
  final String period;
  final int revenue;
  final int orders;

  RevenueTrend({
    required this.period,
    required this.revenue,
    required this.orders,
  });

  factory RevenueTrend.fromJson(Map<String, dynamic> json) {
    return RevenueTrend(
      period: json['day'] ?? json['period'] ?? '',
      revenue: json['revenue'] ?? 0,
      orders: json['orders'] ?? 0,
    );
  }

  factory RevenueTrend.fromMap(Map<String, dynamic> map) => RevenueTrend.fromJson(map);

  Map<String, dynamic> toJson() {
    return {
      'period': period,
      'revenue': revenue,
      'orders': orders,
    };
  }
}

class TopDish {
  final String id;
  final String name;
  final String category;
  final int ordersCount;
  final int totalRevenue;
  final int profit;
  final int profitMargin;
  final double growthRate;
  final int rank;

  TopDish({
    required this.id,
    required this.name,
    required this.category,
    required this.ordersCount,
    required this.totalRevenue,
    required this.profit,
    required this.profitMargin,
    required this.growthRate,
    required this.rank,
  });

  factory TopDish.fromJson(Map<String, dynamic> json) {
    return TopDish(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      ordersCount: json['orders_count'] ?? 0,
      totalRevenue: json['total_revenue'] ?? 0,
      profit: json['profit'] ?? 0,
      profitMargin: json['profit_margin'] ?? 0,
      growthRate: (json['growth_rate'] ?? 0.0).toDouble(),
      rank: json['rank'] ?? 0,
    );
  }

  factory TopDish.fromMap(Map<String, dynamic> map) => TopDish.fromJson(map);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'orders_count': ordersCount,
      'total_revenue': totalRevenue,
      'profit': profit,
      'profit_margin': profitMargin,
      'growth_rate': growthRate,
      'rank': rank,
    };
  }
}

class EmployeePerformance {
  final String id;
  final String name;
  final String position;
  final int ordersServed;
  final int totalRevenue;
  final double rating;
  final int efficiency;
  final int bonus;

  EmployeePerformance({
    required this.id,
    required this.name,
    required this.position,
    required this.ordersServed,
    required this.totalRevenue,
    required this.rating,
    required this.efficiency,
    required this.bonus,
  });

  factory EmployeePerformance.fromJson(Map<String, dynamic> json) {
    return EmployeePerformance(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      position: json['position'] ?? '',
      ordersServed: json['orders_served'] ?? 0,
      totalRevenue: json['total_revenue'] ?? 0,
      rating: (json['rating'] ?? 0.0).toDouble(),
      efficiency: json['efficiency'] ?? 0,
      bonus: json['bonus'] ?? 0,
    );
  }

  factory EmployeePerformance.fromMap(Map<String, dynamic> map) => EmployeePerformance.fromJson(map);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'position': position,
      'orders_served': ordersServed,
      'total_revenue': totalRevenue,
      'rating': rating,
      'efficiency': efficiency,
      'bonus': bonus,
    };
  }
}

class PeakHourData {
  final String timeSlot;
  final int orders;
  final String level;

  PeakHourData({
    required this.timeSlot,
    required this.orders,
    required this.level,
  });

  factory PeakHourData.fromJson(Map<String, dynamic> json) {
    return PeakHourData(
      timeSlot: json['time_slot'] ?? '',
      orders: json['orders'] ?? 0,
      level: json['level'] ?? 'normal',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'time_slot': timeSlot,
      'orders': orders,
      'level': level,
    };
  }
}

class CustomerSatisfactionData {
  final String level;
  final int percentage;
  final int count;
  final String color;

  CustomerSatisfactionData({
    required this.level,
    required this.percentage,
    required this.count,
    required this.color,
  });

  factory CustomerSatisfactionData.fromJson(Map<String, dynamic> json) {
    return CustomerSatisfactionData(
      level: json['level'] ?? '',
      percentage: json['percentage'] ?? 0,
      count: json['count'] ?? 0,
      color: json['color'] ?? '#000000',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'level': level,
      'percentage': percentage,
      'count': count,
      'color': color,
    };
  }
}

class CustomerSatisfaction {
  final List<CustomerSatisfactionData> ratings;
  final double averageRating;
  final int totalReviews;
  final double growthRate;

  CustomerSatisfaction({
    required this.ratings,
    required this.averageRating,
    required this.totalReviews,
    required this.growthRate,
  });

  factory CustomerSatisfaction.fromJson(Map<String, dynamic> json) {
    return CustomerSatisfaction(
      ratings: (json['ratings'] as List<dynamic>?)
          ?.map((item) => CustomerSatisfactionData.fromJson(item))
          .toList() ?? [],
      averageRating: (json['average_rating'] ?? 0.0).toDouble(),
      totalReviews: json['total_reviews'] ?? 0,
      growthRate: (json['growth_rate'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ratings': ratings.map((item) => item.toJson()).toList(),
      'average_rating': averageRating,
      'total_reviews': totalReviews,
      'growth_rate': growthRate,
    };
  }
}