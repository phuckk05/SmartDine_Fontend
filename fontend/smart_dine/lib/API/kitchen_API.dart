import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:mart_dine/models/kitchen_order.dart';
import 'dart:convert';

final uri2 =
    'https://smartdine-backend-oq2x.onrender.com/api/order-item-actions';

class KitchenOrderAPI {
  //Tạo đơn hàng bếp
  Future<KitchenOrder?> create(KitchenOrder kitchenOrder) async {
    final response = await http.post(
      Uri.parse('${uri2}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(kitchenOrder.toMap()),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return KitchenOrder.fromMap(data);
    }
    return null;
  }

  Future<KitchenOrder?> findKitchenOrderById(String id) async {
    final response = await http.get(
      Uri.parse('${uri2}/${id}'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return KitchenOrder.fromMap(data);
    }
    return null;
  }
}

// Provider cho KitchenOrderAPI
final kitchenOrderApiProvider = Provider<KitchenOrderAPI>(
  (ref) => KitchenOrderAPI(),
);
