import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:mart_dine/models/order.dart';
// Import model OrderItem
import 'package:mart_dine/models/order_item.dart';

final uri1 = 'https://spring-boot-smartdine.onrender.com/api/order_items';
final uri2 = 'https://smartdine-backend-oq2x.onrender.com/api/order_items';

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

  //Luu order item
  Future<List<OrderItem>> createOrderItem(List<OrderItem> newOrderItem) async {
    final response = await http.post(
      Uri.parse('${uri2}/save'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(newOrderItem.map((item) => item.toMap()).toList()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      // SỬA LẠI THÀNH THẾ NÀY:
        final List<dynamic> responseData = jsonDecode(response.body);
        return responseData.map((json) => OrderItem.fromJson(json)).toList();
    } else {
      throw ("Loi luu order item: ${response.statusCode}");
    }
  }
}

final orderItemApiProvider = Provider<OrderItemAPI>((ref) {
  return OrderItemAPI();
});
