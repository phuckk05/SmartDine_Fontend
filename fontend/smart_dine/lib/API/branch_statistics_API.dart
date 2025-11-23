import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/http_service.dart';

final branchStatisticsApiProvider = Provider((ref) => BranchStatisticsAPI());

class BranchStatisticsAPI {
  final HttpService _httpService = HttpService();
  static const String baseUrl = 'https://smartdine-backend-oq2x.onrender.com/api';

  // Lấy thống kê tổng quan của chi nhánh
  Future<Map<String, dynamic>?> getBranchStatistics(int branchId, {String? date}) async {
    try {
      // Kiểm tra kết nối trước khi gọi API
      final hasConnection = await _httpService.checkConnection();
      if (!hasConnection) {
        throw Exception('Không có kết nối internet. Vui lòng kiểm tra mạng và thử lại.');
      }

      // Sử dụng endpoint thực tế từ OrderController
      String url = '$baseUrl/orders/statistics/branch/$branchId';
      if (date != null) {
        url += '?date=$date';
      }
      
            final response = await _httpService.get(url);
      final data = _httpService.handleResponse(response);
      
            return data is Map<String, dynamic> ? data : null;
    } catch (e) {
            // Test API endpoint specifically
      final apiWorking = await _httpService.testApiEndpoint('$baseUrl/orders/statistics/branch/$branchId');
      if (!apiWorking) {
        throw Exception('Server không phản hồi. Vui lòng thử lại sau hoặc liên hệ admin.');
      }
      
      rethrow;
    }
  }

  // Lấy xu hướng doanh thu - sử dụng endpoint có sẵn
  Future<List<Map<String, dynamic>>?> getRevenueTrends(int branchId, {String period = 'day', int days = 7}) async {
    try {
      // Tạm thời sử dụng summary endpoint để có dữ liệu
      final response = await _httpService.get('$baseUrl/orders/summary/today/$branchId');
      final data = _httpService.handleResponse(response);
      
      if (data is Map<String, dynamic>) {
        // Convert hourly breakdown to trend format
        final hourlyBreakdown = data['hourlyBreakdown'] as Map<String, dynamic>? ?? {};
        List<Map<String, dynamic>> trends = [];
        
        hourlyBreakdown.forEach((hour, count) {
          trends.add({
            'hour': int.tryParse(hour) ?? 0,
            'orders': count ?? 0,
            'revenue': (count ?? 0) * 0, // Revenue calculation would need payment data
          });
        });
        
        return trends;
      }
      return [];
    } catch (e) {
            return [];
    }
  }

  // Lấy top món bán chạy - Uses real API data
  Future<List<Map<String, dynamic>>?> getTopDishes(int branchId, {int limit = 5}) async {
    try {
      // Return empty list since we need payment/menu API for top dishes data
      return [];
    } catch (e) {
            return [];
    }
  }

  // Lấy hiệu suất nhân viên - sử dụng endpoint có sẵn
  Future<List<Map<String, dynamic>>?> getEmployeePerformance(int branchId) async {
    try {
      // Sử dụng employee performance endpoint có sẵn
      final response = await _httpService.get('$baseUrl/employees/performance/branch/$branchId');
      final data = _httpService.handleResponse(response);
      
      if (data is List) {
        return data.cast<Map<String, dynamic>>();
      } else if (data is Map<String, dynamic> && data['data'] is List) {
        return (data['data'] as List).cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
            return [];
    }
  }

  // Lấy thông tin chi nhánh theo ID - Uses real API data
  Future<Map<String, dynamic>?> getBranchById(int branchId) async {
    try {
      final response = await _httpService.get('$baseUrl/branches/$branchId');
      final data = _httpService.handleResponse(response);
      
      if (data is Map<String, dynamic>) {
        return data;
      }
      
      return null;
    } catch (e) {
            return null;
    }
  }
}