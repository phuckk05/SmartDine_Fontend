// file: providers/order_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mart_dine/models_owner/order.dart'; // Đảm bảo đường dẫn model đúng
import 'package:mart_dine/API_owner/order_API.dart'; // THÊM: Import Order API

// THÊM: Provider mới để lấy tất cả đơn hàng từ API
final allOrdersProvider = FutureProvider<List<Order>>((ref) async {
  final api = ref.watch(orderApiProvider);
  return api.fetchOrders();
});

// THÊM: Provider mới để lấy đơn hàng theo branchId từ API
final ordersByBranchProvider =
    FutureProvider.family<List<Order>, int>((ref, branchId) async {
  final api = ref.watch(orderApiProvider);
  return api.fetchOrdersByBranch(branchId);
});