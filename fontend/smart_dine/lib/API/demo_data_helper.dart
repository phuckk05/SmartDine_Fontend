import 'dart:math';

/// Helper class to generate demo data for development and testing
class DemoDataHelper {
  static final Random _random = Random();
  
  /// Generate mock daily summary data for today activities
  static Map<String, dynamic> generateTodayOrderSummary(int branchId) {
    final totalOrders = _random.nextInt(20) + 5; // 5-25 orders
    final completedOrders = (totalOrders * 0.6).round(); // 60% completed
    final servingOrders = (totalOrders * 0.3).round(); // 30% serving
    final cancelledOrders = totalOrders - completedOrders - servingOrders; // Rest cancelled
    
    return {
      'branchId': branchId,
      'date': DateTime.now().toIso8601String().split('T')[0],
      'totalOrders': totalOrders,
      'totalOrdersToday': totalOrders,
      'completedOrders': completedOrders,
      'completedOrdersToday': completedOrders,
      'pendingOrders': servingOrders,
      'pendingOrdersToday': servingOrders,
      'cancelledOrders': cancelledOrders,
      'completionRate': completedOrders / totalOrders,
      'statusBreakdown': {
        'completed': completedOrders,
        'serving': servingOrders,
        'cancelled': cancelledOrders,
        'pending': 0,
      },
      'hourlyBreakdown': _generateHourlyBreakdown(totalOrders),
      'soldDishes': _generateSoldDishes(),
      'extraDishes': [],
      'cancelledDishes': [],
      'extraSupplies': [],
      'extraDocuments': [],
      // Add yesterday's data for comparison
      'totalOrdersYesterday': (totalOrders * 0.85).round(),
      'pendingOrdersYesterday': (servingOrders * 0.9).round(),
    };
  }
  
  /// Generate mock branch statistics
  static Map<String, dynamic> generateBranchStatistics(int branchId, {String? date, String period = 'day'}) {
    final today = date ?? DateTime.now().toIso8601String().split('T')[0];
    // Adjust order count based on period
    final baseOrders = period == 'month' ? _random.nextInt(300) + 100 : _random.nextInt(15) + 3;
    final totalOrders = baseOrders;
    final completedOrders = (totalOrders * 0.7).round();
    
    return {
      'branchId': branchId,
      'date': today,
      'totalOrdersToday': totalOrders,
      'completedOrdersToday': completedOrders,
      'pendingOrdersToday': totalOrders - completedOrders,
      'completionRate': completedOrders / totalOrders,
      // Add comparison data
      'totalOrdersYesterday': (totalOrders * 0.9).round(),
      'pendingOrdersYesterday': ((totalOrders - completedOrders) * 0.8).round(),
    };
  }
  
  static Map<String, int> _generateHourlyBreakdown(int totalOrders) {
    final breakdown = <String, int>{};
    var remainingOrders = totalOrders;
    
    // Distribute orders across peak hours (11-14, 18-21)
    for (int hour = 11; hour <= 21 && remainingOrders > 0; hour++) {
      if (hour <= 14 || hour >= 18) {
        final ordersThisHour = _random.nextInt(remainingOrders + 1);
        breakdown[hour.toString()] = ordersThisHour;
        remainingOrders -= ordersThisHour;
      }
    }
    
    return breakdown;
  }
  
  static List<Map<String, dynamic>> _generateSoldDishes() {
    final dishes = [
      {'name': 'Phở bò', 'quantity': _random.nextInt(10) + 1},
      {'name': 'Cơm tấm', 'quantity': _random.nextInt(8) + 1},
      {'name': 'Bún chả', 'quantity': _random.nextInt(6) + 1},
      {'name': 'Bánh mì', 'quantity': _random.nextInt(12) + 1},
      {'name': 'Cà phê sữa', 'quantity': _random.nextInt(15) + 1},
    ];
    
    return dishes.take(_random.nextInt(3) + 2).toList();
  }
  
  /// Generate realistic revenue based on order count
  static double calculateRevenueFromOrders(int completedOrders) {
    final avgOrderValue = 45000 + _random.nextInt(30000); // 45k-75k VND
    return completedOrders * avgOrderValue.toDouble();
  }
  
  /// Generate period-specific statistics
  static Map<String, dynamic> generatePeriodStatistics(String period, int branchId) {
    switch (period.toLowerCase()) {
      case 'tuần này':
      case 'week':
        return {
          'totalOrders': _random.nextInt(50) + 20,
          'revenue': (_random.nextInt(2000000) + 1000000).toDouble(),
          'period': 'week'
        };
      case 'tháng này': 
      case 'month':
        return {
          'totalOrders': _random.nextInt(300) + 100,
          'revenue': (_random.nextInt(10000000) + 5000000).toDouble(),
          'period': 'month'
        };
      case 'quý này':
      case 'quarter':
        return {
          'totalOrders': _random.nextInt(900) + 300,
          'revenue': (_random.nextInt(30000000) + 15000000).toDouble(),
          'period': 'quarter'
        };
      default:
        return generateTodayOrderSummary(branchId);
    }
  }
}