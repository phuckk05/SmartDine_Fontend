// file: lib/API_owner/menu_API.dart
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:mart_dine/models_owner/menu.dart';

const _uri = 'https://smartdine-backend-oq2x.onrender.com/api/menus';

/// Lớp MenuAPI chịu trách nhiệm giao tiếp với backend cho các hoạt động liên quan đến Menu.
class MenuAPI {
  /// Lấy tất cả các menu thuộc về một công ty.
  /// GET /api/menus/company/{companyId}
  Future<List<Menu>> getMenusByCompany(int companyId) async {
    final response = await http.get(
      Uri.parse('$_uri/company/$companyId'),
      headers: {'Accept': 'application/json'},
    );
    if (response.statusCode == 200) {
      final List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
      return body.map((dynamic item) => Menu.fromMap(item)).toList();
    } else {
      throw Exception('Lỗi tải danh sách menu (Mã: ${response.statusCode})');
    }
  }

  /// Tạo một menu mới.
  /// POST /api/menus
  Future<Menu> createMenu(Menu menu) async {
    final response = await http.post(
      Uri.parse(_uri),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode(menu.toMap()),
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      return Menu.fromMap(jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Lỗi tạo menu (Mã: ${response.statusCode}) - ${utf8.decode(response.bodyBytes)}');
    }
  }

  /// Cập nhật thông tin một menu đã có.
  /// PUT /api/menus/{id}
  Future<Menu> updateMenu(int id, Menu menuToUpdate) async {
    final response = await http.put(
      Uri.parse('$_uri/$id'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: menuToUpdate.toJson(), // SỬA: Gửi toàn bộ đối tượng menu đã cập nhật
    );
    if (response.statusCode == 200) {
      return Menu.fromMap(jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Lỗi cập nhật menu (Mã: ${response.statusCode})');
    }
  }

  /// Xóa một menu.
  /// DELETE /api/menus/{id}
  Future<void> deleteMenu(int id) async {
    final response = await http.delete(
      Uri.parse('$_uri/$id'),
      headers: {'Accept': 'application/json'},
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Lỗi xóa menu (Mã: ${response.statusCode})');
    }
  }
}

/// Provider để cung cấp một thực thể (instance) của MenuAPI cho toàn ứng dụng.
final menuApiProvider = Provider<MenuAPI>((ref) => MenuAPI());