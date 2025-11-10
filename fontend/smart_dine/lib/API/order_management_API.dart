import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/http_service.dart';
import '../models/order.dart';

final orderManagementApiProvider = Provider((ref) => OrderManagementAPI());

class OrderManagementAPI {
  final HttpService _httpService = HttpService();
  static const String baseUrl = 'https://smartdine-backend-oq2x.onrender.com/api';
  // Lấy tất cả orders
  Future<List<Order>?> getAllOrders() async {
    try {
      final response = await _httpService.get('$baseUrl/orders');
      final data = _httpService.handleResponse(response);
      
      if (data is List) {
        List<Order> orders = data.map((json) => Order.fromMap(json)).toList();
        return orders;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Lấy orders theo branch ID  
  Future<List<Order>?> getOrdersByBranchId(int branchId) async {
    try {
      final response = await _httpService.get('$baseUrl/orders/branch/$branchId');
      final data = _httpService.handleResponse(response);
      if (data is List) {
        List<Order> orders = data.map((json) => Order.fromMap(json)).toList();
        return orders;
      } else if (data is Map<String, dynamic> && data['data'] is List) {
        List<Order> orders = (data['data'] as List).map((json) => Order.fromMap(json)).toList();
        return orders;
      }
      return [];
    } catch (e) {
      return null;
    }
  }

  // Lấy order theo ID
  Future<Order?> getOrderById(int orderId) async {
    try {
      final response = await _httpService.get('$baseUrl/orders/$orderId');
      final data = _httpService.handleResponse(response);
      if (data is Map<String, dynamic>) {
        return Order.fromMap(data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }



  // Lấy danh sách tableId đã có order chưa thanh toán hôm nay
  Future<List<int>?> getUnpaidOrderTableIdsToday() async {
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

  // Lấy orders theo tableId hôm nay
  Future<List<Order>?> getOrdersByTableIdToday(int tableId) async {
    try {
      final response = await _httpService.get('$baseUrl/orders/table-order/$tableId/today');
      final data = _httpService.handleResponse(response);
      
      if (data is List) {
        return data.map((json) => Order.fromMap(json)).toList();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Mock method to get order statuses (since we don't have backend endpoint yet)
  Future<List<OrderStatus>?> getAllOrderStatuses() async {
    try {
      // Mock data since backend doesn't have this endpoint yet
      await Future.delayed(const Duration(milliseconds: 100)); // Giảm từ 500ms xuống 100ms
      return [
        OrderStatus(id: 1, code: 'PENDING', name: 'Chờ xử lý'),
        OrderStatus(id: 2, code: 'COOKING', name: 'Đang nấu'),
        OrderStatus(id: 3, code: 'READY', name: 'Sẵn sàng'),
        OrderStatus(id: 4, code: 'SERVED', name: 'Đã phục vụ'),
        OrderStatus(id: 5, code: 'PAID', name: 'Đã thanh toán'),
        OrderStatus(id: 6, code: 'CANCELLED', name: 'Đã hủy'),
      ];
    } catch (e) {
      return null;
    }
  }

  // Lấy thống kê orders theo branchId
  Future<Map<String, dynamic>?> getOrderStatistics(int branchId) async {
    try {
            final response = await _httpService.get('$baseUrl/orders/statistics/branch/$branchId');
      final data = _httpService.handleResponse(response);
      
            if (data is Map<String, dynamic>) {
                return data;
      }
            return null;
    } catch (e) {
      return null;
    }
  }

  // Lấy tóm tắt orders hôm nay theo branchId
  Future<Map<String, dynamic>?> getTodayOrderSummary(int branchId) async {
    try {
      final response = await _httpService.get('$baseUrl/orders/summary/today/$branchId');
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

