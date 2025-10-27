import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:mart_dine/models/item.dart';

final uri1 = 'https://spring-boot-smartdine.onrender.com/api/items';
final uri2 = 'https://smartdine-backend-oq2x.onrender.com/api/items';

class MenuItemAPI {
  //Lấy tất cả menu items by companyId
  Future<List<Item>> getMenuItemsByCompanyId(int companyId) async {
    final response = await http.get(
      Uri.parse('${uri2}/company/$companyId'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final List<dynamic> data = jsonDecode(response.body);
      return data
          .map((item) => Item.fromMap(item as Map<String, dynamic>))
          .toList();
    }
    print("loi lấy menu items: ${response.statusCode}");
    return [];
  }
}

//menuItemApiProvider
final menuItemApiProvider = Provider<MenuItemAPI>((ref) => MenuItemAPI());
