import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

final uri2 = 'https://smartdine-backend-oq2x.onrender.com/api';

class MenuStatisticsAPI {
  // Get Top Dishes theo chi nhánh
  Future<List<Map<String, dynamic>>?> getTopDishesByBranch({
    required int branchId,
    int limit = 10,
  }) async {
    try {
      await Future.delayed(const Duration(milliseconds: 150));
      
      String url = '$uri2/menus/top-dishes/branch/$branchId?limit=$limit';
      
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      }
      return null;
    } catch (e) {
            return null;
    }
  }

  // Lấy tất cả menus
  Future<List<Map<String, dynamic>>?> getAllMenus() async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      final response = await http.get(
        Uri.parse('$uri2/menus')
      );
      
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      }
      return null;
    } catch (e) {
            return null;
    }
  }

  // Lấy menu theo ID
  Future<Map<String, dynamic>?> getMenuById(int menuId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      final response = await http.get(
        Uri.parse('$uri2/menus/$menuId')
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
            return null;
    }
  }

  // Tạo menu mới
  Future<Map<String, dynamic>?> createMenu(Map<String, dynamic> menuData) async {
    try {
      await Future.delayed(const Duration(milliseconds: 200));
      final response = await http.post(
        Uri.parse('$uri2/menus'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(menuData),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
            return null;
    }
  }

  // Cập nhật menu
  Future<Map<String, dynamic>?> updateMenu(int menuId, Map<String, dynamic> menuData) async {
    try {
      await Future.delayed(const Duration(milliseconds: 150));
      final response = await http.put(
        Uri.parse('$uri2/menus/$menuId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(menuData),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
            return null;
    }
  }

  // Xóa menu
  Future<bool> deleteMenu(int menuId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      final response = await http.delete(
        Uri.parse('$uri2/menus/$menuId')
      );
      
      return response.statusCode == 204;
    } catch (e) {
            return false;
    }
  }
}

final menuStatisticsApiProvider = Provider<MenuStatisticsAPI>((ref) {
  return MenuStatisticsAPI();
});