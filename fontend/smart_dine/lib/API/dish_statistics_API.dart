import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/http_service.dart';

final dishStatisticsApiProvider = Provider((ref) => DishStatisticsAPI());

class DishStatisticsAPI {
  final HttpService _httpService = HttpService();
  static const String baseUrl = 'https://smartdine-backend-oq2x.onrender.com/api';

  // Lấy thống kê món ăn theo chi nhánh và khoảng thời gian
  Future<Map<String, dynamic>?> getDishStatistics(int branchId, {String period = 'week'}) async {
    try {
      // Sử dụng endpoint dashboard dish statistics với period filtering
      final response = await _httpService.get('$baseUrl/dashboard/dish-statistics/branch/$branchId?period=$period');
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
      // Sử dụng endpoint dashboard/dish-statistics với period parameter
      final response = await _httpService.get('$baseUrl/dashboard/dish-statistics/branch/$branchId?period=$period');
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
  Future<List<Map<String, dynamic>>?> getDishRevenueData(int branchId, {String period = 'week'}) async {
    try {
      final salesData = await getDishSalesData(branchId, period: period);

      if (salesData != null) {
        return salesData.map((dish) {
          final quantity = dish['quantity'] ?? 0;
          final name = dish['name'] ?? 'Món khác';
          // Use actual price from backend or default, but don't hardcode
          final price = (dish['price'] != null) ? dish['price'].toDouble() : 0.0;
          final revenue = quantity * price;

          return {
            'name': name,
            'quantity': quantity,
            'revenue': revenue, // Return raw revenue value
            'price': price,
          };
        }).toList();
      }

      return [];
    } catch (e) {
      return [];
    }
  }

  // Lấy dữ liệu biểu đồ theo period
  Future<Map<String, List<Map<String, dynamic>>>?> getChartData(int branchId, {String period = 'week'}) async {
    try {
      // Try to get real data from backend first
      final response = await _httpService.get('$baseUrl/orders/statistics/period/$branchId?period=$period');
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

      // Return empty data if no backend data available
      return {
        'Năm': [],
        'Tháng': [],
        'Tuần': [],
        'Hôm nay': [],
      };
    } catch (e) {
      // Return empty data on error
      return {
        'Năm': [],
        'Tháng': [],
        'Tuần': [],
        'Hôm nay': [],
      };
    }
  }

  List<Map<String, dynamic>> _generateMonthlyChartData(Map<String, dynamic> data) {
    // Return empty data - no real monthly data available
    return [];
  }

  List<Map<String, dynamic>> _generateWeeklyChartData(Map<String, dynamic> data) {
    // Return empty data - no real weekly data available
    return [];
  }

  List<Map<String, dynamic>> _generateDailyChartData(Map<String, dynamic> data) {
    // Return empty data - no real daily data available
    return [];
  }

  List<Map<String, dynamic>> _generateHourlyChartData(Map<String, dynamic> data) {
    // Use hourly breakdown if available from backend
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
    // Return empty data - no real chart data available from summary
    return {
      'Năm': [],
      'Tháng': [],
      'Tuần': [],
      'Hôm nay': _generateHourlyChartData(summaryData),
    };
  }
}