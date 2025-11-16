// file: lib/API/payment_api.dart
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // Cần thêm package intl: flutter pub add intl

// Model cho DTO Biểu đồ
class ChartData {
  final String label;
  final double value;
  ChartData({required this.label, required this.value});

  factory ChartData.fromMap(Map<String, dynamic> map) {
    // Backend gửi 'date' và 'revenue'
    return ChartData(
      label: map['date']?.toString() ?? '',
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
    
    // Xử lý branchId = null (Tổng quan)
    String branchQuery = (branchId == null) ? "" : "&branchId=$branchId";

    final response = await http.get(
      Uri.parse('$_uri/revenue/trends?period=$period&companyId=$companyId$branchQuery&days=$days'),
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
      List<int>? branchIds, int companyId) async {
    
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final String endDate = formatter.format(DateTime.now());
    final String startDate = formatter.format(DateTime.now().subtract(Duration(days: 365))); // Lấy 1 năm
    
    String idsQuery = branchIds?.map((id) => 'branchIds=$id').join('&') ?? '';

    final response = await http.get(
      Uri.parse('$_uri/revenue/branch-comparison?startDate=$startDate&endDate=$endDate&companyId=$companyId&$idsQuery'),
      headers: {'Accept': 'application/json'},
    );
    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
      return body.map((dynamic item) => BranchRevenueComparison.fromMap(item)).toList();
    } else {
      throw Exception('Lỗi tải Branch Comparison (Mã: ${response.statusCode})');
    }
  }
}

final paymentApiProvider = Provider<PaymentAPI>((ref) => PaymentAPI());