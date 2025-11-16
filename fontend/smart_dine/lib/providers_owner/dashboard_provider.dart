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


// =================================================================
// SỬA: TẠO PROVIDER MỚI ĐỂ TẢI DỮ LIỆU THẬT
// =================================================================

// Provider cho Top 4 Chi nhánh (Gọi API)
final topBranchesProvider = FutureProvider<List<BranchRevenueComparison>>((ref) async {
  final api = ref.watch(paymentApiProvider);
  // SỬA: Lấy companyId động
  final companyId = await ref.watch(ownerCompanyIdProvider.future);

  if (companyId == null) {
    // Nếu không có companyId (ví dụ: owner chưa được gán), trả về danh sách rỗng
    return [];
  }
  
  // 1. Lấy tất cả chi nhánh
  final allBranches = await ref.watch(branchListProvider.future);
  if (allBranches.isEmpty) return [];
  
  // 2. Lấy ID của tất cả chi nhánh
  final branchIds = allBranches.map((b) => b.id).toList();

  // 3. Gọi API so sánh doanh thu (Backend sẽ sắp xếp)
  final revenues = await api.fetchBranchComparison(branchIds, companyId);
  
  // 4. Trả về 4 chi nhánh đầu tiên
  return revenues.take(4).toList();
});

// Provider cho Biểu đồ Doanh thu (Line Chart)
final revenueChartProvider = FutureProvider.family<List<ChartData>, ChartFilter>((ref, filter) async {
  final api = ref.watch(paymentApiProvider);
  // SỬA: Lấy companyId động
  final companyId = await ref.watch(ownerCompanyIdProvider.future);

  if (companyId == null) {
    return [];
  }
  
  // Lấy branchId từ state của UI
  final selectedBranchId = ref.watch(_selectedBranchIdProvider);
  
  String period;
  int days;
  
  switch (filter) {
    case ChartFilter.Tuan:
      period = "daily"; // API Backend hỗ trợ 'daily'
      days = 7;
      break;
    case ChartFilter.Nam:
      period = "monthly"; // API Backend hỗ trợ 'monthly'
      days = 12; // Lấy 12 tháng
      break;
    case ChartFilter.Thang:
    default:
      period = "daily"; // API Backend hỗ trợ 'daily'
      days = 30; // Lấy 30 ngày
      break;
  }
  
  // Gọi API để lấy dữ liệu
  final revenueData = await api.fetchRevenueTrends(period, companyId, selectedBranchId, days);

  // SỬA: Nếu không có dữ liệu, tạo dữ liệu mẫu với giá trị 0
  if (revenueData.isEmpty) {
    final now = DateTime.now();
    final today = DateTime.utc(now.year, now.month, now.day);
    return List.generate(days, (index) {
      final date = (period == "monthly")
          ? DateTime.utc(today.year, today.month - (days - 1 - index), 1)
          : today.subtract(Duration(days: days - 1 - index));
      // SỬA: Dùng đúng constructor của ChartData (label, value)
      final label = (period == "monthly") ? "${date.month}/${date.year}" : formatDate(date);
      return ChartData(label: label, value: 0);
    });
  }

  return revenueData;
});

// Provider cho Biểu đồ Đơn hàng (Bar Chart)
final orderChartProvider = FutureProvider.family<List<OrderCountData>, ChartFilter>((ref, filter) async {
  final api = ref.watch(orderApiProvider);
  // SỬA: Lấy companyId động
  final companyId = await ref.watch(ownerCompanyIdProvider.future);
  if (companyId == null) {
    return [];
  }

  final selectedBranchId = ref.watch(_selectedBranchIdProvider);

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
  
  // Gọi API để lấy dữ liệu
  final orderData = await api.fetchOrderCount(period, companyId, selectedBranchId, days);

  // SỬA: Nếu không có dữ liệu, tạo dữ liệu mẫu với giá trị 0
  if (orderData.isEmpty) {
    final now = DateTime.now();
    final today = DateTime.utc(now.year, now.month, now.day);
    return List.generate(days, (index) {
      final date = (period == "monthly")
          ? DateTime.utc(today.year, today.month - (days - 1 - index), 1)
          : today.subtract(Duration(days: days - 1 - index));
      // SỬA: Dùng đúng constructor của OrderCountData (label, count)
      final label = (period == "monthly") ? "${date.month}/${date.year}" : formatDate(date);
      return OrderCountData(label: label, count: 0);
    });
  }
  return orderData;
});
enum ChartFilter { Tuan, Thang, Nam }

// StateProvider để giữ ID chi nhánh đang chọn (0 = Tổng quan)
// SỬA: Mặc định là 0 (Tổng quan)
final _selectedBranchIdProvider = StateProvider<int>((ref) => 0);