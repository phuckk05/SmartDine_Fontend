import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:mart_dine/models/order.dart';
// Import model OrderItem
import 'package:mart_dine/models/order_item.dart';

final uri1 = 'https://spring-boot-smartdine.onrender.com/api/orders';
final uri2 = 'https://smartdine-backend-oq2x.onrender.com/api/orders';

class OrderAPI {
  //Lấy danh sách order (Hàm gốc)
  Future<List<Order>> fetchOrders() async {
    final response = await http.get(
      Uri.parse('${uri2}/all'),
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
  // HÀM TẠO ORDER (ĐÃ CẬP NHẬT LÊN API THẬT)
  // ===================================================================
  Future<Order> createOrder(
      {required int tableId,
      required int userId,
      required int companyId,
      required int branchId}) async {
    print('--- API THẬT: Đang tạo order mới cho bàn $tableId ---');

    // Tạo đối tượng Order (không có id) để gửi đi
    final newOrderData = Order(
      tableId: tableId,
      companyId: companyId,
      branchId: branchId,
      userId: userId,
      statusId: 1, // 1 = "Chưa thanh toán" (giả định)
    );

    final body = newOrderData.toJson(); // Dùng hàm toJson() của model

    try {
      // Giả định endpoint là /create
      final response = await http.post(
        Uri.parse('$uri1/create'), // <-- URL API thật của bạn
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 201) {
        // 201 Created
        print('--- API THẬT: Đã tạo order thành công ---');
        // Server trả về order đã tạo (với ID và createdAt)
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
  // HÀM LẤY ORDER ITEMS (ĐÃ CẬP NHẬT LÊN API THẬT)
  // ===================================================================
  Future<List<OrderItem>> fetchOrderItems(String orderId) async {
    print('--- API THẬT: Đang tải items cho order $orderId ---');
    try {
      // Giả định endpoint là /$orderId/items
      final response = await http.get(
        Uri.parse('$uri1/$orderId/items'), // <-- URL API thật của bạn
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
  // HÀM LƯU ORDER ITEMS (ĐÃ CẬP NHẬT LÊN API THẬT)
  // ===================================================================
  Future<bool> saveOrderItems(
      String orderId, List<Map<String, dynamic>> items) async {
    print('--- API THẬT: Đang gửi ${items.length} món cho order $orderId ---');
    print('Dữ liệu gửi đi: $items');

    final body = json.encode(items);

    try {
      // Giả định dùng PUT để *cập nhật toàn bộ* danh sách món
      final response = await http.put(
        Uri.parse('$uri1/$orderId/items'), // <-- URL API thật của bạn
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
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