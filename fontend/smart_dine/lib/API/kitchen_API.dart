import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:mart_dine/models/order_item.dart';

final uri1 = 'https://spring-boot-smartdine.onrender.com/api/order-items';
final uri2 = 'https://smartdine-backend-oq2x.onrender.com/api/order-items';

class KitchenApi {
  //Lấy tất cả tất cả order items
  Future<List<OrderItem>> getPendingOrderItems(int branchId) async {
    final response = await http.get(
      Uri.parse('${uri2}/today/branch/$branchId'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final List<dynamic> data = jsonDecode(response.body);
      return data
          .map((item) => OrderItem.fromMap(item as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<List<OrderItem>> getOrderItemsByBranch(int branchId) async {
    final response = await http.get(
      Uri.parse('$uri2/branch/$branchId'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final List<dynamic> data = jsonDecode(response.body);
      return data
          .map((item) => OrderItem.fromMap(item as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  //Cập nhật trạng thái order item
  Future<OrderItem> updateOrderItemStatus(int orderItemId, int statusId) async {
    final uri = Uri.parse('$uri2/$orderItemId/status');
    final response = await http.put(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(statusId),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(
        'Failed to update order item status: ${response.statusCode}',
      );
    }

    final Map<String, dynamic> data = jsonDecode(response.body);
    return OrderItem.fromMap(data);
  }
}

final kitchenApiProvider = Provider<KitchenApi>((ref) => KitchenApi());
