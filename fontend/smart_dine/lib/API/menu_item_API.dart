import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:mart_dine/models/item.dart';
// import 'package:mart_dine/models/menu.dart';

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
    return [];
  }

  // Lấy item by ID
  Future<Item?> getItemById(int itemId) async {
    final response = await http.get(
      Uri.parse('$uri2/$itemId'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return Item.fromMap(data);
    }
    return null;
  }
}

//menuItemApiProvider
final menuItemApiProvider = Provider<MenuItemAPI>((ref) => MenuItemAPI());

class MenuItemApi {
  //Lấy danh sách menu (Hàm gốc)
  Future<List<Item>> fetchMenus() async {
    final response = await http.get(
      Uri.parse(uri2), // <-- ĐÃ SỬA (bỏ /all)
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body) as List<dynamic>;
      return data
          .map((item) => Item.fromMap(item as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Lỗi lấy danh sách menu');
    }
  }

  //Lay menu theo company id
  Future<List<Item>> fetchMenusByCompanyId(int companyId) async {
    final response = await http.get(
      Uri.parse('$uri2/company/$companyId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body) as List<dynamic>;
      return data
          .map((item) => Item.fromMap(item as Map<String, dynamic>))
          .toList();
    } else {
      return []; // Trả về rỗng nếu không có hoặc lỗi
    }
  }
}

final menuApiProvider = Provider<MenuItemApi>((ref) {
  return MenuItemApi();
});
