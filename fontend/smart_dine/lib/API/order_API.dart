import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:mart_dine/models/order.dart';

final uri1 = 'https://spring-boot-smartdine.onrender.com/api/orders';
final uri2 = 'https://smartdine-backend-oq2x.onrender.com/api/orders';

class OrderApi {
  //Lấy tất cả menu items by branchId
  Future<List<Order>> getOrderByBranchId(int branchId) async {
    final response = await http.get(
      Uri.parse('${uri2}/branch/$branchId'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final List<dynamic> data = jsonDecode(response.body);
      return data
          .map((item) => Order.fromMap(item as Map<String, dynamic>))
          .toList();
    }
    print("loi lấy order by branch: ${response.statusCode}");
    return [];
  }
}

//menuItemApiProvider
final orderApiProvider = Provider<OrderApi>((ref) => OrderApi());
