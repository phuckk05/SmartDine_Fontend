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
      final response = await _httpService.get('$baseUrl/employees/performance/branch/$branchId');
      final data = _httpService.handleResponse(response);

      if (data is List) {
        return data.map((employee) {
          final perf = Map<String, dynamic>.from(employee);
          // Return raw backend data without static transformations
          return {
            'employeeId': perf['employeeId'],
            'fullName': perf['fullName'] ?? 'Unknown',
            'email': perf['email'] ?? '',
            'role': perf['role'] ?? '',
            'ordersHandled': perf['ordersHandled'] ?? 0,
            'revenue': perf['revenue'] ?? 0.0,
            'rating': perf['rating'] ?? 0.0,
            'assignedAt': perf['assignedAt'],
          };
        }).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
  // Lấy dữ liệu trips thức (service trips)
  Future<List<Map<String, dynamic>>?> getTripsData(int branchId, {String period = 'week'}) async {
    try {
      // TODO: Implement real trips/service tracking API
      // For now, return empty list since we don't have backend endpoint
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
          'totalCustomers': data['pendingOrdersToday'] ?? 0,
          'averageRating': data['completionRate'] ?? 0.0, // Use completion rate as rating proxy
          'lastUpdated': DateTime.now().toIso8601String(),
        };
      }

      return null;
    } catch (e) {
      return null;
    }
  }
}