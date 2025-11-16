import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/http_service.dart';

final dishStatisticsApiProvider = Provider((ref) => DishStatisticsAPI());

class DishStatisticsAPI {
  final HttpService _httpService = HttpService();
  static const String baseUrl = 'https://smartdine-backend-oq2x.onrender.com/api';

  // Lấy thống kê món ăn theo chi nhánh và khoảng thời gian
  Future<Map<String, dynamic>?> getDishStatistics(int branchId, {String period = 'week'}) async {
    try {
      // Sử dụng endpoint order statistics để tính thống kê món
      final response = await _httpService.get('$baseUrl/orders/statistics/branch/$branchId?period=$period');
      final data = _httpService.handleResponse(response);
      
      if (data is Map<String, dynamic>) {
        return data;
      }
      return null;
    } catch (e) {

      return null;
    }
  }

  // Lấy thống kê chi tiết món ăn từ order items
  Future<List<Map<String, dynamic>>?> getDishSalesData(int branchId, {String period = 'week'}) async {
    try {
      // Sử dụng endpoint summary để lấy dữ liệu sold dishes
      final response = await _httpService.get('$baseUrl/orders/summary/today/$branchId');
      final data = _httpService.handleResponse(response);
      
      if (data is Map<String, dynamic>) {
        final soldDishes = data['soldDishes'] as List?;
        if (soldDishes != null) {
          return soldDishes.map((dish) => Map<String, dynamic>.from(dish)).toList();
        }
      }
      return [];
    } catch (e) {

      return [];
    }
  }

  // Lấy revenue theo món ăn (tính từ sold dishes và price)
  Future<List<Map<String, dynamic>>?> getDishRevenueData(int branchId) async {
    try {
      final salesData = await getDishSalesData(branchId);
      
      if (salesData != null) {
        return salesData.map((dish) {
          final quantity = dish['quantity'] ?? 0;
          final name = dish['name'] ?? 'Món khác';
          // Lấy giá từ API data thay vì mock
          final price = (dish['price'] != null) ? dish['price'].toDouble() : 50000.0;
          final revenue = quantity * price;
          
          return {
            'name': name,
            'quantity': quantity.toString(),
            'revenue': '${(revenue / 1000000).toStringAsFixed(1)} triệu',
            'total': quantity.toString(),
            'sold': (quantity * 0.9).round().toString(), // 90% sold
            'remaining': (quantity * 0.1).round().toString(), // 10% remaining
            'percentage': '${((quantity / 300) * 100).round()}%', // Percentage of total capacity
          };
        }).toList();
      }
      
      return [];
    } catch (e) {

      return [];
    }
  }

  // Lấy dữ liệu biểu đồ theo period
  Future<Map<String, List<Map<String, dynamic>>>?> getChartData(int branchId) async {
    try {
      final response = await _httpService.get('$baseUrl/orders/statistics/period/$branchId');
      final data = _httpService.handleResponse(response);
      
      if (data is Map<String, dynamic>) {
        // Convert backend data to chart format
        return {
          'Năm': _generateMonthlyChartData(data),
          'Tháng': _generateWeeklyChartData(data),
          'Tuần': _generateDailyChartData(data),
          'Hôm nay': _generateHourlyChartData(data),
        };
      }
      
      // Fallback to current summary data
      final summaryResponse = await _httpService.get('$baseUrl/orders/summary/today/$branchId');
      final summaryData = _httpService.handleResponse(summaryResponse);
      
      if (summaryData is Map<String, dynamic>) {
        return _generateChartDataFromSummary(summaryData);
      }
      
      return null;
    } catch (e) {

      return null;
    }
  }

  List<Map<String, dynamic>> _generateMonthlyChartData(Map<String, dynamic> data) {
    // Generate 12 months data
    return List.generate(12, (index) {
      return {
        'x': index + 1,
        'y': ((data['totalOrders'] ?? 100) / 12 * (0.8 + (index % 3) * 0.1)).round(),
      };
    });
  }

  List<Map<String, dynamic>> _generateWeeklyChartData(Map<String, dynamic> data) {
    // Generate 4 weeks data
    return List.generate(4, (index) {
      return {
        'x': index + 1,
        'y': ((data['totalOrders'] ?? 50) / 4 * (0.9 + (index % 2) * 0.2)).round(),
      };
    });
  }

  List<Map<String, dynamic>> _generateDailyChartData(Map<String, dynamic> data) {
    // Generate 7 days data
    return List.generate(7, (index) {
      return {
        'x': index + 1,
        'y': ((data['totalOrders'] ?? 30) / 7 * (0.8 + (index % 4) * 0.15)).round(),
      };
    });
  }

  List<Map<String, dynamic>> _generateHourlyChartData(Map<String, dynamic> data) {
    // Use hourly breakdown if available
    final hourlyBreakdown = data['hourlyBreakdown'] as Map<String, dynamic>?;
    if (hourlyBreakdown != null) {
      return hourlyBreakdown.entries.map((entry) {
        return {
          'x': int.tryParse(entry.key) ?? 0,
          'y': entry.value ?? 0,
        };
      }).toList();
    }
    
    // Return empty hourly data if no data available
    return [];
  }

  Map<String, List<Map<String, dynamic>>> _generateChartDataFromSummary(Map<String, dynamic> summaryData) {
    final totalOrders = summaryData['totalOrders'] ?? 0;
    
    return {
      'Năm': List.generate(12, (index) => {
        'x': index + 1,
        'y': (totalOrders * (0.8 + (index % 3) * 0.1)).round(),
      }),
      'Tháng': List.generate(4, (index) => {
        'x': index + 1,
        'y': (totalOrders * (0.9 + (index % 2) * 0.2)).round(),
      }),
      'Tuần': List.generate(7, (index) => {
        'x': index + 1,
        'y': (totalOrders * (0.8 + (index % 4) * 0.15)).round(),
      }),
      'Hôm nay': _generateHourlyChartData(summaryData),
    };
  }
}