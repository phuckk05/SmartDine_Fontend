import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:mart_dine/models/order.dart';
// Import model OrderItem
import 'package:mart_dine/models/order_item.dart';

final uri1 = 'https://spring-boot-smartdine.onrender.com/api/orders';
final uri2 = 'https://smartdine-backend-oq2x.onrender.com/api/orders';

class OrderAPI {
  //Lấy danh sách order (Hàm gốc)
  Future<List<Order>> fetchOrders() async {
    final response = await http.get(
      Uri.parse('$uri2/all'), // <-- ĐÃ SỬA (thêm /all)
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body) as List<dynamic>;
      return data
          .map((item) => Order.fromMap(item as Map<String, dynamic>))
          .toList();
    } else {
      print("Loi lay order: ${response.statusCode}");
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
      print("Loi lay order theo tableId hom nay: ${response.statusCode}");
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
      print("Loi lay tableId chua thanh toan hom nay: ${response.statusCode}");
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

  // ===================================================================
  // HÀM TẠO ORDER (ĐÃ SỬA LỖI 405)
  // ===================================================================
  Future<Order> createOrder(Order newOrderData) async {
    final response = await http.post(
      Uri.parse('$uri2/save'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(newOrderData.toMap()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return Order.fromMap(data);
    } else {
      print("Loi tao order: ${response.statusCode}");
      throw Exception('Lỗi tạo order');
    }
  }
}

// Provider
final orderApiProvider = Provider<OrderAPI>((ref) => OrderAPI());
