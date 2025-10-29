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
      
      print('Fetching branch statistics for branch $branchId from: $url');
      
      final response = await _httpService.get(url);
      final data = _httpService.handleResponse(response);
      
      print('Successfully fetched branch statistics: $data');
      return data is Map<String, dynamic> ? data : null;
    } catch (e) {
      print('Error getting branch statistics: $e');
      
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
            'revenue': (count ?? 0) * 50000, // Mock revenue calculation
          });
        });
        
        return trends;
      }
      return [];
    } catch (e) {
      print('Error getting revenue trends: $e');
      return [];
    }
  }

  // Lấy top món bán chạy - Mock data vì chưa có API
  Future<List<Map<String, dynamic>>?> getTopDishes(int branchId, {int limit = 5}) async {
    try {
      // Tạm thời trả về mock data
      await Future.delayed(Duration(milliseconds: 500)); // Simulate API call
      
      return [
        {'name': 'Phở Bò', 'orders': 25, 'revenue': 1250000},
        {'name': 'Bún Chả', 'orders': 18, 'revenue': 900000},
        {'name': 'Cơm Tấm', 'orders': 15, 'revenue': 750000},
        {'name': 'Bánh Mì', 'orders': 12, 'revenue': 360000},
        {'name': 'Chả Cá', 'orders': 8, 'revenue': 640000},
      ].take(limit).toList();
    } catch (e) {
      print('Error getting top dishes: $e');
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
      print('Error getting employee performance: $e');
      return [];
    }
  }

  // Lấy thông tin chi nhánh theo ID - Mock data vì chưa có API
  Future<Map<String, dynamic>?> getBranchById(int branchId) async {
    try {
      // Tạm thời trả về mock data
      await Future.delayed(Duration(milliseconds: 300)); // Simulate API call
      
      return {
        'id': branchId,
        'name': 'Chi nhánh $branchId',
        'address': '123 Đường ABC, Quận XYZ, TP.HCM',
        'phone': '0901234567',
        'status': 'active',
        'manager': 'Nguyễn Văn A',
      };
    } catch (e) {
      print('Error getting branch by id: $e');
      return null;
    }
  }
}