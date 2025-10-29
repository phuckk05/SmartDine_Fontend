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
      print('🔄 Calling API: $baseUrl/orders');
      final response = await _httpService.get('$baseUrl/orders');
      final data = _httpService.handleResponse(response);
      
      print('📡 API Response status: ${response.statusCode}');
      print('📝 API Response data type: ${data.runtimeType}');
      
      if (data is List) {
        print('📊 Parsed data count: ${data.length}');
        List<Order> orders = data.map((json) => Order.fromJson(json)).toList();
        print('✅ Successfully parsed ${orders.length} orders');
        return orders;
      }
      print('❌ API returned unexpected data format');
      return null;
    } catch (e, stackTrace) {
      print('❌ Error getting all orders: $e');
      print('📍 Stack trace: $stackTrace');
      return null;
    }
  }

  // Lấy orders theo branch ID  
  Future<List<Order>?> getOrdersByBranchId(int branchId) async {
    try {
      print('🔄 Calling API: $baseUrl/orders/branch/$branchId');
      final response = await _httpService.get('$baseUrl/orders/branch/$branchId');
      final data = _httpService.handleResponse(response);
      
      print('📡 API Response status: ${response.statusCode}');
      print('📝 API Response data type: ${data.runtimeType}');
      
      if (data is List) {
        print('📊 Parsed data count: ${data.length}');
        List<Order> orders = data.map((json) => Order.fromJson(json)).toList();
        print('✅ Successfully parsed ${orders.length} orders for branch $branchId');
        return orders;
      } else if (data is Map<String, dynamic> && data['data'] is List) {
        List<Order> orders = (data['data'] as List).map((json) => Order.fromJson(json)).toList();
        return orders;
      }
      print('❌ API returned unexpected data format, returning empty list');
      return [];
    } catch (e, stackTrace) {
      print('❌ Error getting orders by branch: $e');
      print('📍 Stack trace: $stackTrace');
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
      print('Error getting order by id: $e');
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
      print('Error getting unpaid table ids: $e');
      return null;
    }
  }

  // Lấy orders theo tableId hôm nay
  Future<List<Order>?> getOrdersByTableIdToday(int tableId) async {
    try {
      final response = await _httpService.get('$baseUrl/orders/table-order/$tableId/today');
      final data = _httpService.handleResponse(response);
      
      if (data is List) {
        return data.map((json) => Order.fromJson(json)).toList();
      }
      return null;
    } catch (e) {
      print('Error getting orders by table id: $e');
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
      print('Error getting order statuses: $e');
      return null;
    }
  }

  // Lấy thống kê orders theo branchId
  Future<Map<String, dynamic>?> getOrderStatistics(int branchId) async {
    try {
      print('🔄 Getting order statistics for branch: $branchId');
      final response = await _httpService.get('$baseUrl/orders/statistics/branch/$branchId');
      final data = _httpService.handleResponse(response);
      
      print('📡 Statistics API Response status: ${response.statusCode}');
      
      if (data is Map<String, dynamic>) {
        print('✅ Successfully got statistics for branch $branchId');
        return data;
      }
      print('❌ Statistics API returned unexpected data format');
      return null;
    } catch (e, stackTrace) {
      print('❌ Error getting order statistics: $e');
      print('📍 Stack trace: $stackTrace');
      return null;
    }
  }

  // Lấy tóm tắt orders hôm nay theo branchId
  Future<Map<String, dynamic>?> getTodayOrderSummary(int branchId) async {
    try {
      print('🔄 Getting today order summary for branch: $branchId');
      final response = await _httpService.get('$baseUrl/orders/summary/today/$branchId');
      final data = _httpService.handleResponse(response);
      
      print('📡 Summary API Response status: ${response.statusCode}');
      
      if (data is Map<String, dynamic>) {
        print('✅ Successfully got today summary for branch $branchId');
        return data;
      }
      print('❌ Summary API returned unexpected data format');
      return null;
    } catch (e, stackTrace) {
      print('❌ Error getting today order summary: $e');
      print('📍 Stack trace: $stackTrace');
      return null;
    }
  }
}

