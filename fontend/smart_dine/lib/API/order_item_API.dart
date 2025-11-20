import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:mart_dine/models/order_item.dart';

final uri1 = 'https://spring-boot-smartdine.onrender.com/api/order-items';
final uri2 = 'https://smartdine-backend-oq2x.onrender.com/api/order-items';

class OrderItemAPI {
  //Lấy danh sách order (Hàm gốc)
  Future<List<OrderItem>> fetchOrders() async {
    final response = await http.get(
      Uri.parse(uri2), // <-- ĐÃ SỬA (bỏ /all)
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body) as List<dynamic>;
      return data
          .map((item) => OrderItem.fromMap(item as Map<String, dynamic>))
          .toList();
    } else {
      print("Loi lay order item: ${response.statusCode}");
      throw Exception('Lỗi lấy danh sách order item');
    }
  }

  /// Lưu danh sách order item
  Future<List<OrderItem>> saveOrderItems(List<OrderItem> newOrderItem) async {
    final response = await http.post(
      Uri.parse('$uri2/save'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(
        newOrderItem.map((item) => item.toCreatePayload()).toList(),
      ),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final List<dynamic> responseData = jsonDecode(response.body);
      return responseData
          .map((json) => OrderItem.fromMap(json as Map<String, dynamic>))
          .toList();
    }

    throw Exception(
      'Loi luu order item: ${response.statusCode} - ${response.body}',
    );
  }

  Future<List<OrderItem>> getOrderItemsByOrderId(int orderId) async {
    final response = await http.get(
      Uri.parse('$uri2/order/$orderId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
      return data
          .map((item) => OrderItem.fromMap(item as Map<String, dynamic>))
          .toList();
    }

    throw Exception(
      'Loi lay order item theo orderId: ${response.statusCode} - ${response.body}',
    );
  }

  Future<void> deleteOrderItem(int orderItemId) async {
    final response = await http.delete(
      Uri.parse('$uri2/$orderItemId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 204) {
      return;
    }

    if (response.statusCode == 400 || response.statusCode == 404) {
      throw Exception(
        response.body.isEmpty ? 'Không thể xóa order item.' : response.body,
      );
    }

    throw Exception(
      'Lỗi xóa order item: ${response.statusCode} - ${response.body}',
    );
  }
}

final orderItemApiProvider = Provider<OrderItemAPI>((ref) {
  return OrderItemAPI();
});
