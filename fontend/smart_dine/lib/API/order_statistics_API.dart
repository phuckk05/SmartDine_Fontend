import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/http_service.dart';

final orderStatisticsApiProvider = Provider((ref) => OrderStatisticsAPI());

class OrderStatisticsAPI {
  final HttpService _httpService = HttpService();
  static const String baseUrl = 'https://smartdine-backend-oq2x.onrender.com/api';
  // Thống kê đơn hàng theo chi nhánh
  Future<Map<String, dynamic>?> getOrderStatisticsByBranch(int branchId) async {
    try {
      final response = await _httpService.get('$baseUrl/orders/statistics/branch/$branchId');
      final data = _httpService.handleResponse(response);
      
      return data is Map<String, dynamic> ? data : null;
    } catch (e) {
            return null;
    }
  }

  // Tóm tắt đơn hàng hôm nay theo chi nhánh
  Future<Map<String, dynamic>?> getTodayOrderSummary(int branchId) async {
    try {
      final response = await _httpService.get('$baseUrl/orders/summary/today/$branchId');
      final data = _httpService.handleResponse(response);
      
      return data is Map<String, dynamic> ? data : null;
    } catch (e) {
            return null;
    }
  }

  // Giờ cao điểm đặt hàng theo chi nhánh
  Future<Map<String, dynamic>?> getPeakHours(int branchId) async {
    try {
      final response = await _httpService.get('$baseUrl/orders/peak-hours/$branchId');
      final data = _httpService.handleResponse(response);
      
      return data is Map<String, dynamic> ? data : null;
    } catch (e) {
            return null;
    }
  }

  // Lấy tất cả đơn hàng
  Future<List<Map<String, dynamic>>?> getAllOrders() async {
    try {
      final response = await _httpService.get('$baseUrl/orders/all');
      final data = _httpService.handleResponse(response);
      
      if (data is List) {
        return data.cast<Map<String, dynamic>>();
      }
      return null;
    } catch (e) {
            return null;
    }
  }

  // Lấy đơn hàng theo ID
  Future<Map<String, dynamic>?> getOrderById(int orderId) async {
    try {
      final response = await _httpService.get('$baseUrl/orders/$orderId');
      final data = _httpService.handleResponse(response);
      
      return data is Map<String, dynamic> ? data : null;
    } catch (e) {
            return null;
    }
  }

  // Lấy danh sách bàn chưa thanh toán hôm nay
  Future<List<int>?> getUnpaidTableIdsToday() async {
    try {
      final response = await _httpService.get('$baseUrl/orders/unpaid-tables/today');
      final data = _httpService.handleResponse(response);
      
      if (data is List) {
        return data.cast<int>();
      }
      return null;
    } catch (e) {
            return null;
    }
  }

  // Lấy đơn hàng theo bàn hôm nay
  Future<List<Map<String, dynamic>>?> getOrdersByTableToday(int tableId) async {
    try {
      final response = await _httpService.get('$baseUrl/orders/table-order/$tableId/today');
      final data = _httpService.handleResponse(response);
      
      if (data is List) {
        return data.cast<Map<String, dynamic>>();
      }
      return null;
    } catch (e) {
            return null;
    }
  }
}

