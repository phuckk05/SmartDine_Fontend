// file: lib/API/payment_api.dart
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // Cần thêm package intl: flutter pub add intl
import 'package:mart_dine/models_owner/payment.dart'; // THÊM: Import model Payment

// Model cho DTO Biểu đồ
class ChartData {
  final String label;
  final double value;
  ChartData({required this.label, required this.value});

  factory ChartData.fromMap(Map<String, dynamic> map) {
    // SỬA: Xử lý linh hoạt các định dạng label khác nhau mà backend có thể trả về.
    // Tương tự như OrderCountData, nó có thể đọc 'date', 'startDate', hoặc 'month'/'year'.
    String label = map['date']?.toString() ?? 
                   map['startDate']?.toString() ?? 
                   (map['month'] != null ? "${map['month']}/${map['year']}" : '');

    return ChartData(
      label: label,
      value: (map['revenue'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

// Model cho DTO So sánh Chi nhánh
class BranchRevenueComparison {
  final int branchId;
  final double totalRevenue;

  BranchRevenueComparison({required this.branchId, required this.totalRevenue});

  factory BranchRevenueComparison.fromMap(Map<String, dynamic> map) {
    return BranchRevenueComparison(
      branchId: map['branchId'] ?? 0,
      totalRevenue: (map['totalRevenue'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

final _uri = 'https://smartdine-backend-oq2x.onrender.com/api/payments';

class PaymentAPI {
  // GET /api/payments/revenue/trends
  Future<List<ChartData>> fetchRevenueTrends(
      String period, int companyId, int? branchId, int days) async {
    // SỬA: Đồng bộ hóa cách xây dựng URL để giống hệt với hàm fetchOrderCount trong order_API.
    // Xử lý tham số branchId và days một cách linh hoạt.
    String branchQuery = (branchId == null) ? "" : "&branchId=$branchId";
    // SỬA: Chỉ thêm tham số 'days' nếu period là 'daily' hoặc 'weekly'.
    String daysQuery = (period == 'daily' || period == 'weekly') ? "&days=$days" : "";

    final response = await http.get(
      // URL được xây dựng lại để chỉ bao gồm các tham số cần thiết.
      Uri.parse('$_uri/revenue/trends?period=$period&companyId=$companyId$branchQuery$daysQuery'),
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
      return body.map((dynamic item) => ChartData.fromMap(item)).toList();
    } else {
      throw Exception('Lỗi tải Revenue Trends (Mã: ${response.statusCode})');
    }
  }

  // GET /api/payments/revenue/branch-comparison
  Future<List<BranchRevenueComparison>> fetchBranchComparison(
     String period, int companyId, int? branchId, int days) async {
    
    // Xử lý branchId = null (Tổng quan)
    // SỬA: Đồng bộ hóa logic xây dựng URL với các hàm khác trong file.
    final branchQuery = (branchId == null) ? "" : "&branchId=$branchId";
    final daysQuery = (period == 'daily') ? "&days=$days" : "";

    final response = await http.get(
      // SỬA: Áp dụng daysQuery để chỉ gửi tham số 'days' khi cần thiết, tránh lỗi 400.
      Uri.parse('$_uri/revenue/branch-comparison?period=$period&companyId=$companyId$branchQuery$daysQuery'),
      headers: {'Accept': 'application/json'},
    );
    
    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
      return body.map((dynamic item) => BranchRevenueComparison.fromMap(item)).toList();
    } else {
      throw Exception('Lỗi tải Branch Comparison (Mã: ${response.statusCode})');
    }
  }

  // THÊM: Hàm mới để lấy tất cả các giao dịch, tương tự fetchOrders.
  /// Lấy danh sách tất cả các giao dịch.
  /// GET /api/payments
  Future<List<Payment>> fetchAllPayments() async {
    final response = await http.get(
      Uri.parse(_uri), // Gọi đến endpoint base /api/payments
      headers: {'Accept': 'application/json'},
    );
    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
      // Giả định bạn có Payment.fromMap để parse dữ liệu
      return body.map((dynamic item) => Payment.fromMap(item)).toList();
    } else {
      throw Exception('Lỗi tải danh sách giao dịch (Mã: ${response.statusCode})');
    }
  }
}

final paymentApiProvider = Provider<PaymentAPI>((ref) => PaymentAPI());