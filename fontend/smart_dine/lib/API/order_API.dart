import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:mart_dine/models/order.dart';
// Import model OrderItem
import 'package:mart_dine/models/order_item.dart';

final uri1 = 'https://spring-boot-smartdine.onrender.com/api/orders';
final uri2 = 'https://smartdine-backend-oq2x.onrender.com/api/orders';

// URL MỚI CHO ORDER ITEMS (Dựa trên sửa lỗi của bạn)
final uriOrderItems = 'https://smartdine-backend-oq2x.onrender.com/api/order-items';


class OrderAPI {
  //Lấy danh sách order (Hàm gốc)
  Future<List<Order>> fetchOrders() async {
    final response = await http.get(
      Uri.parse(uri2), // <-- ĐÃ SỬA (bỏ /all)
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body) as List<dynamic>;
      return data
          .map((item) => Order.fromMap(item as Map<String, dynamic>))
          .toList();
    } else {
      print("Loi lay order: ${response.statusCode}");
      throw Exception('Lỗi lấy danh sách order');
    }
  }

  // Lấy danh sách order theo tableId ngay hôm nay (Hàm gốc)
  Future<List<Order>> fetchOrdersByTableIdToday(int tableId) async {
    final response = await http.get(
      Uri.parse('${uri2}/table-order/$tableId/today'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body) as List<dynamic>;
      return data
          .map((item) => Order.fromMap(item as Map<String, dynamic>))
          .toList();
    } else {
      print("Loi lay order theo tableId hom nay: ${response.statusCode}");
      return []; // Trả về rỗng nếu không có hoặc lỗi
    }
  }

  // Lấy danh sách tableId đã có order chưa thanh toán ngay hôm nay (Hàm gốc)
  Future<List<int>> fetchUnpaidTableIdsToday() async {
    final response = await http.get(
      Uri.parse('${uri2}/unpaid-tables/today'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body) as List<dynamic>;
      return data.map((item) => item as int).toList();
    } else {
      print("Loi lay tableId chua thanh toan hom nay: ${response.statusCode}");
      return [];
    }
  }

  // Lấy order theo id (Hàm gốc)
  Future<Order?> getOrderById(int id) async {
    final response = await http.get(
      Uri.parse('$uri2/$id'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return Order.fromMap(data);
    }
    return null;
  }

  // ===================================================================
  // HÀM TẠO ORDER (ĐÃ SỬA LỖI 405)
  // ===================================================================
  Future<Order> createOrder(
      {required int tableId,
      required int userId,
      required int companyId,
      required int branchId}) async {
    print('--- API THẬT: Đang tạo order mới cho bàn $tableId ---');

    final newOrderData = Order(
      tableId: tableId,
      companyId: companyId,
      branchId: branchId,
      userId: userId,
      statusId: 1, // 1 = "Chưa thanh toán" (giả định)
    );

    final body = newOrderData.toJson();

    try {
      // SỬA LẠI URL (bỏ /create)
      final response = await http.post(
        Uri.parse(uri2), // <-- ĐÃ SỬA
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 201 || response.statusCode == 200) { // 201 Created hoặc 200 OK
        print('--- API THẬT: Đã tạo order thành công ---');
        return Order.fromJson(response.body);
      } else {
        print(
            '--- API THẬT: Tạo order thất bại, code: ${response.statusCode}, body: ${response.body} ---');
        throw Exception('Không thể tạo order');
      }
    } catch (e) {
      print('Lỗi khi gọi API createOrder: $e');
      throw Exception('Lỗi khi tạo order: $e');
    }
  }

  // ===================================================================
  // HÀM LẤY ORDER ITEMS (ĐÃ SỬA LỖI 404)
  // ===================================================================
  Future<List<OrderItem>> fetchOrderItems(String orderId) async {
    print('--- API THẬT: Đang tải items cho order $orderId ---');
    try {
      // Dùng URL mới mà bạn đã tìm ra
      final response = await http.get(
        Uri.parse('$uriOrderItems?orderId=$orderId'), // <-- ĐÃ SỬA
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body) as List<dynamic>;
        final items =
            data.map((json) => OrderItem.fromJson(json)).toList();
        print('--- API THẬT: Đã tải ${items.length} món ---');
        return items;
      } else {
        print(
            '--- API THẬT: Tải items thất bại, code: ${response.statusCode}, body: ${response.body} ---');
        return []; // Trả về rỗng nếu lỗi
      }
    } catch (e) {
      print('Lỗi khi gọi API fetchOrderItems: $e');
      return [];
    }
  }

  // ===================================================================
  // HÀM LƯU ORDER ITEMS (ĐÃ SỬA LỖI 404)
  // ===================================================================
  Future<bool> saveOrderItems(
      String orderId, List<Map<String, dynamic>> items) async {
    print('--- API THẬT: Đang gửi ${items.length} món cho order $orderId ---');
    print('Dữ liệu gửi đi: $items');

    // Bạn có thể cần thêm orderId vào nội dung (body) của items
    // Tùy thuộc vào yêu cầu của backend
    
    final body = json.encode(items);

    try {
      // SỬA LẠI URL (dùng URL mới, và có thể là POST thay vì PUT)
      // Giả sử backend dùng POST để *thêm* items
      final response = await http.post( 
        Uri.parse(uriOrderItems), // <-- ĐÃ SỬA
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('--- API THẬT: Gửi thành công ---');
        return true;
      } else {
        print(
            '--- API THẬT: Gửi thất bại, code: ${response.statusCode}, body: ${response.body} ---');
        return false;
      }
    } catch (e) {
      print('Lỗi khi gọi API saveOrderItems: $e');
      return false;
    }
  }
}

// Provider
final orderApiProvider = Provider<OrderAPI>((ref) => OrderAPI());