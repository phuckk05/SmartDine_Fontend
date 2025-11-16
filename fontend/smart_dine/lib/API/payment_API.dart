import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:mart_dine/models/payment.dart';

class PaymentAPI {
  final String baseUrl =
      'https://smartdine-backend-oq2x.onrender.com/api/payments';

  // Tạo payment mới
  Future<Payment?> createPayment(Payment payment) async {
    try {
      final url = '$baseUrl/create';
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(payment.toCreatePayload()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return Payment.fromMap(data['payment']);
      } else {
        throw Exception('Failed to create payment: ${response.statusCode}');
      }
    } catch (e) {

      return null;
    }
  }

  // Lấy payments theo orderId
  Future<List<Payment>> getPaymentsByOrderId(int orderId) async {
    try {
      final url = '$baseUrl/order/$orderId';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => Payment.fromJson(item)).toList();
      } else {
        throw Exception('Failed to get payments: ${response.statusCode}');
      }
    } catch (e) {

      return [];
    }
  }

  // Lấy payments theo branchId hôm nay
  Future<List<Payment>> getPaymentsByBranchToday(int branchId) async {
    try {
      final url = '$baseUrl/branch/$branchId/today';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => Payment.fromJson(item)).toList();
      } else {
        throw Exception('Failed to get payments: ${response.statusCode}');
      }
    } catch (e) {

      return [];
    }
  }

  // Lấy doanh thu theo ngày
  Future<double> getRevenueByDay({
    required DateTime date,
    int? branchId,
    int? companyId,
  }) async {
    try {
      final dateStr =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

      String url = '$baseUrl/revenue/day?date=$dateStr';
      if (branchId != null) url += '&branchId=$branchId';
      if (companyId != null) url += '&companyId=$companyId';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        return double.parse(response.body);
      } else {
        throw Exception('Failed to get revenue: ${response.statusCode}');
      }
    } catch (e) {

      return 0.0;
    }
  }

  // Lấy doanh thu theo tuần
  Future<double> getRevenueByWeek({
    required int week,
    required int year,
    int? branchId,
    int? companyId,
  }) async {
    try {
      String url = '$baseUrl/revenue/week?week=$week&year=$year';
      if (branchId != null) url += '&branchId=$branchId';
      if (companyId != null) url += '&companyId=$companyId';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        return double.parse(response.body);
      } else {
        throw Exception('Failed to get revenue: ${response.statusCode}');
      }
    } catch (e) {

      return 0.0;
    }
  }

  // Lấy doanh thu theo tháng
  Future<double> getRevenueByMonth({
    required int year,
    required int month,
    int? branchId,
    int? companyId,
  }) async {
    try {
      String url = '$baseUrl/revenue/month?year=$year&month=$month';
      if (branchId != null) url += '&branchId=$branchId';
      if (companyId != null) url += '&companyId=$companyId';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        return double.parse(response.body);
      } else {
        throw Exception('Failed to get revenue: ${response.statusCode}');
      }
    } catch (e) {

      return 0.0;
    }
  }

  // Lấy doanh thu theo năm
  Future<double> getRevenueByYear({
    required int year,
    int? branchId,
    int? companyId,
  }) async {
    try {
      String url = '$baseUrl/revenue/year?year=$year';
      if (branchId != null) url += '&branchId=$branchId';
      if (companyId != null) url += '&companyId=$companyId';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        return double.parse(response.body);
      } else {
        throw Exception('Failed to get revenue: ${response.statusCode}');
      }
    } catch (e) {

      return 0.0;
    }
  }
}

// Provider
final paymentApiProvider = Provider<PaymentAPI>((ref) {
  return PaymentAPI();
});
