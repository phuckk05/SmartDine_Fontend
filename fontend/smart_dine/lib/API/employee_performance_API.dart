import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/http_service.dart';
import 'payment_statistics_API.dart';

final employeePerformanceApiProvider = Provider((ref) => EmployeePerformanceAPI());

class EmployeePerformanceAPI {
  final HttpService _httpService = HttpService();
  static const String baseUrl = 'https://smartdine-backend-oq2x.onrender.com/api';

  // Lấy danh sách nhân viên theo chi nhánh
  Future<List<Map<String, dynamic>>?> getEmployeesByBranch(int branchId) async {
    try {
      final response = await _httpService.get('$baseUrl/employees/branch/$branchId');
      final data = _httpService.handleResponse(response);
      
      if (data is List) {
        return data.map((employee) => Map<String, dynamic>.from(employee)).toList();
      }
      return [];
    } catch (e) {

      return [];
    }
  }

  // Lấy thống kê hiệu suất nhân viên
  Future<List<Map<String, dynamic>>?> getEmployeePerformance(int branchId, {String period = 'week'}) async {
    try {
      print('EmployeePerformanceAPI: Fetching performance for branch $branchId');
      final response = await _httpService.get('$baseUrl/employees/performance/branch/$branchId');
      final data = _httpService.handleResponse(response);
      
      print('EmployeePerformanceAPI: Raw API response: $data');

      if (data is List) {
        final mappedData = data.map((employee) {
          final perf = Map<String, dynamic>.from(employee);
          // Map đơn giản từ backend
          return {
            'name': perf['fullName'] ?? perf['name'] ?? 'Unknown',
            'role': perf['role'] ?? perf['roleName'] ?? 'Unknown',
            'roleId': perf['roleId'] ?? perf['role'],
            'tablesServed': perf['tablesServed'] ?? perf['tablesServed'] ?? 0,
            'ordersCompleted': perf['ordersCompleted'] ?? perf['ordersHandled'] ?? 0,
            'totalServed': perf['totalServed'] ?? perf['ordersHandled'] ?? 0,
            'tips': perf['tips'] ?? perf['revenue'] ?? 0.0,
            'rating': perf['rating'] ?? perf['performanceRating'] ?? 0.0,
          };
        }).toList();
        
        print('EmployeePerformanceAPI: Mapped data: $mappedData');
        return mappedData;
      }
      print('EmployeePerformanceAPI: Data is not a list, returning empty');
      return [];
    } catch (e) {
      print('EmployeePerformanceAPI: Error fetching performance: $e');
      return [];
    }
  }
  // Lấy dữ liệu số đơn hàng theo giờ từ thống kê đơn hàng
  Future<List<Map<String, dynamic>>?> getTripsData(int branchId, {String period = 'week'}) async {
    try {
      // Get order statistics to generate hourly breakdown
      final response = await _httpService.get('$baseUrl/orders/statistics/branch/$branchId');
      final data = _httpService.handleResponse(response);

      if (data is Map<String, dynamic> && data['hourlyBreakdown'] != null) {
        final hourlyData = data['hourlyBreakdown'] as Map<String, dynamic>;
        // Convert to expected format with hourIndex and revenue
        // Group hours into 6 time slots: 6-9, 9-12, 12-15, 15-18, 18-21, 21-24
        int slot1 = 0, slot2 = 0, slot3 = 0, slot4 = 0, slot5 = 0, slot6 = 0;
        hourlyData.forEach((hour, count) {
          int h = int.parse(hour.toString());
          if (h >= 6 && h < 9) slot1 += (count as int);
          else if (h >= 9 && h < 12) slot2 += (count as int);
          else if (h >= 12 && h < 15) slot3 += (count as int);
          else if (h >= 15 && h < 18) slot4 += (count as int);
          else if (h >= 18 && h < 21) slot5 += (count as int);
          else if (h >= 21 || h < 6) slot6 += (count as int); // 21-24 and 0-6
        });

        return [
          {'hour': '6-9h', 'count': slot1},
          {'hour': '9-12h', 'count': slot2},
          {'hour': '12-15h', 'count': slot3},
          {'hour': '15-18h', 'count': slot4},
          {'hour': '18-21h', 'count': slot5},
          {'hour': '21-24h', 'count': slot6},
        ];
      }

      // Fallback empty data
      return [
        {'hour': '6-9h', 'count': 0},
        {'hour': '9-12h', 'count': 0},
        {'hour': '12-15h', 'count': 0},
        {'hour': '15-18h', 'count': 0},
        {'hour': '18-21h', 'count': 0},
        {'hour': '21-24h', 'count': 0},
      ];
    } catch (e) {
      return [
        {'hour': '6-9h', 'count': 0},
        {'hour': '9-12h', 'count': 0},
        {'hour': '12-15h', 'count': 0},
        {'hour': '15-18h', 'count': 0},
        {'hour': '18-21h', 'count': 0},
        {'hour': '21-24h', 'count': 0},
      ];
    }
  }

  // Lấy thống kê tổng quan hiệu suất chi nhánh
  Future<Map<String, dynamic>?> getBranchPerformanceOverview(int branchId) async {
    try {
      final response = await _httpService.get('$baseUrl/orders/statistics/branch/$branchId');
      final data = _httpService.handleResponse(response);

      if (data is Map<String, dynamic>) {
        // Get revenue data from payment API
        final paymentApi = PaymentStatisticsAPI();
        final today = DateTime.now().toIso8601String().split('T')[0];
        final revenue = await paymentApi.getPotentialRevenueByDay(
          branchId: branchId,
          date: today,
          includeServing: true,
        );

        return {
          'totalOrders': data['totalOrdersToday'] ?? 0,
          'totalRevenue': ((revenue ?? 0.0) * 1000).round(), // Convert to VND
          'totalCustomers': data['totalCustomersToday'] ?? 0, // Số khách hàng thực tế
          'completionRate': data['completionRate'] ?? 0.0, // Tỷ lệ hoàn thành
          'totalTables': data['totalTablesServed'] ?? 0, // Số bàn phục vụ
          'lastUpdated': DateTime.now().toIso8601String(),
        };
      }

      return null;
    } catch (e) {
      return null;
    }
  }
}