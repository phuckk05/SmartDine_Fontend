import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/http_service.dart';

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
      final employees = await getEmployeesByBranch(branchId);
      
      if (employees != null && employees.isNotEmpty) {
        // Calculate performance metrics for each employee based on orders
        final performanceData = <Map<String, dynamic>>[];
        
        for (int i = 0; i < employees.length && i < 10; i++) {
          final employee = employees[i];
          final name = employee['fullName'] ?? employee['username'] ?? 'Nhân viên ${i + 1}';
          
          // Mock performance data based on employee info
          // In real implementation, this would come from order/service data
          final basePerformance = 20 + (i * 3) + (name.hashCode % 10);
          final variance = (name.hashCode % 5);
          
          performanceData.add({
            'name': name,
            'totalServed': '${basePerformance + variance}k',
            'tips': '${2 + (i % 3)}k',
            'rating': '${6 + (i % 3)}k',
            'employeeId': employee['id'],
            'rawTotalServed': basePerformance + variance,
            'rawTips': 2 + (i % 3),
            'rawRating': 6 + (i % 3),
          });
        }
        
        // Sort by performance (total served)
        performanceData.sort((a, b) => 
          (b['rawTotalServed'] as int).compareTo(a['rawTotalServed'] as int));
        
        return performanceData;
      }
      
      // Return empty list if no employees found
      return [];
    } catch (e) {

      return [];
    }
  }
  // Lấy dữ liệu trips thức (service trips)
  Future<List<Map<String, dynamic>>?> getTripsData(int branchId, {String period = 'week'}) async {
    try {
      // In real implementation, this would come from a trips/service tracking API
      // For now, generate based on order data
      final response = await _httpService.get('$baseUrl/orders/summary/today/$branchId');
      final data = _httpService.handleResponse(response);
      
      if (data is Map<String, dynamic>) {
        final hourlyBreakdown = data['hourlyBreakdown'] as Map<String, dynamic>?;
        
        if (hourlyBreakdown != null) {
          // Convert hourly order data to trips data
          return hourlyBreakdown.entries.take(7).map((entry) {
            final hour = int.tryParse(entry.key) ?? 0;
            final orders = entry.value ?? 0;
            return {
              'period': 'H$hour',
              'trips': (orders * 2).toInt(), // Assume 2 trips per order
              'value': (orders * 2).toDouble(),
            };
          }).toList();
        }
      }
      
      // Return empty list if no trips data
      return [];
    } catch (e) {

      return [];
    }
  }

  // Lấy thống kê tổng quan hiệu suất chi nhánh
  Future<Map<String, dynamic>?> getBranchPerformanceOverview(int branchId) async {
    try {
      final response = await _httpService.get('$baseUrl/orders/statistics/branch/$branchId');
      final data = _httpService.handleResponse(response);
      
      if (data is Map<String, dynamic>) {
        return {
          'totalOrders': data['totalOrdersToday'] ?? 0,
          'totalRevenue': '165 triệu', // This could come from payment API
          'totalCustomers': data['pendingOrdersToday'] ?? 0,
          'averageRating': '4.8★',
          'lastUpdated': DateTime.now().toIso8601String(),
        };
      }
      
      return null;
    } catch (e) {

      return null;
    }
  }
}