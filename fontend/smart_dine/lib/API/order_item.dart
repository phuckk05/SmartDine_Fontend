import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:mart_dine/models/order_item.dart';

final uri1 = 'https://spring-boot-smartdine.onrender.com/api/order-items';
final uri2 = 'https://smartdine-backend-oq2x.onrender.com/api/order-items';

class OrderItemAPI {
  // Lấy danh sách order items
  Future<List<OrderItem>> fetchOrders() async {
    final response = await http.get(
      Uri.parse(uri2),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body) as List<dynamic>;
      return data
          .map((item) => OrderItem.fromMap(item as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Lỗi lấy danh sách order item: ${response.statusCode}');
    }
  }

  // ✅ SỬA: Gửi TỪNG item riêng lẻ vì backend chỉ nhận 1 OrderItem
  Future<List<OrderItem>> createOrderItem(List<OrderItem> newOrderItems) async {
    List<OrderItem> savedItems = [];

    // ✅ GIẢI PHÁP: Gửi từng item một
    for (var orderItem in newOrderItems) {
      try {
        // Chuyển OrderItem thành Map
        final itemJson = orderItem.toJson();

        print('📤 Đang gửi item: ${itemJson}');

        // ⚠️ Backend dùng GET nên phải dùng http.get
        // Nhưng GET không có body, nên phải dùng POST hoặc PUT
        // Vì backend sai, ta thử cả 2 cách:

        // Cách 1: Thử POST (đúng chuẩn)
        var response = await http.post(
          Uri.parse('$uri2/save'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(itemJson),
        );

        // Nếu lỗi 405 (Method Not Allowed), thử GET với query params
        if (response.statusCode == 405) {
          print('⚠️ POST bị 405, thử GET...');
          
          // Cách 2: Dùng GET với query parameters (workaround)
          final queryParams = Uri(queryParameters: {
            'orderId': orderItem.orderId.toString(),
            'itemId': orderItem.itemId.toString(),
            'quantity': orderItem.quantity.toString(),
            'statusId': orderItem.statusId.toString(),
            'addedBy': orderItem.addedBy?.toString() ?? '',
            'note': orderItem.note ?? '',
            'createdAt': orderItem.createdAt.toIso8601String(),
          }).query;

          response = await http.get(
            Uri.parse('$uri2/save?$queryParams'),
            headers: {'Content-Type': 'application/json'},
          );
        }

        print('📥 Response: ${response.statusCode}');
        print('📦 Body: ${response.body}');

        if (response.statusCode == 200 || response.statusCode == 201) {
          final responseData = jsonDecode(response.body);
          savedItems.add(OrderItem.fromJson(responseData));
        } else {
          print('❌ Lỗi lưu item: ${response.statusCode}');
          throw Exception('Lỗi lưu order item: ${response.statusCode}');
        }
      } catch (e) {
        print('❌ Exception khi lưu item: $e');
        throw Exception('Lỗi lưu order item: $e');
      }
    }

    return savedItems;
  }
}

final orderItemApiProvider = Provider<OrderItemAPI>((ref) {
  return OrderItemAPI();
});