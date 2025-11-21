import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:mart_dine/models/order.dart';

final uri1 = 'https://spring-boot-smartdine.onrender.com/api/orders';
final uri2 = 'https://smartdine-backend-oq2x.onrender.com/api/orders';
final uriOrderItems =
    'https://smartdine-backend-oq2x.onrender.com/api/order-items';

class OrderAPI {
  // Gửi yêu cầu thanh toán (cập nhật statusId = 4)
  Future<Order?> requestPayment(int orderId) async {
    try {
      final response = await http.put(
        Uri.parse('$uri2/$orderId/request-payment'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return Order.fromMap(data);
      } else {
        print(
          'Lỗi gửi yêu cầu thanh toán: \\${response.statusCode} - \\${response.body}',
        );
        return null;
      }
    } catch (e) {
            return null;
    }
  }

  //Lấy orders by branchId ngay hôm nay
  Future<List<Order>> fetchOrdersByBranchIdToday(int branchId) async {
    final response = await http.get(
      Uri.parse('$uri2/today/branch/$branchId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body) as List<dynamic>;
      return data
          .map((item) => Order.fromMap(item as Map<String, dynamic>))
          .toList();
    } else {
            return [];
    }
  }

  //Lấy danh sách order (Hàm gốc)
  Future<List<Order>> fetchOrders() async {
    final response = await http.get(
      Uri.parse(uri2), // <-- ĐÃ SỬA (bỏ /all)
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body) as List<dynamic>;
      return data
          .map((item) => Order.fromMap(item as Map<String, dynamic>))
          .toList();
    } else {
            throw Exception('Lỗi lấy danh sách order');
    }
  }

  // Lấy danh sách order theo tableId ngay hôm nay (Hàm gốc)
  Future<List<Order>> fetchOrdersByTableIdToday(int tableId) async {
    final response = await http.get(
      Uri.parse('$uri2/table-order/$tableId/today'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body) as List<dynamic>;
      return data
          .map((item) => Order.fromMap(item as Map<String, dynamic>))
          .toList();
    } else {
            return []; // Trả về rỗng nếu không có hoặc lỗi
    }
  }

  // Lấy danh sách tableId đã có order chưa thanh toán ngay hôm nay (Hàm gốc)
  Future<List<int>> fetchUnpaidTableIdsToday() async {
    final response = await http.get(
      Uri.parse('$uri2/unpaid-tables/today'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body) as List<dynamic>;
      return data.map((item) => item as int).toList();
    } else {
            return [];
    }
  }

  // Lấy order theo id (Hàm gốc)
  Future<Order?> getOrderById(int id) async {
    final response = await http.get(
      Uri.parse('$uri2/$id'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return Order.fromMap(data);
    }
    return null;
  }

  //Lấy order theo branchId
  Future<List<Order>> getOrdersByBranchId(int branchId) async {
    final response = await http.get(
      Uri.parse('${uri2}/branch/$branchId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body) as List<dynamic>;
      return data
          .map((item) => Order.fromMap(item as Map<String, dynamic>))
          .toList();
    } else {
            return [];
    }
  }

  Future<Order?> saveOrder(Order order) async {
    try {
      final response = await http.post(
        Uri.parse('$uri2/save'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(order.toCreatePayload()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);
        return Order.fromMap(data);
      }

            return null;
    } catch (e) {
            return null;
    }
  }

  Future<List<OrderItem>> saveOrderItems(List<OrderItem> items) async {
    if (items.isEmpty) {
      return [];
    }

    try {
      final payload = items.map((item) => item.toCreatePayload()).toList();

      final response = await http.post(
        Uri.parse('$uriOrderItems/save'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<dynamic> data = json.decode(response.body) as List<dynamic>;
        return data
            .map((item) => OrderItem.fromMap(item as Map<String, dynamic>))
            .toList();
      }

            return [];
    } catch (e) {
            return [];
    }
  }
}

// Provider
final orderApiProvider = Provider<OrderAPI>((ref) => OrderAPI());
