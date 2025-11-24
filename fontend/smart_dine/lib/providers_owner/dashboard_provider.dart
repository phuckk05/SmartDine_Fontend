// file: screens/screen_dashboard.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math';
// Thay thế bằng đường dẫn thực tế của bạn
import 'package:mart_dine/core/constrats.dart' show ShadowCus, kTextColorDark, kTextColorLight; 
import 'package:mart_dine/core/style.dart';
import 'package:mart_dine/widgets_owner/appbar.dart';

// Import các màn hình/file mới
import 'package:mart_dine/widgets_owner/_custom_bottom_nav_bar.dart';
import 'package:mart_dine/widgets_owner/_charts.dart';
import 'package:mart_dine/providers_owner/target_provider.dart' show branchListProvider; 
import 'package:mart_dine/models_owner/branch.dart'; 
import 'package:mart_dine/providers_owner/role_provider.dart' show formatDate, formatCurrency;
import 'package:mart_dine/API_owner/payment_API.dart'; // <<< API DOANH THU
import 'package:mart_dine/API_owner/order_API.dart'; // <<< API ĐƠN HÀNG

// THÊM: Import provider để lấy companyId động
import 'package:mart_dine/providers_owner/system_stats_provider.dart';
import 'package:mart_dine/providers/user_session_provider.dart';

// =================================================================
// SỬA: TẠO PROVIDER MỚI ĐỂ TẢI DỮ LIỆU THẬT
// =================================================================

// SỬA: Xóa topBranchesProvider vì không còn sử dụng trong UI mới.

// Provider cho Biểu đồ Doanh thu (Line Chart)
final revenueChartProvider = FutureProvider.family<List<ChartData>, (ChartFilter, int?)>((ref, params) async {
  final filter = params.$1;
  final branchId = params.$2;
  final api = ref.watch(paymentApiProvider);
  final companyId = (await ref.watch(ownerProfileProvider.future)).companyId;
  if (companyId == null) { 
    return []; // Không có companyId, không gọi API
  }

  String period;
  int days;

  switch (filter) {
    case ChartFilter.Tuan:
      period = "daily";
      days = 7;
      break;
    case ChartFilter.Nam:
      period = "monthly";
      days = 12;
      break;
    case ChartFilter.Thang:
    default:
      // SỬA: Lấy dữ liệu 30 ngày gần nhất cho bộ lọc "Tháng".
      period = "daily";
      days = 30;
      break;
  }

  // SỬA: Nếu branchId là null (tổng quan), lấy tất cả chi nhánh và tổng hợp dữ liệu.
  if (branchId == null) {
    final branches = await ref.watch(branchListProvider.future);
    if (branches.isEmpty) return [];

    // Gọi API cho từng chi nhánh
    final results = await Future.wait(
      branches.map((b) => api.fetchRevenueTrends(period, companyId, b.id, days))
    );

    // Tổng hợp kết quả
    final Map<String, double> aggregatedData = {};
    for (var branchData in results) {
      for (var dataPoint in branchData) {
        aggregatedData.update(
          dataPoint.label,
          (value) => value + dataPoint.value,
          ifAbsent: () => dataPoint.value,
        );
      }
    }

    // Chuyển map đã tổng hợp thành list ChartData
    final sortedKeys = aggregatedData.keys.toList()..sort();
    final revenueData = sortedKeys.map((key) => ChartData(label: key, value: aggregatedData[key]!)).toList();
    
    // Nếu không có dữ liệu, trả về list rỗng để logic bên dưới xử lý
    if (revenueData.every((d) => d.value == 0)) {
      return [];
    }
    return revenueData;

  }

  final revenueData = await api.fetchRevenueTrends(period, companyId, branchId, days);

  if (revenueData.isEmpty) {
    // SỬA: Xử lý trường hợp không có dữ liệu trả về để tránh lỗi vẽ biểu đồ.
    // Tạo dữ liệu rỗng cho số ngày/tháng tương ứng.
    // Giữ nguyên logic cũ cho các trường hợp khác (7 ngày, 12 tháng)
    final now = DateTime.now();
    final today = DateTime.utc(now.year, now.month, now.day);
    return List.generate(days, (index) {
      final date = (period == "monthly") ? DateTime.utc(today.year, today.month - (days - 1 - index), 1) : today.subtract(Duration(days: days - 1 - index));
      final label = (period == "monthly") ? "${date.month}/${date.year}" : formatDate(date);
      return ChartData(label: label, value: 0);
    });
  }
  return revenueData;
});

// Provider cho Biểu đồ Đơn hàng (Bar Chart)
final orderChartProvider = FutureProvider.family<List<OrderCountData>, (ChartFilter, int?)>((ref, params) async {
    final filter = params.$1;
    final branchId = params.$2;
    final api = ref.watch(orderApiProvider);
    final companyId = (await ref.watch(ownerProfileProvider.future)).companyId;
    if (companyId == null) { 
      return []; // Không có companyId, không gọi API
    }

    String period;
    int days;

    switch (filter) {
      case ChartFilter.Tuan:
        period = "daily";
        days = 7;
        break;
      case ChartFilter.Nam:
        period = "monthly";
        days = 12;
        break;
      case ChartFilter.Thang:
      default:
        period = "daily";
        days = 30;
        break;
    }

    // SỬA: Nếu branchId là null (tổng quan), lấy tất cả chi nhánh và tổng hợp dữ liệu.
    if (branchId == null) {
      final branches = await ref.watch(branchListProvider.future);
      if (branches.isEmpty) return [];

      // Gọi API cho từng chi nhánh
      final results = await Future.wait(
        branches.map((b) => api.fetchOrderCount(period, companyId, b.id, days))
      );

      // Tổng hợp kết quả
      final Map<String, int> aggregatedData = {};
      for (var branchData in results) {
        for (var dataPoint in branchData) {
          aggregatedData.update(
            dataPoint.label,
            (value) => value + dataPoint.count,
            ifAbsent: () => dataPoint.count,
          );
        }
      }

      // Chuyển map đã tổng hợp thành list OrderCountData
      final sortedKeys = aggregatedData.keys.toList()..sort();
      final orderData = sortedKeys.map((key) => OrderCountData(label: key, count: aggregatedData[key]!)).toList();

      return orderData;
    }

    final orderData = await api.fetchOrderCount(period, companyId, branchId, days);

    if (orderData.isEmpty) {
      final now = DateTime.now();
      final today = DateTime.utc(now.year, now.month, now.day);
      return List.generate(days, (index) {
        final date = (period == "monthly") ? DateTime.utc(today.year, today.month - (days - 1 - index), 1) : today.subtract(Duration(days: days - 1 - index));
        final label = (period == "monthly") ? "${date.month}/${date.year}" : formatDate(date);
        return OrderCountData(label: label, count: 0);
      });
    }
    return orderData;
});
enum ChartFilter { Tuan, Thang, Nam }

// StateProvider để giữ ID chi nhánh đang chọn (0 = Tổng quan)
// SỬA: Xóa _selectedBranchIdProvider vì không còn sử dụng.