// file: lib/API/category_api.dart
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:mart_dine/models_owner/categories.dart';
import 'package:mart_dine/API_owner/item_API.dart'; // THÊM: Để sử dụng ItemAPI
final _uri = 'https://smartdine-backend-oq2x.onrender.com/api/categories';

class CategoryAPI {
  // SỬA: Đổi tên hàm để khớp với provider
  Future<List<Category>> fetchCategoriesByCompany(int companyId) async {
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
      'statusId': 1, // Mặc định là 1 (Hoạt động) khi tạo mới
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
    // SỬA: Chỉ gửi những trường cần thiết để cập nhật (name, companyId)
    final Map<String, dynamic> requestBody = {
      'name': category.name,
      'companyId': category.companyId,
      'statusId': category.statusId, // Gửi cả statusId khi cập nhật
    };
    final response = await http.put(
      Uri.parse('$_uri/$id'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode(requestBody),
    );
    if (response.statusCode == 200) {
      return Category.fromMap(jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Lỗi cập nhật nhóm món (Mã: ${response.statusCode})');
    }
  }

  // THÊM: Hàm xóa category và tất cả các liên kết menu-item của nó
  Future<void> deleteCategoryAndAssignments(int categoryId, int companyId) async {
    // BƯỚC 1: Xóa tất cả các bản ghi trong `menu_items` có categoryId này.
    // Vì không có API xóa hàng loạt theo category, ta phải làm thủ công:
    // 1.1. Lấy tất cả các món ăn của công ty.
    final itemApi = ItemAPI(); // Tạo instance của ItemAPI
    final allItems = await itemApi.fetchAllItems(companyId);

    // 1.2. Lặp qua từng món và cố gắng xóa nó khỏi category này.
    // Lời gọi này sẽ xóa bản ghi trong `menu_items` nếu nó tồn tại.
    // Nếu không tồn tại, API sẽ trả lỗi (ví dụ 404), nhưng ta có thể bỏ qua lỗi này.
    for (final item in allItems) {
      try {
        await itemApi.unassignItemFromMenu(item.id, categoryId);
      } catch (e) {
        // Bỏ qua lỗi, vì có thể món ăn này không thuộc category đang xóa.
        print('Info: Could not unassign item ${item.id} from category $categoryId (may not exist): $e');
      }
    }

    // BƯỚC 2: Sau khi đã xóa hết các liên kết, tiến hành xóa category.
    await deleteCategory(categoryId);
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
      // SỬA: Thêm trường hợp đặc biệt cho lỗi 500, có thể do nhóm món đang được sử dụng
      if (response.statusCode == 500) {
        throw Exception('Không thể xóa. Nhóm món này có thể đang được sử dụng trong một hoặc nhiều menu.');
      }
      throw Exception('Lỗi xóa nhóm món (Mã: ${response.statusCode})');
    }
  }
}
final categoryApiProvider = Provider<CategoryAPI>((ref) => CategoryAPI());