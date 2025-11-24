// file: API/item_api.dart
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:mart_dine/models_owner/item.dart';
const _menuImageUri = 'https://smartdine-backend-oq2x.onrender.com/api/menu-images'; // THÊM
const _uri = 'https://smartdine-backend-oq2x.onrender.com/api/items';
// SỬA LỖI 404 (Lần 3): Rà soát lại các API khác cho thấy có sự không nhất quán trong việc đặt tên (số ít/số nhiều).
// Thử dùng 'menu-item' (số ít) thay vì 'menu-items' (số nhiều).
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
    // SỬA: Đơn giản hóa logic. Endpoint này sẽ trả về tất cả các món ăn
    // của công ty. Backend đã được cập nhật để trả về đối tượng Item
    // bao gồm cả `categoryId` của nó.
    final allItemsUri = Uri.parse('$_uri/all').replace(queryParameters: {
      'companyId': companyId.toString(),
    });
    final allItemsResponse = await http.get(allItemsUri, headers: {'Accept': 'application/json'});
    if (allItemsResponse.statusCode != 200) {
      throw Exception('Lỗi tải danh sách tất cả món ăn (Mã: ${allItemsResponse.statusCode})');
    }
    List<dynamic> allItemsBody = jsonDecode(utf8.decode(allItemsResponse.bodyBytes));
    // SỬA: Lặp qua từng món ăn để lấy ảnh của nó
    List<Item> itemsWithImages = [];
    for (var itemJson in allItemsBody) {
      Item item = Item.fromMap(itemJson);
      // Gọi hàm lấy ảnh cho món ăn này
      final imageUrl = await _fetchFirstImageForItem(item.id);
      // Tạo bản sao của món ăn với URL ảnh đã được cập nhật
      itemsWithImages.add(item.copyWith(image: imageUrl));
    }
    return itemsWithImages;
  }

  // THÊM: Lấy tất cả item thuộc về một menu
  Future<List<Item>> fetchItemsByMenu(int companyId, int menuId) async {
    // TỐI ƯU: Thay vì lặp và gọi API cho từng món, chúng ta sẽ lấy tất cả món ăn của công ty
    // và danh sách ID món ăn trong menu, sau đó lọc ở client.

    // BƯỚC 1: Lấy danh sách ID của các món ăn có trong menu.
    // SỬA LỖI 404 (Lần 5 - GIẢI PHÁP CUỐI CÙNG):
    // Dựa trên logic của hàm xóa (`unassignItemFromMenu`), endpoint để lấy danh sách
    // các quan hệ theo menuId rất có thể là: GET /api/menu-items/{menuId}
    final menuItemUri = Uri.parse('$_menuItemUri/$menuId');
    final menuItemResponse =
        await http.get(menuItemUri, headers: {'Accept': 'application/json'});

    // SỬA: Xử lý trường hợp menu mới chưa có món ăn (API trả về 404 Not Found)
    if (menuItemResponse.statusCode == 404) {
      // Đây là trường hợp hợp lệ cho một menu mới, trả về danh sách rỗng.
      return [];
    }

    if (menuItemResponse.statusCode != 200 && menuItemResponse.statusCode != 201) {
      throw Exception('Lỗi tải danh sách món ăn trong menu (Mã: ${menuItemResponse.statusCode})');
    }

    final List<dynamic> relations = jsonDecode(utf8.decode(menuItemResponse.bodyBytes));
    // Tạo một Set chứa các ID món ăn trong menu để tra cứu nhanh.
    // Đồng thời, tạo một Map để "vá" lại categoryId từ bản ghi quan hệ.
    final itemIdsInMenu = <int>{};
    final categoryIdOverrides = <int, int>{};
    for (var relation in relations) { // relation là một map {'itemId': ..., 'categoryId': ...}
      final int itemId = relation['itemId'];
      itemIdsInMenu.add(itemId);
      categoryIdOverrides[itemId] = relation['categoryId'];
    }

    // BƯỚC 2: Lấy TẤT CẢ món ăn của công ty (đã bao gồm ảnh).
    final allCompanyItems = await fetchAllItems(companyId);

    // BƯỚC 3: Lọc ra những món ăn có trong menu và gán lại categoryId đúng.
    return allCompanyItems
        .where((item) => itemIdsInMenu.contains(item.id))
        .map((item) {
          // Gán categoryId từ bảng quan hệ vào đối tượng Item
          return item.copyWith(categoryId: categoryIdOverrides[item.id]);
        })
        .toList();
  }

  // SỬA: Hoàn nguyên. Hàm addItem không cần và không nên có categoryId.
  Future<Item> addItem(String name, double price, int companyId, String? imageUrl) async {
    // BƯỚC 1: Tạo Item cơ bản, không gửi ảnh
    final itemResponse = await http.post(
      Uri.parse(_uri),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({
        'name': name,
        'price': price,
        'companyId': companyId,
        // 'categoryId' không thuộc về một món ăn, nó thuộc về quan hệ menu-item.
        'image': null, // Luôn gửi null để không lưu vào bảng items
        'statusId': 1,
      }),
    );

    if (itemResponse.statusCode != 201 && itemResponse.statusCode != 200) {
      throw Exception('Lỗi tạo món ăn: ${utf8.decode(itemResponse.bodyBytes)}');
    }
    
    var newItem = Item.fromMap(jsonDecode(utf8.decode(itemResponse.bodyBytes)));

    // BƯỚC 2: Nếu có ảnh, gọi API để lưu vào menu_images
    if (imageUrl != null) {
      await createMenuImage(newItem.id, imageUrl);
      // Gán lại ảnh vào đối tượng trả về để UI hiển thị ngay lập tức
      // SỬA: Tạo một bản sao của đối tượng với ảnh đã được cập nhật
      newItem = newItem.copyWith(image: imageUrl);
    }

    return newItem;
  }

  // SỬA: Hàm xóa item chỉ cần itemId. Backend sẽ xử lý xóa các quan hệ liên quan.
  Future<void> deleteItem(int itemId) async {
    // Backend nên được cấu hình để khi xóa một item,
    // nó cũng sẽ tự động xóa tất cả các bản ghi liên quan trong bảng `menu_items` (ON DELETE CASCADE).
    // Nếu không, bạn sẽ cần gọi API để xóa các quan hệ trước khi xóa item.
    final response = await http.delete(Uri.parse('$_uri/$itemId'));
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Lỗi xóa món ăn: ${utf8.decode(response.bodyBytes)}');
    }
  }

  // THÊM: Xóa một món ăn khỏi một menu (xóa quan hệ menu-item)
  // SỬA: Cập nhật logic xóa để phù hợp với backend.
  // Backend yêu cầu: DELETE /api/menu-items?categoryId=...&itemId=...
  Future<void> unassignItemFromMenu(int itemId, int categoryId) async {
    final uri = Uri.parse(_menuItemUri).replace(queryParameters: {
      'itemId': itemId.toString(),
      'categoryId': categoryId.toString(),
    });

    final response = await http.delete(uri);
    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('Lỗi xóa món ăn khỏi menu: ${utf8.decode(response.bodyBytes)}');
    }
  }

  // SỬA: Gán một món ăn vào menu, BẮT BUỘC phải có categoryId
  Future<void> assignItemToMenu(int itemId, int menuId, int companyId, int categoryId) async {
    final response = await http.post(
      Uri.parse(_menuItemUri),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({
        'menuId': menuId,
        'itemId': itemId,
        'categoryId': categoryId, // THAM SỐ QUAN TRỌNG NHẤT
        'companyId': companyId,
      }),
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Lỗi gán món ăn vào menu: ${utf8.decode(response.bodyBytes)}');
    }
  }

  Future<Item> updateItem(Item item) async {
    final response = await http.put(
      Uri.parse('$_uri/${item.id}'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({
        // KHÔNG gửi 'image' ở đây để tránh cập nhật vào bảng 'items'
        // KHÔNG gửi 'categoryId' vì nó không thuộc về Item
        'name': item.name,
        'price': item.price,
        'statusId': item.statusId,
      }),
    );
    if (response.statusCode == 200) {
      var updatedItem = Item.fromMap(jsonDecode(utf8.decode(response.bodyBytes)));
      // BƯỚC 2: Xử lý ảnh riêng biệt
      // Xóa ảnh cũ
      await deleteMenuImagesByItemId(item.id);
      // Nếu có ảnh mới, tạo mới
      if (item.image != null && item.image!.isNotEmpty) {
        await createMenuImage(item.id, item.image!);
      }
      // Gán lại ảnh vào đối tượng trả về để UI cập nhật
      updatedItem = updatedItem.copyWith(image: item.image);
      return updatedItem;
    } else {
      throw Exception(
          'Lỗi cập nhật món ăn: ${utf8.decode(response.bodyBytes)}');
    }
  }

  // THÊM: Hàm tạo bản ghi trong menu_images
  Future<void> createMenuImage(int itemId, String imageUrl) async {
    final response = await http.post(
      Uri.parse(_menuImageUri),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({'itemId': itemId, 'image': imageUrl}),
    );
    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Lỗi lưu ảnh món ăn: ${utf8.decode(response.bodyBytes)}');
    }
  }

  // THÊM: Hàm xóa tất cả ảnh của một món ăn
  Future<void> deleteMenuImagesByItemId(int itemId) async {
    // Giả định backend có endpoint: DELETE /api/menu-images/by-item/{itemId}
    final response = await http.delete(Uri.parse('$_menuImageUri/by-item/$itemId'));
    if (response.statusCode != 200 && response.statusCode != 204) {
      // Có thể bỏ qua lỗi nếu endpoint không tồn tại, vì mục tiêu là đảm bảo ảnh cũ bị xóa
      print('Warning: Không thể xóa ảnh cũ của món ăn (có thể do endpoint chưa tồn tại). Mã: ${response.statusCode}');
    }
  }

  // THÊM: Hàm private để lấy URL ảnh đầu tiên của một món ăn
  Future<String?> _fetchFirstImageForItem(int itemId) async {
    // Giả định backend có endpoint: GET /api/menu-images?itemId={itemId}
    try {
      final uri = Uri.parse(_menuImageUri).replace(queryParameters: {'itemId': itemId.toString()});
      final response = await http.get(uri, headers: {'Accept': 'application/json'});

      if (response.statusCode == 200) {
        final List<dynamic> images = jsonDecode(utf8.decode(response.bodyBytes));
        if (images.isNotEmpty) {
          // Trả về URL của ảnh đầu tiên tìm thấy
          return images.first['image'];
        }
      }
      // Trả về null nếu không tìm thấy ảnh hoặc có lỗi
      return null;
    } catch (e) {
      // Ghi lại lỗi thay vì ném ra ngoài, để không làm hỏng toàn bộ danh sách
      print('Warning: Không thể tải ảnh cho món ăn ID $itemId. Lỗi: $e');
      return null; // Trả về null nếu có bất kỳ lỗi nào xảy ra
    }
  }
}
final itemApiProvider = Provider<ItemAPI>((ref) => ItemAPI());