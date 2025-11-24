// file: lib/API/order_api.dart
import 'dart:convert';
import 'package:mart_dine/models_owner/order.dart'; // THÊM: Import model Order
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

// Model cho DTO Biểu đồ (Bar chart có thể có nhiều giá trị, nhưng API của bạn chỉ trả về 1)
class OrderCountData {
  final String label;
  final int count; // API trả về 'orders'
  
  OrderCountData({required this.label, required this.count});

  factory OrderCountData.fromMap(Map<String, dynamic> map) {
    String label = map['date']?.toString() ?? 
                   map['startDate']?.toString() ?? 
                   (map['month'] != null ? "${map['month']}/${map['year']}" : '');

    return OrderCountData(
      label: label,
      count: (map['orders'] as num?)?.toInt() ?? 0,
    );
  }
}

final _uri = 'https://smartdine-backend-oq2x.onrender.com/api/orders';

class OrderAPI {
  // GET /api/orders/count
  Future<List<OrderCountData>> fetchOrderCount(
      String period, int companyId, int? branchId, int days) async {
    
    // Xử lý branchId = null (Tổng quan)
    String branchQuery = (branchId == null) ? "" : "&branchId=$branchId";
    // SỬA: Đồng bộ hóa logic với payment_API.
    // Chỉ thêm tham số 'days' nếu period là 'daily' hoặc 'weekly'.
    String daysQuery = (period == 'daily' || period == 'weekly') ? "&days=$days" : "";

    final response = await http.get(
      // SỬA: Xây dựng lại URL để chỉ bao gồm các tham số cần thiết.
      Uri.parse('$_uri/count?period=$period&companyId=$companyId$branchQuery$daysQuery'),
      headers: {'Accept': 'application/json'},
    );
    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
      return body.map((dynamic item) => OrderCountData.fromMap(item)).toList();
    } else {
      throw Exception('Lỗi tải Order Count (Mã: ${response.statusCode})');
    }
  }


  // THÊM: GET /api/orders/all để lấy tất cả đơn hàng
  Future<List<Order>> fetchOrders() async {
    final response = await http.get(
      Uri.parse(_uri), // SỬA: Bỏ '/all' để gọi đến endpoint /api/orders
      headers: {'Accept': 'application/json'},
    );
    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
      return body.map((dynamic item) => Order.fromMap(item)).toList();
    } else {
      throw Exception('Lỗi tải danh sách đơn hàng (Mã: ${response.statusCode})');
    }
  }

  // THÊM: GET /api/orders/branch/{branchId} để lấy đơn hàng theo chi nhánh
  Future<List<Order>> fetchOrdersByBranch(int branchId) async {
    final response = await http.get(
      Uri.parse('$_uri/branch/$branchId'),
      headers: {'Accept': 'application/json'},
    );
    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
      return body.map((dynamic item) => Order.fromMap(item)).toList();
    } else {
      throw Exception(
          'Lỗi tải danh sách đơn hàng theo chi nhánh (Mã: ${response.statusCode})');
    }
  }
}

final orderApiProvider = Provider<OrderAPI>((ref) => OrderAPI());