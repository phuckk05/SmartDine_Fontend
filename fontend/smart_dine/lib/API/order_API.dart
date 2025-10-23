import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:mart_dine/models/order.dart';

final uri1 = 'https://spring-boot-smartdine.onrender.com/api/orders';
final uri2 = 'https://smartdine-backend-oq2x.onrender.com/api/orders';

class OrderAPI {
  //Lấy danh sách order
  Future<List<Order>> fetchOrders() async {
    final response = await http.get(
      Uri.parse('${uri2}/all'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body) as List<dynamic>;
      return data
          .map((item) => Order.fromMap(item as Map<String, dynamic>))
          .toList();
    } else {
      print("Loi lay order: ${response.statusCode}");
      return [];
    }
  }

  // Lấy danh sách order theo tableId ngay hôm nay
  Future<List<Order>> fetchOrdersByTableIdToday(int tableId) async {
    final response = await http.get(
      Uri.parse('${uri2}/table-order/$tableId/today'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body) as List<dynamic>;
      return data
          .map((item) => Order.fromMap(item as Map<String, dynamic>))
          .toList();
    } else {
      print("Loi lay order theo tableId hom nay: ${response.statusCode}");
      return [];
    }
  }

  // Lấy danh sách tableId đã có order chưa thanh toán ngay hôm nay
  Future<List<int>> fetchUnpaidTableIdsToday() async {
    final response = await http.get(
      Uri.parse('${uri2}/unpaid-tables/today'),
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

  // Lấy order theo id
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
}

// Provider
final orderApiProvider = Provider<OrderAPI>((ref) => OrderAPI());
