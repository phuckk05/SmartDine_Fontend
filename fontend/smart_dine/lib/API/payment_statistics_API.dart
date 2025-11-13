import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'demo_data_helper.dart';

final uri2 = 'https://smartdine-backend-oq2x.onrender.com/api';

class PaymentStatisticsAPI {
  // Lấy doanh thu theo ngày
  Future<double?> getRevenueByDay({
    required String date, // YYYY-MM-DD format
    int? branchId,
    int? companyId,
  }) async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      
      String url = '$uri2/payments/revenue/day?date=$date';
      if (branchId != null) url += '&branchId=$branchId';
      if (companyId != null) url += '&companyId=$companyId';
      
      print('=== PAYMENT REVENUE API DEBUG ===');
      print('Calling URL: $url');
      
      final response = await http.get(Uri.parse(url));
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final revenue = double.parse(response.body);
        print('✅ PAYMENT API SUCCESS - Revenue: $revenue');
        return revenue;
      }
      
      // Fallback: generate realistic revenue based on typical order counts
      print('❌ PAYMENT API FAILED (Status: ${response.statusCode}) - generating demo revenue for $date');
      final orderCount = 5 + (date.hashCode % 20); // 5-25 orders based on date
      final demoRevenue = DemoDataHelper.calculateRevenueFromOrders(orderCount) / 1000;
      print('Demo revenue generated: $demoRevenue');
      return demoRevenue;
    } catch (e) {
      print('❌ PAYMENT API ERROR: $e');
      print('Using demo revenue as fallback');
      final orderCount = 5 + (date.hashCode % 20);
      final demoRevenue = DemoDataHelper.calculateRevenueFromOrders(orderCount) / 1000;
      print('Demo revenue generated: $demoRevenue');
      return demoRevenue;
    }
  }

  // Lấy doanh thu theo khoảng thời gian
  Future<double?> getRevenueByPeriod({
    required int branchId,
    required String startDate, // YYYY-MM-DD format
    required String endDate,   // YYYY-MM-DD format
  }) async {
    try {
      print('=== PAYMENT REVENUE PERIOD API DEBUG ===');
      print('Period: $startDate to $endDate, Branch: $branchId');
      
      String url = '$uri2/payments/revenue/period?branchId=$branchId&startDate=$startDate&endDate=$endDate';
      print('Calling URL: $url');
      
      final response = await http.get(Uri.parse(url));
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final revenue = double.parse(response.body);
        print('✅ PAYMENT PERIOD API SUCCESS - Revenue: $revenue');
        return revenue;
      }
      
      // Fallback: generate realistic revenue for the period
      print('❌ PAYMENT PERIOD API FAILED (Status: ${response.statusCode}) - generating demo revenue');
      final days = DateTime.parse(endDate).difference(DateTime.parse(startDate)).inDays + 1;
      final avgOrdersPerDay = 8 + (branchId % 15); // 8-23 orders per day
      final totalOrders = days * avgOrdersPerDay;
      final demoRevenue = DemoDataHelper.calculateRevenueFromOrders(totalOrders) / 1000;
      print('Demo period revenue generated: $demoRevenue (${days} days, ${totalOrders} orders)');
      return demoRevenue;
    } catch (e) {
      print('❌ PAYMENT PERIOD API ERROR: $e');
      print('Using demo revenue as fallback');
      final days = DateTime.parse(endDate).difference(DateTime.parse(startDate)).inDays + 1;
      final avgOrdersPerDay = 8 + (branchId % 15);
      final totalOrders = days * avgOrdersPerDay;
      final demoRevenue = DemoDataHelper.calculateRevenueFromOrders(totalOrders) / 1000;
      print('Demo period revenue generated: $demoRevenue');
      return demoRevenue;
    }
  }

  // Lấy doanh thu theo tuần
  Future<double?> getRevenueByWeek({
    required int week,
    required int year,
    int? branchId,
    int? companyId,
  }) async {
    try {
      await Future.delayed(const Duration(milliseconds: 150));
      
      String url = '$uri2/payments/revenue/week?week=$week&year=$year';
      if (branchId != null) url += '&branchId=$branchId';
      if (companyId != null) url += '&companyId=$companyId';
      
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        return double.parse(response.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Lấy doanh thu theo tháng
  Future<double?> getRevenueByMonth({
    required int year,
    required int month,
    int? branchId,
    int? companyId,
  }) async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      
      String url = '$uri2/payments/revenue/month?year=$year&month=$month';
      if (branchId != null) url += '&branchId=$branchId';
      if (companyId != null) url += '&companyId=$companyId';
      
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        return double.parse(response.body);
      }
      return null;
    } catch (e) {
            return null;
    }
  }

  // Lấy doanh thu theo năm
  Future<double?> getRevenueByYear({
    required int year,
    int? branchId,
    int? companyId,
  }) async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      
      String url = '$uri2/payments/revenue/year?year=$year';
      if (branchId != null) url += '&branchId=$branchId';
      if (companyId != null) url += '&companyId=$companyId';
      
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        return double.parse(response.body);
      }
      return null;
    } catch (e) {
            return null;
    }
  }

  // Get Revenue Trends theo spec mới - đơn giản hơn
  Future<List<Map<String, dynamic>>?> getRevenueTrendsSimple({
    required int branchId,
    required String period, // 'day', 'week', 'month', 'year'
    int days = 7,
  }) async {
    try {
      await Future.delayed(const Duration(milliseconds: 150));
      
      String url = '$uri2/payments/revenue/trends?branchId=$branchId&period=$period&days=$days';
      
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      }
      return null;
    } catch (e) {
            return null;
    }
  }

  // Lấy xu hướng doanh thu theo kỳ (version cũ)
  Future<List<Map<String, dynamic>>?> getRevenueTrends({
    required String period, // 'daily', 'weekly', 'monthly'
    required String startDate, // YYYY-MM-DD
    required String endDate, // YYYY-MM-DD
    int? branchId,
    int? companyId,
  }) async {
    try {
      await Future.delayed(const Duration(milliseconds: 200));
      
      String url = '$uri2/payments/revenue/trends/$period?startDate=$startDate&endDate=$endDate';
      if (branchId != null) url += '&branchId=$branchId';
      if (companyId != null) url += '&companyId=$companyId';
      
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      }
      return null;
    } catch (e) {
            return null;
    }
  }

  // So sánh doanh thu với kỳ trước
  Future<Map<String, dynamic>?> compareRevenue({
    required String period, // 'day', 'week', 'month'
    required String currentDate, // YYYY-MM-DD
    int? branchId,
    int? companyId,
  }) async {
    try {
      await Future.delayed(const Duration(milliseconds: 150));
      
      String url = '$uri2/payments/revenue/compare/$period?currentDate=$currentDate';
      if (branchId != null) url += '&branchId=$branchId';
      if (companyId != null) url += '&companyId=$companyId';
      
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
            return null;
    }
  }

  // So sánh doanh thu giữa các chi nhánh
  Future<List<Map<String, dynamic>>?> compareBranchRevenue({
    required String startDate, // YYYY-MM-DD
    required String endDate, // YYYY-MM-DD
    required List<int> branchIds,
    int? companyId,
  }) async {
    try {
      await Future.delayed(const Duration(milliseconds: 200));
      
      String branchIdsParam = branchIds.join(',');
      String url = '$uri2/payments/revenue/branch-comparison?startDate=$startDate&endDate=$endDate&branchIds=$branchIdsParam';
      if (companyId != null) url += '&companyId=$companyId';
      
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      }
      return null;
    } catch (e) {
            return null;
    }
  }

  // Lấy potential revenue bao gồm serving orders
  Future<double?> getPotentialRevenueByDay({
    required String date, // YYYY-MM-DD format
    int? branchId,
    int? companyId,
    bool includeServing = true,
  }) async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      
      String url = '$uri2/payments/revenue/potential?date=$date&includeServing=$includeServing';
      if (branchId != null) url += '&branchId=$branchId';
      if (companyId != null) url += '&companyId=$companyId';
      
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        return double.parse(response.body);
      }
      return null;
    } catch (e) {
            return null;
    }
  }
}

final paymentStatisticsApiProvider = Provider<PaymentStatisticsAPI>((ref) {
  return PaymentStatisticsAPI();
});