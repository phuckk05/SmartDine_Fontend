// file: lib/API/category_api.dart
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:mart_dine/models_owner/categories.dart';
final _uri = 'https://smartdine-backend-oq2x.onrender.com/api/categories';

class CategoryAPI {
  // SỬA: Thêm companyId và tạo Uri chính xác
  Future<List<Category>> fetchCategories(int companyId) async {
    // Tạo URI với query parameter
    final uri = Uri.parse('$_uri/all').replace(
      queryParameters: {'companyId': companyId.toString()},
    );

    final response =
        await http.get(uri, headers: {'Accept': 'application/json'});
    if (response.statusCode == 200) {
      try {
        List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
        return body.map((dynamic item) => Category.fromMap(item)).toList();
      } catch (e) {
        throw Exception('Lỗi giải mã Categories: $e');
      }
    } else {
      throw Exception('Lỗi tải Categories (Mã: ${response.statusCode})');
    }
  }
  
  // (Các hàm POST, PUT, DELETE giữ nguyên như bạn đã cung cấp)
  Future<Category> createCategory(Category category) async {
    final Map<String, dynamic> requestBody = {
      'name': category.name,
      'companyId': category.companyId,
    };
    final response = await http.post(
      Uri.parse(_uri),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode(requestBody), 
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      return Category.fromMap(jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Lỗi tạo nhóm món (Mã: ${response.statusCode}) - ${utf8.decode(response.bodyBytes)}');
    }
  }

  Future<Category> updateCategory(int id, Category category) async {
    final response = await http.put(
      Uri.parse('$_uri/$id'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode(category.toMap()),
    );
    if (response.statusCode == 200) {
      return Category.fromMap(jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Lỗi cập nhật nhóm món (Mã: ${response.statusCode})');
    }
  }

  Future<bool> deleteCategory(int id) async {
    final response = await http.delete(
      Uri.parse('$_uri/$id'),
      headers: {'Accept': 'application/json'},
    );
    if (response.statusCode == 200 || response.statusCode == 204) {
      return true;
    } else {
      if (response.statusCode == 400) {
        throw Exception('Không thể xóa nhóm món vì vẫn còn món ăn trong đó.');
      }
      throw Exception('Lỗi xóa nhóm món (Mã: ${response.statusCode})');
    }
  }
}
final categoryApiProvider = Provider<CategoryAPI>((ref) => CategoryAPI());