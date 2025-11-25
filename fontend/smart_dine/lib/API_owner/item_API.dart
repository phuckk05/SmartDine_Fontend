// file: API/item_api.dart
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:mart_dine/models_owner/item.dart';
const _uri = 'https://smartdine-backend-oq2x.onrender.com/api/items';
const _menuItemUri = 'https://smartdine-backend-oq2x.onrender.com/api/menu-items';

class ItemAPI {
  // SỬA: Lấy item theo categoryId VÀ companyId
  Future<List<Item>> fetchItemsByCategory(
      int companyId, int categoryId) async {
    // Backend API là: GET /api/items/all?companyId=...&categoryId=...
    final uri = Uri.parse('$_uri/all').replace(queryParameters: {
      'companyId': companyId.toString(),
      'categoryId': categoryId.toString(),
    });

    final response =
        await http.get(uri, headers: {'Accept': 'application/json'});
    if (response.statusCode == 200) {
      try {
        List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
        return body.map((dynamic item) => Item.fromMap(item)).toList();
      } catch (e) {
        throw Exception('Lỗi giải mã danh sách món ăn: $e');
      }
    } else {
      throw Exception('Lỗi tải danh sách món ăn (Mã: ${response.statusCode})');
    }
  }

  // SỬA: Lấy tất cả item (phải có companyId)
  Future<List<Item>> fetchAllItems(int companyId) async {
    // Backend API là: GET /api/items/all?companyId=...
    final uri = Uri.parse('$_uri/all').replace(queryParameters: {
      'companyId': companyId.toString(),
    });

    final response =
        await http.get(uri, headers: {'Accept': 'application/json'});
    if (response.statusCode == 200) {
      try {
        List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
        return body.map((dynamic item) => Item.fromMap(item)).toList();
      } catch (e) {
        throw Exception('Lỗi giải mã danh sách tất cả món ăn: $e');
      }
    } else {
      throw Exception('Lỗi tải danh sách tất cả món ăn (Mã: ${response.statusCode})');
    }
  }

  // SỬA: Thêm item mới (Quy trình 2 bước)
  Future<Item> addItem(
      String name, double price, int categoryId, int companyId) async {
    
    // BƯỚC 1: Tạo Item (POST /api/items)
    // Body chỉ chứa các trường Item có (name, price, companyId)
    final itemResponse = await http.post(
      Uri.parse(_uri),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({
        'name': name,
        'price': price,
        'companyId': companyId,
      }),
    );

    if (itemResponse.statusCode != 201 && itemResponse.statusCode != 200) {
      throw Exception('Lỗi tạo món ăn: ${utf8.decode(itemResponse.bodyBytes)}');
    }

    final newItem =
        Item.fromMap(jsonDecode(utf8.decode(itemResponse.bodyBytes)));
    final newItemId = newItem.id;

    // BƯỚC 2: Gán Item vào Category (POST /api/menu-items)
    // Dựa trên ảnh của bạn, 'menu_id' = 1.
    final menuItemResponse = await http.post(
      Uri.parse(_menuItemUri),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({
        'menuId': 1, // Bắt buộc vì là khóa chính
        'itemId': newItemId,
        'categoryId': categoryId,
        'companyId': companyId,
      }),
    );

    if (menuItemResponse.statusCode != 201 &&
        menuItemResponse.statusCode != 200) {
      // Nếu bước 2 lỗi, ta nên xóa item vừa tạo ở bước 1
      try {
        await http.delete(Uri.parse('$_uri/$newItemId'));
      } catch (e) { /* Bỏ qua lỗi rollback */ }
      
      throw Exception(
          'Tạo món ăn thành công, nhưng lỗi gán vào menu: ${utf8.decode(menuItemResponse.bodyBytes)}');
    }

    return newItem; // Trả về item đã tạo
  }

  // SỬA: Hàm xóa item (Quy trình 2 bước)
  Future<void> deleteItem(int itemId, int categoryId) async {
    // BƯỚC 1: Xóa gán (DELETE /api/menu-items?categoryId=...&itemId=...)
    // API này của bạn dùng categoryId/itemId
    final uri = Uri.parse(_menuItemUri).replace(queryParameters: {
      'categoryId': categoryId.toString(),
      'itemId': itemId.toString(),
    });
    
    final menuItemResponse = await http.delete(uri);

    // Nếu không tìm thấy (404) hoặc xóa thành công (200/204) thì đều chấp nhận
    if (menuItemResponse.statusCode != 204 &&
        menuItemResponse.statusCode != 200 &&
        menuItemResponse.statusCode != 404) { 
      throw Exception(
          'Lỗi xóa gán món ăn khỏi nhóm: ${utf8.decode(menuItemResponse.bodyBytes)}');
    }

    // BƯỚC 2: Xóa Item (DELETE /api/items/{id})
    final response = await http.delete(Uri.parse('$_uri/$itemId'));
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Lỗi xóa món ăn: ${utf8.decode(response.bodyBytes)}');
    }
  }


  // SỬA: Hàm cập nhật item (Giữ nguyên, chỉ cập nhật tên và giá)
  Future<Item> updateItem(int itemId, String newName, double newPrice) async {
    final response = await http.put(
      Uri.parse('$_uri/$itemId'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({'name': newName, 'price': newPrice}),
    );
    if (response.statusCode == 200) {
      return Item.fromMap(jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception(
          'Lỗi cập nhật món ăn: ${utf8.decode(response.bodyBytes)}');
    }
  }
}

final itemApiProvider = Provider<ItemAPI>((ref) => ItemAPI());